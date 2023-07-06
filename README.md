![Stata](https://img.shields.io/badge/stata-2013-green) ![GitHub Starts](https://img.shields.io/github/stars/damiancclarke/rwolf?style=social) ![GitHub license](https://img.shields.io/github/license/damiancclarke/rwolf)

# rwolf - Calculate Romano-Wolf stepdown *p*-values for multiple hypothesis testing

`rwolf` calculates [Romano and Wolf's (2005a,b)](#references) step-down adjusted *p*-values robust to multiple hypothesis testing. This program follows
the resampling algorithm described in [Romano and Wolf (2016)](#references), and provides a *p*-value corresponding to the significance of a hypothesis
test where *S* tests have been implemented, providing strong control of the familywise error rate (the probability of committing any Type I
error among all of the *S* hypotheses tested).  The `rwolf` algorithm constructs a null distribution for each of the *S* hypothesis tests based
on Studentized bootstrap replications of a subset of the tested variables.  Full details of the procedure are described in 
[Romano and Wolf (2016)](#references), and further discussion of this program and its implementation, plus a full discussion of this ado, is provided in 
[Clarke, Romano and Wolf (2019)](#references).

There are two ways for this command to be used. First, either `indepvar()` and `method()` must be specified if the complete Romano-Wolf procedure should be implemented including the estimation of bootstrap
replications and generation of adjusted p-values.  Alternatively, the user can provide `rwolf` with pre-computed bootstrap or permuted
replications of the estimated statistic and standard errors for each of their multiple hypothesis tests of interest.  In this case, the
`nobootstraps` and `pointestimates(numlist)`, `stderrs(numlist)` and `stdests(varlist)` should be indicated, and rwolf calculates the adjusted *p*-values from the replicates provided.

In the former case where `rwolf` takes care of estimating the bootstrap replicates of each test statistic and its standard error, `rwolf` simply
requires that the user indicates the multiple dependent variables to be tested, the independent variable of interest, and (optionally) a series
of control variables which should be included in each test.  `rwolf` works with any estimation-based regression command allowed in Stata,
which should be indicated using the `method()` option. If not specified, `regress` is assumed.  In the case that `ivregress` is specified, it is
assumed that the independent variable is the endogenous variable, and the instrumental variable(s) should be indicated in the `iv()` option. If
this is not the case (ie if the treatment variable is an exogenous variable in the IV model), this should be indicated with the indepexog
option. Optionally, regression weights, if or in can be specified.  By default, 100 bootstrap replications are run for each of the *S* multiple
hypotheses.  Where possible, a larger number of replications should be preferred given that *p*-values are computed by comparing estimates to a
bootstrapped null distribution constructed from these replications. The number of replications is set using the `reps(#)` option, and to
replicate results, the `seed(#)` should be set.

In the case of more complex situations where a user wishes to pre-compute their test statistics, standard errors, and a large number
of bootstrap replicates of each these, the user can request for only the *p*-value correction algorithm to be implemented with the bootstrap
option.  This allows for cases where different estimation methodologies or different independent variables are used in each model within the
family of hypothesis tests, or where more complicated resampling procedures are used, such as those based on permutation.

By default, the re-sampled null distributions are formed using a simple bootstrap procedure.  However, more complex stratified and/or clustered
resampling procedures can be specified using the `strata()` and `cluster()` options.  The `cluster()` option refers only to the resampling procedure,
and not to the standard errors estimated in each original regression model.  If the standard variance estimator is not desired for
regression models, this should be indicated using the same `vce()`  specification as in the original regression models, for example
`vce(cluster clustvar)`.  It is suggested that the `cluster()` and `vce(cluster clustvar)` should be used together.

The command returns the Romano Wolf *p*-value corresponding to each variable, standard (bootstrapped) uncorrected *p*-values, and for
reference, the original uncorrected (analytical) *p*-value from the initial tests when `rwolf` estimates baseline regression models.  `rwolf`
is an e-class command, and the Romano Wolf *p*-value for each variable is returned as a scalar in `e(rw_varname)`.  A matrix is also returned as
`e(RW)` providing the full set of Romano-Wolf corrected *p*-values.

To install directly into Stata:
```s
ssc install rwolf, replace
```
or using ```net install``` command:
```s
net install rwolf, from("https://raw.githubusercontent.com/damiancclarke/rwolf/master") replace
```
## Syntax

## Running an example

### References
D. Clarke, J. P. Romano, and M. Wolf. **[The Romano–Wolf Multiple­-hypothesis Correction in Stata](https://journals.sagepub.com/doi/abs/10.1177/1536867X20976314)**. *The Stata Journal*, 20(4):812–843, 2020.

J. P. Romano and M. Wolf. **[Stepwise Multiple Testing as Formalized Data Snooping](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-0262.2005.00615.x)**. Econometrica, 73(4): 1237–1282, 2005a.

J. P. Romano and M. Wolf. **[Exact and Approximate Stepdown Methods for Multiple Hypothesis Testing](https://www.tandfonline.com/doi/abs/10.1198/016214504000000539)**. Journal of the American Statistical Association, 100(469):94–108, 2005b.

J. P. Romano and M. Wolf. **[Efficient computation of adjusted p-­values for resampling-­based stepdown multiple testing](https://www.sciencedirect.com/science/article/abs/pii/S0167715216000389)**. *Statistics and Probability Letters*, 113:38–40, 2016.
