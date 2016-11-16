*! rwolf: Romano Wolf stepdown hypothesis testing algorithm
*! Version 0.0.0 november 12, 2016 @ 22:25:56
*! Author: Damian Clarke
*! Department of Economics
*! Universidad de Santiago de Chile
*! damian.clarke@usach.cl

cap program drop rwolf
program rwolf, eclass
vers 11.0
#delimit ;
syntax varlist(min=1 fv ts numeric) [if] [in] [pweight fweight aweight iweight],
depvar(varlist max=1)
[
 method(name)
 controls(varlist fv ts)
 seed(numlist integer >0 max=1)
 reps(integer 100)
 verbose
 ]
;
#delimit cr
cap set seed `seed'
if `"`method'"'=="" local method regress


*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution
*-------------------------------------------------------------------------------
local j=0
foreach var of varlist `varlist' {
    local ++j
    tempfile file`j'
    #delimit ;
    bootstrap b`j'=_b[`depvar'], saving(`file`j'') reps(`reps'):
    `method' `var' `depvar' `controls' `if' `in' [`weight' `exp'];
    #delimit cr
    preserve
    use `file`j'', clear
    gen n=_n
    qui save `file`j'', replace
    restore
}

preserve
use `file1'
if `j'>1 {
    foreach jj of numlist 2(1)`j' {
        merge 1:1 n using `file`jj''
        drop _merge
    }
}

*-------------------------------------------------------------------------------
*--- Create null t-distribution
*-------------------------------------------------------------------------------
foreach num of numlist 1(1)`j' {
    sum b`num'
    replace b`num'=abs((b`num'-r(mean))/r(sd))
}


list



restore
end
