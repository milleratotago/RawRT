% This demo illustrates functions that might be used when there are two
% (possibly related) measurements on each trial.  Specifically,
%   * Compute a paired t-test between two conditions, separately for each condition.
%   * Compute the correlation between two DVs, separately for each condition.
%   * Compute a regression (linear or quadratic) to predict one DV from another DV, separately for each condition.
%   * Fit a linear model to predict one DV from one or more other DVs, separately for each condition.

%% Generate some simulated data for a demonstration.
Trials = DemoData('DemoPaired');

% Note that the outputs of all functions are quite complex--even models.

PairedTs = Condttest(Trials,'RT1','RT2',{'SubNo','Trty'});
WilcoxSR = Condsignrank(Trials,'RT1','RT2',{'SubNo','Trty'});

Corrs = CondCorrs(Trials,'RT1','RT2',{'SubNo','Trty'});  % default Pearson corrs

CorrSpearm = CondCorrs(Trials,'RT1','RT2',{'SubNo','Trty'},'Parms',{'Type','Spearman'});  % Spearman rank-order corrs

RegrLinear = CondRegr(Trials,'RT1','RT2',{'SubNo','Trty'},1);  % 1 indicates simple linear
% The Corrs table contains various summaries of the linear regression predicting RT2 from RT1.

RegrQuadratic = CondRegr(Trials,'RT1','RT2',{'SubNo','Trty'},2);  % 2 indicates quadratic
% Slope2 is the multiplier of the quadratic term

sModel = 'RT3 ~ RT1 + RT2';
RegrLinearViaFit = CondFitlm(Trials,sModel,{'SubNo','Trty'});

