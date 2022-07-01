% This demo illustrates a number of miscellaneous functions:
%   * CondSummaryScores
%   * Condttest
%   * Condttest2
%   * Condsignrank
%   * Condranksum
%   * CondMedianBTS
%   * CondMeansTrimmed
%   * CondCenMoment
%   * CondDistToBox

%% CondSummaryScores Demo.

Trials = DemoData('DemoCondSummaryScores');
% Illustrative experiment recording firing rates of single cells;
% see description in DemoData.m.

% Bootstrap-correct medians
nBoot = 10;
MdnBTS = CondMediansBTS(Trials,'Stim',{'Bird','Cell'},nBoot);

% Trimmed means
TrimPct = 20;  % Trim 10% from each end and compute mean of remaining 80%.
MeansTrimmed = CondMeansTrimmed(Trials,'Stim',{'Bird','Cell'},TrimPct);

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

% CondCenMoment
NMoment = 3;
[CenMomTbl, CenMomNames, CenMom3] = CondCenMoment(Trials,'Stim',{'Bird'},NMoment);

% CondDistToBox
Trials.DistToBox = CondDistToBox(Trials,'Stim',{'Bird'});
DVs = Trials.Stim(Trials.Bird==1);
[a, b, c] = BoxplotCalcs(DVs);

