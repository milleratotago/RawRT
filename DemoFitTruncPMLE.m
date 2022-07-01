% The goals of this demo are to illustrate how to fit the observations in each condition
% to a pre-specified probability distribution when a certain proportion of observations have been excluded
% (i.e., observations outside certain probability bounds are excluded). The probability distributions are defined
% in the separate software package Cupid available at https://github.com/milleratotago/Cupid
% and you must have the Cupid *.m files on your MATLAB path for this demo to work.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.
Trials = DemoData('DemoFitDist');
                     
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

% Choose arbitrary lower & upper bounds for illustration
% (these are not realistic bounds but they work for these data):
TruncProps = [0.05 0.05];  % for some reason we want to drop the top and bottom 5% of the trials

% Define the distribution that we want to fit:
Dist1 = ExGauMn(300,20,100);

% Adjust some options for fminsearch:
Dist1.SearchOptions.MaxFunEvals = 30000;
Dist1.SearchOptions.MaxIter = 30000;
Dist1.SearchOptions.TolFun = 1.0e-03; 
Dist1.SearchOptions.TolX = 1.0e-03; 

fprintf('Estimating ex-Gaussian parameters by MLE for truncated data...');
tic
ExGaussFitMLE = CondFitDistTruncPMLE(Trials,'RT',{'SubNo' 'Cond'},Dist1,TruncProps);
fprintf('\n');
toc

return

%% Derive predicted values:

% The table ExGaussFitMLE now has the ML parameter estimates for each subject/condition,
% based on the censored data.
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

