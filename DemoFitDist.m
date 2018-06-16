% The goals of this demo are to illustrate how to fit the observations in each condition
% to a pre-specified probability distribution. The probability distributions are defined
% in the separate software package Cupid available at https://github.com/milleratotago/Cupid
% and you must have the Cupid *.m files on your MATLAB path for this demo to work.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.
Trials = DemoData('DemoFitDist');
Trials.RTOK = true(height(Trials),1);  % Mark the trials as all OK for the analysis (this demo ignores the possibility of outliers).

% The following show some haphazard examples of fitting
% different probability distributions (e.g., ExGauMn, RNGamma)
% and using different fitting methods (e.g., maximum likelihood or MLE, moments).
% The different distributions and fitting options are listed in the
% documentation that comes with Cupid.

% The distribution parameters specified in each Dist1 are the starting parameters
% for the fit of that distribution in each of the different conditions (here, SubNo x Cond).
% These starting parameters must be reasonably good guesses or the fitting routines may get
% trapped in local minima.  If you are not sure what starting parameters to use,
% you will need to work with the desired distribution to find some parameters
% that are in the right ball-park for your data (see Cupid documentation).

fprintf('Estimating ex-Gaussian parameters by MLE...');
Dist1 = ExGauMn(200,20,100);
ExGaussFitMLE = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1);
fprintf('\n');

fprintf('Estimating RNGamma parameters by method of moments...');
Dist1 = RNGamma(100,.1);
RNGammaFitMom = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Moments');
fprintf('\n');

fprintf('Estimating Normal parameters by method of percentiles...');
Dist1 = Normal(500,50);
NormalFitPrctiles = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Percentiles');
fprintf('\n');

fprintf('Estimating Weibull parameters by minimium ChiSquare with 5 bins...');
Dist1 = Weibull(200,3,100);
WeibullFitChiSq = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','ChiSquareBins','NChiSqBins',5);
fprintf('\n');

% Fitting this distribution is quite a lot slower, so only fit for one subject:
fprintf('Estimating ExWald parameters by method of percentiles (this is slow)...');
Dist1 = ExWaldMSM(200,20,100);
ExWaldFitPctiles = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Percentiles','Include',Trials.SubNo==1);
fprintf('\n');
% Note: If you need different starting parameters for different subjects and/or conditions, you must
% call CondFitDist separately for each condition, with the appropriate Dist1 parameters for each one.
% Just use the 'Include' option as in this example to select out the right data to fit with each
% set of starting parameters.

%% You can use a separate function to adjust the starting parameter values for each fit.
fprintf('Estimating ex-Gaussian parameters by MLE with adjusted starting parameter values...');
Dist1 = ExGauMn(200,20,100);
ExGaussFitMLE = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'StartParms',@LC2008EGStartParms);
fprintf('\n');


% Additional tips:
% For each combination of conditions, CondFitDist calls a parameter estimation routine in Cupid,
% and that routine in turn calls MATLAB's fminsearch. This is important to know because fminsearch
% accepts various optional control values, and you may want to change these control values
% depending on your particular application.  You can set new control values like this:
%   Dist1 = Weibull(200,3,100);
%   Dist1.SearchOptions.MaxFunEvals = 500;
% This works because Dist1.SearchOptions is a set of control values initialized by MATLAB's optimset
% function, and you can change these default values to anything you want.  Cupid distributions
% pass their control value settings (e.g., Dist1.SearchOptions) to fminsearch when they call it.
