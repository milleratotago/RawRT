% This demo illustrates a number of miscellaneous functions:
%   * CondSummaryScores
%   * Condttest
%   * Condttest2
%   * Condsignrank
%   * Condranksum

%% CondSummaryScores Demo.

Trials = DemoData('DemoCondSummaryScores');
% Illustrative experiment recording firing rates of single cells;
% see description in DemoData.m.

% Do paired t-tests to see whether the stimulus influenced the firing rate of each cell:
PairedTs = Condttest(Trials,'Baseline','Stim',{'Bird','Cell'});

% Is it better to use an unpaired t-test?
UnpairedTs = Condttest2(Trials,'inTable.Baseline','inTable.Stim',{'Bird','Cell'});

[mean(PairedTs.p<.05) mean(UnpairedTs.p<.05)]

% Note that there could be more significant results with the unpaired test.
% Using the average baseline has higher power _when the baseline & stimulus firing
% rates are negatively correlated within cells_, which they are not here.
Corrs = CondCorrs(Trials,'Baseline','Stim',{'Bird','Cell'});
mean(Corrs.r)

% Also check some nonparametric tests:
% Is it better to use a Wilcoxon nonparametric test?
WilcoxRS = Condranksum(Trials,'inTable.Baseline','inTable.Stim',{'Bird','Cell'});
WilcoxSR = Condsignrank(Trials,'Baseline','Stim',{'Bird','Cell'});

