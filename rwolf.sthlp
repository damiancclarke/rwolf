{smcl}
{* November 25, 2016 @ 17:34:22}{...}
{hline}
help for {hi:rwolf}
{hline}

{title:Title}

{p 8 20 2}
    {hi:rwolf} {hline 2} Calculate Romano-Wolf p-values for stepdown multiple hypothesis testing

{title:Syntax}

{p 8 20 2}
{cmdab:rwolf} {it:{help varnames:depvars}} {ifin} [{it:{help weight}}]{cmd:,} {cmd:indepvar(}{it:varname}{cmd:)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{cmd:indepvar(}{it:varname}{cmd:)}}Indicates the one independent (treatment) variable which is included in multiple hypothesis tests.
{p_end}
{...}
{synopt :{cmd:method({help regress} | {help logit} | {help probit} |...)}}Indicates to Stata how each of the multiple hypothesis tests are performed (ie the baseline models).  Any estimation command permitted by Stata can be included.  See {help regress} for a full list of estimation commands in Stata.
    If not specified, {help regress} is assumed.
{p_end}
{...}
{synopt :{cmd:controls({help varlist})}}Lists all other control variables which are to be included in the model to be tested multiple times.  Any variable format accepted by {help varlist} is permitted including time series and factor variables.
{p_end}
{...}
{synopt :{cmd:seed({help set seed:#})}}Seets seed to indicate the initial value for the pseudo-random number generator.  # can be any integer between 0 and 2^31-1. 
{p_end}
{...}
{synopt :{cmd:reps({help bootstrap:#})}}Perform # bootstrap replication; default is reps(100).  Where possible prefer a larger number of replications for more precise p-values.
{p_end}
{...}
{synopt :{opt other options}}Any additional options which correspond to the baseline regression model.  All options permitted by the indicated method are allowed.
{p_end}
{...}
{synoptline}
{p2colreset}


{title:Description}

{p 6 6 2}
{hi:rwolf} calculates Romano and Wolf's (2005a,b) stepdown adjusted p-values robust to multiple hypothesis testing.  This program follows the algorithm described in Romano and Wolf (2016), and provides a p-value corresponding to each of a series of J independent variables when running testing multiple hypotheses against a single dependent (or treatment) variable.  The {hi:rwolf} algorithm constructs a null distribution for each of the J hypothesis tests based on Studentized bootstrap replications of a subset of the tested variables.  Full details of the process are describe in Romano and Wolf (2016).

{p 6 6 2}
{hi:rwolf} requires multiple independent variables to be tested, a single dependent variable, and (optionally) a series of control variables which should be included in each test.
    {hi:rwolf} works with any {help regress:estimation-based regression command} allowed in Stata, which should be indicated using the {cmd:method} option.
    If not specified, {help:regress} is assumed.  Optionally, regression {help weight}s, {help if} or {help in} can be specified.  By default, 100 {help bootstrap} replications are run for each of the J multiple hypotheses.  Where possible, a larger number of replications should be preferred.
    Replications are set using the {cmd:reps({help bootstrap:#})} option, and to replicate results, the {cmd:seed({help seed:#})} should be set.

{p 6 6 2}
The command returns the Romano Wolf p-value corresponding to each variable, and for reference, the original uncorrected (analytical) p-value from the initial tests.
    {hi:rwolf} is an e-class command, and the Romano Wolf p-value for each variable is returned as a scalar in e(rw_varname).

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Use the auto dataset to run multiple regressions of various dependent variables on a single dependent variable of interest (price) controlling for foriegn.  {break}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. rwolf var1 var2 var3 var4, indepvar(price) controls()}{p_end}

    {hline}

{pstd}Run the same analysis, however using areg to absorb a series of fixed effects {break}

{phang2}{cmd:. rwolf var1 var2 var3 var4, indepvar(price) controls() method(areg) abs()}{p_end}

    {hline}

{pstd}Search the National Longitudinal (panel) Survey for significant predictors of log wages{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. genspec ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure 2.race not_smsa south msp nev_mar union, xt(fe) numsearch(2)}{p_end}

    {hline}



{marker results}{...}
{title:Saved results}

{pstd}
{cmd:rwolf} saves the following in {cmd:e()}:

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rw_var1)}}The Romano Wolf p-value associated with variable 1 (var1 will be changed for variable name) {p_end}
{synopt:{cmd:e(rw_varJ)}}The Romano Wolf p-value associated with variable J.  Each of the independent variables will be returned in this way. {p_end}

	

{marker references}{...}
{title:References}

{marker RomanoWolf2005a}{...}
{phang}
Romano J.P. and Wolf M., 2005a.
{it:Exact and Approximate Stepdown Methods for Multiple Hypothesis Testing},
Journal of the American Statistical Association 100(469): 94-108.

{marker RomanoWolf2005b}{...}
{phang}
Romano J.P. and Wolf M., 2005b.
{it: Stepwise Multiple Testing as Formalized Data Snooping},
Econometrica 73(4): 1237-1282.

{marker RomanoWolf2016}{...}
{phang}
Romano J.P. and Wolf M., 2016.
{it: Efficient computation of adjusted p-values for resampling-based stepdown multiple testing},
Statistics and Probability Letters 113: 38-40.
{p_end}


{title:Author}

{pstd}
Damian Clarke, Department of Economics, Universidad de Santiago de Chile. {browse "mailto:damian.clarke@usach.cl":damian.clarke@usach.cl}
{p_end}
