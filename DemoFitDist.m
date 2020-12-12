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

%% Example 1:

fprintf('Estimating ex-Gaussian parameters by MLE...');
Dist1 = ExGauMn(200,20,100);
tic
ExGaussFitMLE = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1);
fprintf('\n');
toc

% With this example, fminsearch probably complains:
%    Exiting: Maximum number of function evaluations has been exceeded
% and it recommends that you increase MaxFunEvals.
% Example 2 shows how to do that (and to change other search options too).

%% Example 2: Redo example 1 with revised search options.

fprintf('Estimating ex-Gaussian parameters again with revised search options...');

% Each Cupid distribution object (e.g., Dist1) has its own set of
% fminsearch search options, set by default to fminsearch's defaults.
% One way to revise these is to create a new set of search options,
% change any defaults you want, and assign it.  For example,
% here is a new set of search options:
mySearchOptions = optimset;  % Generate the default set.
mySearchOptions.MaxFunEvals = 30000;  % Change several options.
mySearchOptions.MaxIter = 30000;
mySearchOptions.TolFun = 1.0e-03; 
mySearchOptions.TolX = 1.0e-03; 

Dist1.SearchOptions = mySearchOptions;  % Change Dist1's default options to your preferred set.

% Instead, you could just change the options directly, with commands like this:
%   Dist1.SearchOptions.MaxIter = 30000;
% but I will re-use mySearchOptions throughout this demo file.

% Rerunning the search with these new option will be faster (due to looser tolerances),
% and fminsearch will not complain that it fails to converge.
tic
ExGaussFitMLE = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1);
fprintf('\n');
toc

%% Derive predicted values:

% The table ExGaussFitMLE now has the ML parameter estimates for each subject/condition.
% You can now get predicted values based on these estimates as shown in the following
% example where the predicted mean and SD are computed:

% Make new table variables to hold the predicted values:
ExGaussFitMLE.PredictedMean = nan(height(ExGaussFitMLE),1);
ExGaussFitMLE.PredictedSD = nan(height(ExGaussFitMLE),1);

% For each subject/condition combination, make a predicted distribution
% with the fitted parameter values & compute its mean and SD:
for iRow=1:height(ExGaussFitMLE)
    onemu = ExGaussFitMLE.mu(iRow);
    onesigma = ExGaussFitMLE.sigma(iRow);
    oneexmean = ExGaussFitMLE.exmean(iRow);
    oneDist = ExGauMn(onemu,onesigma,oneexmean);  % ExGauMn is of course the same as the distribution that we fit.
    ExGaussFitMLE.PredictedMean(iRow) = oneDist.Mean;
    ExGaussFitMLE.PredictedSD(iRow) = oneDist.SD;
end


%% Example 3:

fprintf('Estimating RNGamma parameters by method of moments...');
Dist1 = RNGamma(100,.1);
Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.
RNGammaFitMom = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Moments');
fprintf('\n');

%% Example 4:

fprintf('Estimating Normal parameters by method of percentiles...');
Dist1 = Normal(500,50);
Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.
NormalFitPrctiles = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Percentiles','Pctiles',.1:.2:.9);
fprintf('\n');

%% Example 5:

fprintf('Estimating Weibull parameters by minimium ChiSquare with 5 bins...');
Dist1 = Weibull(200,3,100);
Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.
WeibullFitChiSq = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','ChiSquareBins','NChiSqBins',5);
fprintf('\n');

%% Example 6:

% Fitting this distribution is quite a lot slower, so only fit for one subject:
tic
fprintf('Estimating ExWald parameters by method of percentiles (this is slow)...');
Dist1 = ExWaldMSM(200,20,100);
Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.
ExWaldFitPctiles = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'Method','Percentiles','Pctiles',.1:.2:.9,'Include',Trials.SubNo==1);
fprintf('\n');
toc

%% Example 7: Multiple searches with different starting points for each search

% Note: If you need different starting parameters for different subjects and/or conditions, you might want
% to call CondFitDist separately for each condition, with the appropriate Dist1 parameters for each one.
% Just use the 'Include' option as in this example to select out the right data to fit with each
% set of starting parameters.  Alternatively, you can use a separate function to compute the starting
% values for each fit, as is illustrated next.

%% You can use a separate function to adjust the starting parameter values for each fit.
fprintf('Estimating ex-Gaussian parameters by MLE with adjusted starting parameter values...');
Dist1 = ExGauMn(200,20,100);
Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.
ExGaussFitMLE = CondFitDist(Trials,'RT',{'SubNo' 'Cond'},Dist1,'StartParms',@LC2008EGStartParms);
fprintf('\n');

%% Example 8: Special-purpose routine for maximum-likelihood fits of ex-Gaussian and ex-Wald RT distributions.
% There is a special routine CondFitEGorEWML designed to fit ex-Gaussian or ex-Wald RT distributions.

% You could use it with either of these two distributions. The demo uses ExGauMn because it is faster.
Dist1 = ExGauMn(200,20,100);        % The starting parameters are never actually used,
% Dist1 = ExWaldMSM(200,20,100);    % so you don't need to pick good ones for your data.

Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.

% CondFitEGorEWML starts fminsearch several times for each data set, as controlled
% by the following parameter (see CondFitEGorEWML.m for further info).
% Of course the final result is determined by whichever fminsearch found the
% parameters with the highest likelihood.
VarianceProportionInEx = .1:.1:.9;  % Start 9 different fminsearch runs with the exponential component
                                    % contributing the corresponding proportion of the total variance

ExGaussFitMLE2 = CondFitEGorEWML(Trials,'RT',{'SubNo' 'Cond'},Dist1,VarianceProportionInEx);

%% Example 9: Specify your own starting values (possibly multiple starting points) for each condition separately.
%  This is effectively the same as Example 8 but uses a more general technique of specifying starting points.
%  With this technique you could compute (multiple) starting points for each data set however you want,
%  which would be especially useful with other distributions than EG or EW.

% You could use it with either of these two distributions. The demo uses ExGauMn because it is faster.
Dist1 = ExGauMn(200,20,100);        % The starting parameters are never actually used,
% Dist1 = ExWaldMSM(200,20,100);    % so you don't need to pick good ones for your data.

Dist1.SearchOptions = mySearchOptions;  % For the same reason as before.

VarianceProportionInEx = .1:.1:.9;  % Start 9 different fminsearch runs with the exponential component
                                    % contributing the corresponding proportion of the total variance

CondSpecs = {'SubNo' 'Cond'};

% The following function computes some plausible starting ex-GauMn parameter values separately for each condition
starting_parms = StartingParmsEGEW(Trials,'RT',CondSpecs,VarianceProportionInEx,'Include',Trials.RTOK);

[outResultTable, outDVNames] = CondFitDist2(Trials,'RT',CondSpecs,Dist1,'StartingParms',starting_parms,'Include',Trials.RTOK)
 
%% The end

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
