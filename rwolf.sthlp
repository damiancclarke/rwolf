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
{hi:rwolf} is 

{p 6 6 2}
Paragraph 2.

{p 6 6 2}
Paragraph 3.


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Search the auto dataset for the significant predictors of car price{break}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. genspec price mpg rep78 headroom trunk weight length foreign turn displace}{p_end}

    {hline}

{pstd}Search the auto dataset for the significant predictors of car price at 70th quantile of price {break}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. genspec price mpg rep78 headroom trunk weight length foreign turn displace, qreg quantile(70)}{p_end}

    {hline}

{pstd}Search the National Longitudinal (panel) Survey for significant predictors of log wages{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. genspec ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure 2.race not_smsa south msp nev_mar union, xt(fe) numsearch(2)}{p_end}

    {hline}

{pstd}Predict variables for Hoover and Perez (1999)'s time-series model 5{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse set http://users.ox.ac.uk/~ball3491/}{p_end}
{phang2}{cmd:. webuse gets_data}{p_end}
{phang2}{cmd:. qui ds y* u* time, not}{p_end}
{phang2}{cmd:. local xvars `r(varlist)'}{p_end}
{phang2}{cmd:. local lags l.dcoinc l.gd l.ggeq l.ggfeq l.ggfr l.gnpq l.gydq l.gpiq l.fmrra l.fmbase l.fm1dq l.fm2dq l.fsdj l.fyaaac l.lhc l.lhur l.mu l.mo}{p_end}

{phang2}{cmd:. genspec y5 `xvars' `lags' l.y5 l2.y5 l3.y5 l4.y5, ts}{p_end}

    {hline}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:genspec} saves the following in {cmd:e()}:

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(fit)}}Bayesian Information Criterion of final specification {p_end}

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}List of variables from the final specification {p_end}
	

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
