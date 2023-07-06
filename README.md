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
```s
 rwolf depvars [if] [in] [weight], [options]
```
### Options
+ indepvar(varlist)        Indicates the independent (treatment) variable which is included
                           in multiple hypothesis tests. This will typically be a single
                           independent variable, however it is possible to indicate various
                           independent (treatment) variables which are included in the same
                           model, and the Romano-Wolf procedure will be implemented
                           efficiently returning p-values for each dependent variable of
                           interest, corresponding to each of the specified independent
                           variables.  This option must be specified, unless the
                           nobootstraps option is indicated.
+ method(regress | logit | probit | ivregress |...)
                           Indicates to Stata how each of the multiple hypothesis tests are
                           performed (ie the baseline models).  Any estimation command
                           permitted by Stata can be included.  See regress for a full list
                           of estimation commands in Stata.  If not specified, regress is
                           assumed. If an IV regression is desired, this must be specified
                           with ivregress only, and the iv() option below must be
                           specified.
+ controls(varlist)        Lists all other control variables which are to be included in the
                           model to be tested multiple times.  Any variable format accepted
                           by varlist is permitted including time series and factor
                           variables.
+ nulls(numlist)           Indicates the parameter values of interest used in each test. If
                           specified, a single scalar value should be indicated for each of
                           the multiple hypotheses tested, and these should be listed in
                           the same order that variables are listed as depvars in the
                           command syntax. In the case that multiple indepvars are
                           specified, null parameters should be specified grouped first by
                           indepvars and then by depvars. For example, if two independent
                           variables are considered with four dependent variables, first
                           the four null parameters associated with the first independent
                           variable should be listed, followed by the four null parameters
                           associated with the second independent variable. If this option
                           is not used, it is assumed that each null hypothesis is that the
                           parameter is equal to 0.
+ seed(#)                  Sets seed to indicate the initial value for the pseudo-random
                           number generator.  # can be any integer between 0 and 2^31-1.
+ reps(#)                  Perform # bootstrap replication; default is reps(100).  Where
                           possible prefer a larger number of replications for more precise
                           p-values.  In IV models, a considerably larger number of
                           replications is highly recommended.
+ verbose                   Requests additional output, including display of the initial
                           (uncorrected) models estimated. This will also result in the
                           generation of a summary output message indicating the number of
                           hypotheses rejected in uncorrected models and when implementing
                           the Romano-Wolf correction, as well as any dependent variables
                           for which the null is rejected in the Romano-Wolf procedure.
+ strata(varlist)           specifies the variables identifying strata.  If strata() is
                           specified, bootstrap samples are selected within each stratum
                           when forming the resampled null distributions.
+ cluster(varlist)          specifies the variables identifying resampling clusters.  If
                           cluster() is specified, the sample drawn when forming the
                           resampled null distributions is a bootstrap sample of clusters.
                           This option does not cluster standard errors in each original
                           regression.  If desired, this should be additionally specified
                           using vce(cluster clustvar).  It is suggested that these options
                           be used together to ensure that underlying regression models and
                           bootstrap resampling obey the same clustering schemes.  If
                           vce(cluster clustvar) is indicated, it is assumed that a
                           clustered bootstrap resample is desired, and cluster() will
                           cluster on the same {cmd clustvar}.  If this is not desired, the
                           regcluster() option should be used, which allows for a cluster
                           variable to be passed only to the underlying regressions, or for
                           different cluster variables to be used for the regression, and
                           the bootstrap resamples.
+ regcluster(varname)       allows for a cluster variable to be passed directly to the
                           regressions used in each test.  This option allows for different
                           variables to be used for clustering in the underlying regression
                           (via regcluster()) and the bootstrap resample (via clustvar()),
                           or for a variable to be used to cluster the underlying
                           regression, but not cluster the bootstrap resample procedure.
+ onesided(string)          Indicates that p-values based on one-sided tests should be
                           calculated.  Unless specified, p-values based on two-sided tests
                           are provided, corresponding to the null that each parameter is
                           equal to 0 (or the values indicated in nulls()). In onesided(
                           string), string must be either "positive", in which case the
                           null is that each parameter is greater than or equal to 0, or
                           "negative" in which case the null is that each parameter is less
                           than or equal to 0.
+ iv(varlist)               only necessary when method(ivregress) is specified.  The
                           instrumental variables for the treatment variable of interest
                           should be specified in iv().  At least as many instruments as
                           endogenous variables must be included.
+ otherendog(varlist)       If more than one endogenous variable is required in ivregress
                           models, additional endogenous variables can be included using
                           this option.  By default, when ivregress is specified it is
                           assumed that the variable specified in indepvar(varname) is an
                           endogenous variable which must be instrumented.  If this is the
                           case, the variable should not be entered again in otherendog(
                           varlist).
+ indepexog                If ivregress is specified, but indepvar(varname) is an exogenous
                           variable, indepexog should be indicated.  In this case all
                           endogenous variables must be specified in otherendog(varlist)
                           and all instruments must be specified in iv(varlist).
+ bl(string)               Allows for the inclusion of baseline measures of the dependent
                           variable as controls in each model.  If desired, these variables
                           should be created with some suffix, and the suffix should be
                           included in the bl() option.  For example, if outcome variables
                           are called y1, y2 and y3, variables y1_bl, y2_bl and y3_bl
                           should be created with baseline values, and bl(_bl) should be
                           specified.
+ noplusone                Calculate the Resampled and Romano-Wolf adjusted p-values without
                           adding one to the numerator and denominator.
+ nodots                   Suppress replication dots in bootstrap resamples.
+ holm                     Along with standard output, additionally provide p-values
                           corresponding to the Holm multiple hypothesis correction.
+ graph                    Requests that a graph be produced showing the Romano-Wolf null
                           distribution corresponding to each variable examined.
+ varlabels                Name panels on the graph of null distributions using their
                           variable labels rather than their variable names.
+ other options            Any additional options which correspond to the baseline regression
                                 model.  All options permitted by the indicated method are
                                 allowed.

#### Options specific to cases where resampled estimates are user-provided
+ nobootstraps              Indicates that bootstrap replications do not need to be estimated
                           by the rwolf command. In this case, each variable indicated in
                           depvars must consist of M bootstrap realizations of the
                           statistic of interest corresponding to each of the multiple
                           baseline models. Additionally, for each variable indicated in
                           depvars, the corresponding standard errors for each of the M
                           bootstrap replicates should be stored as another variable, and
                           these variables should be indicated as stdests(varlist).
                           Finally, the original estimates corresponding to each model in
                           the full sample should be provided in pointestimates(numlist),
                           and the original standard errors should be provided in stderrs(
                           numlist). This option may not be specified if indepvar() and
                           method() are specified. For all standard implementations based
                           on regression models, indepvar() and method() should be
                           preferred.
+ pointestimates(numlist)   Provides the estimated statistics of interest in the full sample
                           corresponding to each of the depvars indicated in the command.
                           These estimates must be provided in the same order as the
                           depvars are specified. This option may not be specified if
                           indepvar() and method() are specified. For all standard
                           implementations based on regression models, indepvar() and
                           method() should be preferred.
+ stderrs(numlist)         Provides the estimated standard errors for each estimated
                           statistic in the full sample. These estimates must be provided
                           in the same order as the depvars are specified. This option may
                           not be specified if indepvar() and method() are specified. For
                           all standard implementations based on regression models,
                           indepvar() and method() should be preferred.
+ stdests(varlist)         Contains variables consisting of estimated standard errors from
                           each of the M resampled replications. These standard errors
                           should correspond to the resampled estimates listed as each
                           depvar and must be provided in the same order as the depvars are
                           specified. This option may not be specified if indepvar() and
                           method() are specified. For all standard implementations based
                           on regression models, indepvar() and method() should be
                           preferred.
+ nullimposed              Indicates that resamples are centered around the null, rather than
                           the original estimate. This option is generally only used when
                           permutations rather than bootstrap resamples are performed.




## Running an example
```s
sysuse auto

. rwolf headroom turn price rep78, indepvar(weight) controls(trunk mpg) reps(250) seed(121316)
Bootstrap replications (250). This may take some time.
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5
..................................................     50
..................................................     100
..................................................     150
..................................................     200
..................................................     250




Romano-Wolf step-down adjusted p-values


Independent variable:  weight
Outcome variables:   headroom turn price rep78
Number of resamples: 250


------------------------------------------------------------------------------
   Outcome Variable | Model p-value    Resample p-value    Romano-Wolf p-value
--------------------+---------------------------------------------------------
           headroom |    0.6719             0.6574              0.6574
               turn |    0.0000             0.0040              0.0040
              price |    0.0075             0.0359              0.0478
              rep78 |    0.0998             0.0797              0.1474
------------------------------------------------------------------------------
```

### References
D. Clarke, J. P. Romano, and M. Wolf. **[The Romano–Wolf Multiple­-hypothesis Correction in Stata](https://journals.sagepub.com/doi/abs/10.1177/1536867X20976314)**. *The Stata Journal*, 20(4):812–843, 2020.

J. P. Romano and M. Wolf. **[Stepwise Multiple Testing as Formalized Data Snooping](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-0262.2005.00615.x)**. Econometrica, 73(4): 1237–1282, 2005a.

J. P. Romano and M. Wolf. **[Exact and Approximate Stepdown Methods for Multiple Hypothesis Testing](https://www.tandfonline.com/doi/abs/10.1198/016214504000000539)**. Journal of the American Statistical Association, 100(469):94–108, 2005b.

J. P. Romano and M. Wolf. **[Efficient computation of adjusted p-­values for resampling-­based stepdown multiple testing](https://www.sciencedirect.com/science/article/abs/pii/S0167715216000389)**. *Statistics and Probability Letters*, 113:38–40, 2016.
