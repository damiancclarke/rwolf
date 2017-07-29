*! rwolf: Romano Wolf stepdown hypothesis testing algorithm
*! Version 1.1.0 july 23, 2017 @ 11:03:44
*! Author: Damian Clarke
*! Department of Economics
*! Universidad de Santiago de Chile
*! damian.clarke@usach.cl

/*
version highlights:
1.0.0 [01/12/2016]: Romano Wolf Procedure exporting p-values
1.1.0: Experimental weighting procedure within bootstrap to allow weights
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
 manual
 *
 ]
;
#delimit cr
cap set seed `seed'
if `"`method'"'=="" local method regress

*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution [UNWEIGHTED]
*-------------------------------------------------------------------------------
dis "Running `reps' bootstrap replications for each variable.  This may take some time"
if length(`"`weight'"')==0&length(`"`manual'"')==0 {
    local j=0
    local cand
    foreach var of varlist `varlist' {
        local ++j
        cap qui `method' `var' `indepvar' `controls' `if' `in', `options'
        if _rc!=0 {
            dis as error "Your original `method' does not work."
            dis as error "Please test the `method' and try again."
            exit _rc
        }
        local t`j' = abs(_b[`indepvar']/_se[`indepvar'])
        local n`j' = e(N)-e(rank)
        if `"`method'"'=="areg" local n`j' = e(df_r)
        local cand `cand' `j'
        
        tempfile file`j'
        if length(`"`verbose'"')==0 {
            #delimit ;
            qui bootstrap b`j'=_b[`indepvar'], saving(`file`j'') reps(`reps'):
                `method' `var' `indepvar' `controls' `if' `in', `options';
            #delimit cr
        }
        else {
            #delimit ;
            bootstrap b`j'=_b[`indepvar'], saving(`file`j'') reps(`reps'):
                `method' `var' `indepvar' `controls' `if' `in', `options';
            #delimit cr
        }
        if e(N_misreps)!=0 {
            local mr = e(N_misreps)
            dis ""
            dis as error "`mr' bootstrap replications could not be estimated for `var'."
            dis as error "To correct this, the manual option is recommended."
        }
        
        preserve
        qui use `file`j'', clear
        qui gen n=_n
        qui save `file`j'', replace
        restore
    }
}
*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution [WEIGHTED]
*-------------------------------------------------------------------------------
qui count
local Nobs1 = r(N)
if length(`"`weight'"')!=0|length(`"`manual'"')!=0 {
    local j=0
    local cand
    local wt [`weight' `exp']
    
    foreach var of varlist `varlist' {
        local ++j
        cap qui `method' `var' `indepvar' `controls' `if' `in' `wt', `options'
        if _rc!=0 {
            dis as error "Your original `method' does not work."
            dis as error "Please test the `method' and try again."
            exit _rc
        }
        local t`j' = abs(_b[`indepvar']/_se[`indepvar'])
        local n`j' = e(N)-e(rank)
        if `"`method'"'=="areg" local n`j' = e(df_r)
        local cand `cand' `j'
        
        qui count
        local Nobs = r(N)
        if `reps'>`Nobs' qui set obs `reps'
        tempvar b`j'
        qui gen `b`j''=.
        forvalues i=1/`reps' {
            if length(`"`verbose'"')!=0 dis "Bootstrap sample `i' for `var'"
            preserve
            bsample `if' `in' 
            qui `method' `var' `indepvar' `controls' `if' `in' `wt', `options'
            local bval = _b[`indepvar']
            restore
            qui replace `b`j'' = `bval' in `i'
        }
        preserve
        keep `b`j''
        rename `b`j'' b`j'
        gen n=_n
        tempfile file`j'
        qui save `file`j'', replace
        restore
        drop `b`j''
    }
    if `reps'>`Nobs1' qui keep in 1/`Nobs1'
}

preserve
qui use `file1', clear
if `j'>1 {
    foreach jj of numlist 2(1)`j' {
        qui merge 1:1 n using `file`jj''
        qui drop _merge
    }
}

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
