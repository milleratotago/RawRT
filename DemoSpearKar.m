% The goals of this demo are to illustrate how to:
%   * perform Spearman-Kaerber analysis for a single psychometric function data set.
%   * perform separate Spearman-Kaerber analyses for psychometric function obtained in many subjects/conditions.
%   * perform ANOVA on the results of many Spearman-Kaerber analyses.
% The demo is based on the ideas that:
%  there are a number of different stimulus values
%  there are 2 responses, 1 and 2, and the likelihood of response 2 increases with the stimulus value.


%% This section shows how to analyze a single psychometric function.

stim = [300 350 400 450 500 550 600 650 700];  % stimulus values
n1 = [14 11 12 5 3 0 1 0 0];   % number of R1 responses for each stimulus value
n2 = [1 4 2 10 9 15 14 15 14]; % number of R2 responses for each stimulus value

% The following command computes the SK estimates of PSE, sigma, and DL:
[PSE_SK, Sigma_SK, DL_SK, ~, ~, ~, ~] = SpearKar(stim,n1,n2)

% The following command computes the SK estimates of PSE, sigma, and DL and also produces a plot of the results
% (f1 is the handle of the plot):
[PSE_SK, Sigma_SK, DL_SK, ~, ~, ~, f1] = SpearKar(stim,n1,n2,'Plot')


% The following command computes the SK estimates of PSE, sigma, and DL and also produces bootstrap-based
% estimates of the mean, standard error, and CIs of these values, based on 1235 bootstrap samples.
[PSE_SK, Sigma_SK, DL_SK, BootstrapMeans, BootstrapSEMs, BootstrapCIs, ~] = SpearKar(stim,n1,n2,'Bootstrap',1235)
% You could also add the option 'Plot' to make a plot.



%% The remaining sections of this demo illustrate how to perform Spearman-Kaerber analyses for
%  many subjects and/or conditions, with data in RawRT's standard "trials table" format.

% First, generate some simulated data to use for the demonstration:
% Look at the trials table to get a good idea of the data format.
% For each trial, "Stim" holds the stimulus value and "Resp" holds the 1/2 response.
Trials = DemoData('DemoSpearKar');

%% Compute PSE_SK, Sigma_SK, DL_SK for each subject separately,
% pooling across blocks, and then run ANOVA on these 3 DVs:
SubCondSK = CondSpearKar(Trials,'Stim','Resp',{'SubNo','Cond'},'Plot');
BetweenFacs = {};  % None in this experiment.
WithinFacs = {'Cond'};
OutFileName = 'SubCondSK';
CallMrf(SubCondSK,{'PSE_SK','Sigma_SK', 'DL_SK'},BetweenFacs,WithinFacs,'SubNo',OutFileName);


%% Compute the same SK values, but also compute bootstrap 500 times to compute SE's, etc.
SubCondSKboot = CondSpearKar(Trials,'Stim','Resp',{'SubNo','Cond'},'Bootstrap',500);
% Sorry for this awkward "NPassThru" notation, which is explained in the header of CondSpearKar.m
% Look at the output table; I hope it is clear what everything is.
% If you prefer to have each bootstrap value in its own column, set up the new
% columns with commands like this:
SubCondSKboot.PSE_SK_Mean = SubCondSKboot.BootstrapMeans(:,1);
SubCondSKboot.Sigma_SK_Mean = SubCondSKboot.BootstrapMeans(:,2);
SubCondSKboot.DL_SK_Mean = SubCondSKboot.BootstrapMeans(:,3);

