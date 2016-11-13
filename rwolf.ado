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
method(name)
[
 controls(varlist fv ts)
 depvar(varlist max=1)
 seed(numlist integer >0 max=1)
 reps(integer 100)
 verbose
 ]
;
#delimit cr
cap set seed `seed'

local j=1
foreach var of varlist `varlist' {
    tempfile file`j'
    #delimit ;
    bootstrap b`j'=_b[`depvar'], saving(`file`j'') reps(`reps'):
    `method' `var' `depvar' `controls' `if' `in' [`weight' `exp'];
    #delimit cr
    local ++j
}

preserve
use `file1', clear
gen n=_n
restore

end
