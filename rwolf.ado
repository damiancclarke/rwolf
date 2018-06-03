*! rwolf: Romano Wolf stepdown hypothesis testing algorithm
*! Version 2.2.0 june 2, 2018 @ 21:17:21
*! Author: Damian Clarke
*! Department of Economics
*! Universidad de Santiago de Chile
*! damian.clarke@usach.cl

/*
version highlights:
1.0.0 [01/12/2016]: Romano Wolf Procedure exporting p-values
1.1.0:[23/07/2017]: Experimental weighting procedure within bootstrap to allow weights
2.0.0:[16/10/2017]: bsample exclusively.  Add cluster and strata for bsample
2.1.0:[15/12/2017]: Adding ivregress as permitted method.
2.2.0:[29/05/2018]: Correcting estimate of standard error in studentized t-value
*/


cap program drop rwolf
program rwolf, eclass
vers 11.0
#delimit ;
syntax varlist(min=1 fv ts numeric) [if] [in] [pweight fweight aweight iweight],
indepvar(varlist max=1)
[
 method(name)
 controls(varlist fv ts)
 seed(numlist integer >0 max=1)
 reps(integer 100)
 Verbose
 strata(varlist)
 otherendog(varlist)
 cluster(varlist)
 iv(varlist)
 indepexog
 bl(name)
 *
 ]
;
#delimit cr
cap set seed `seed'
if `"`method'"'=="" local method regress
if `"`method'"'=="ivreg2"|`"`method'"'=="ivreg" {
    dis as error "To estimate IV regression models, specify method(ivregress)"
    exit 200
}
if `"`method'"'!="ivregress"&length(`"`indepexog'"')>0 {
    dis as error "indepexog argument can only be specified with method(ivregress)"
    exit 200
}
if `"`method'"'=="ivregress" {
    local ivr1 "("
    local ivr2 "=`iv')"
    local method ivregress 2sls
    if length(`"`iv'"')==0 {
        dis as error "Instrumental variable(s) must be included when specifying ivregress"
        dis as error "Specify the IVs using iv(varlist)"
        exit 200
    }    
}
else {
    local ivr1
    local ivr2
    local otherendog
}

local bopts
if length(`"`strata'"')!=0  local bopts `bopts' strata(`strata')
if length(`"`cluster'"')!=0 local bopts `bopts' cluster(`cluster')

if length(`"`verbose'"')==0 local q qui

*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution
*-------------------------------------------------------------------------------    
local j=0
local cand
local wt [`weight' `exp']

tempname nullvals
tempfile nullfile
file open `nullvals' using "`nullfile'", write all

`q' dis "Displaying original (uncorrected) models:"
foreach var of varlist `varlist' {
    local ++j
    local Xv `controls'
    if length(`"`bl'"')!=0 local Xv `controls' `var'`bl' 
    if length(`"`indepexog'"')==0 {
        `q' `method' `var' `ivr1'`indepvar' `otherendog'`ivr2' `Xv' `if' `in' `wt', `options'
    }
    else {
        `q' `method' `var' `ivr1'`otherendog'`ivr2' `indepvar' `Xv' `if' `in' `wt', `options'
    }
    if _rc!=0 {
        dis as error "Your original `method' does not work."
        dis as error "Please test the `method' and try again."
        exit _rc
    }
    local t`j' = abs(_b[`indepvar']/_se[`indepvar'])
    local n`j' = e(N)-e(rank)
    if `"`method'"'=="areg" local n`j' = e(df_r)
    local cand `cand' `j'
    
    file write `nullvals' "b`j'; se`j';"
}


dis "Running `reps' bootstrap replications for each variable.  This may take some time"
forvalues i=1/`reps' {
    if length(`"`verbose'"')!=0 dis "Bootstrap sample `i'."
    local j=0
    preserve
    bsample `if' `in', `bopts'
    
    foreach var of varlist `varlist' {
        local ++j
        local Xv `controls'
        if length(`"`bl'"')!=0 local Xv `controls' `var'`bl' 
        if length(`"`indepexog'"')==0 {
            qui `method' `var' `ivr1'`indepvar'  `otherendog'`ivr2' `Xv' `if' `in' `wt', `options'
        }
        else {
            qui `method' `var' `ivr1'`otherendog'`ivr2' `indepvar' `Xv' `if' `in' `wt', `options'
        }
        if `j'==1 file write `nullvals' _n "`= _b[`indepvar']';`= _se[`indepvar']'"
        else file write `nullvals' ";`= _b[`indepvar']';`= _se[`indepvar']'"
    }
    restore
}

preserve
file close `nullvals'
qui insheet using `nullfile', delim(";") names clear

*-------------------------------------------------------------------------------
*--- Create null t-distribution
*-------------------------------------------------------------------------------
foreach num of numlist 1(1)`j' {
    qui sum b`num'
    qui replace b`num'=abs((b`num'-r(mean))/r(sd))
}

*-------------------------------------------------------------------------------
*--- Create stepdown value in descending order based on t-stats
*-------------------------------------------------------------------------------
local maxt = 0
local pval = 0
local rank

while length("`cand'")!=0 {
    local donor_tvals

    foreach var of local cand {
        if `t`var''>`maxt' {
            local maxt = `t`var''
            local maxv `var'
        }
        qui dis "Maximum t among remaining candidates is `maxt' (variable `maxv')"
        local donor_tvals `donor_tvals' b`var'
    }
    qui egen empiricalDist = rowmax(`donor_tvals')
    sort empiricalDist
    forvalues cnum = 1(1)`reps' {
        qui sum empiricalDist in `cnum'
        local cval = r(mean)
        if `maxt'>`cval' {
            local pval = 1-((`cnum'+1)/(`reps'+1))
        }
    }
    local prm`maxv's= `pval'
    if length(`"`prmsm1'"')!=0 local prm`maxv's=max(`prm`maxv's',`prmsm1')
    local p`maxv'   = string(ttail(`n`maxv'',`maxt')*2,"%6.4f")
    if `"`method'"'=="ivregress 2sls" local p`maxv'   = string((1-normal(abs(`maxt')))*2,"%6.4f")
    local prm`maxv' = string(`prm`maxv's',"%6.4f")
    local prmsm1 = `prm`maxv's'
    
    drop empiricalDist
    local rank `rank' `maxv'
    local candnew
    foreach c of local cand {
        local match = 0
        foreach r of local rank {
            if `r'==`c' local match = 1
        }
        if `match'==0 local candnew `candnew' `c'
    }
    local cand `candnew'
    local maxt = 0
    local maxv = 0
}

restore

*-------------------------------------------------------------------------------
*--- Report and export p-values
*-------------------------------------------------------------------------------
local j=0
dis _newline
foreach var of varlist `varlist' {
    local ++j
    local ORIG "Original p-value is `p`j''"
    local RW "Romano Wolf p-value is `prm`j''"
    dis "For the variable `var': `ORIG'. `RW'."
    ereturn scalar rw_`var'=`prm`j's'
}   

end
