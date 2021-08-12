% This demo illustrates functions for meta-analysis:
%   * CondMetaChisq: Combine independent chi-square values to see if their common H0 can be rejected.
%   * CondMetaFisher: Combine independent one-tailed p values to see if their common H0 can be rejected.

%% CondMetaChisq Demo.

% Imagine that each of 20 subjects is tested in 3 conditions.
FNames  = {'SubNo', 'Cond'};
FLevels = [   20       3  ];
Trials = TrialFrame(FNames,FLevels,'SortBy',{'SubNo','Cond'});

% For each subject and condition, we have an observed value of a chi-square test
% with 2 df's (e.g., it might be a chi-square test for contingency).
Trials.df = 2 * ones(height(Trials),1);
Trials.ObsChisq = ChiSq(2).Random(height(Trials),1);
% Arbitrarily increase ObsChisq values in conds 2 & 3 so that
% H0 is false in those conditions for this demo
Trials.ObsChisq = Trials.ObsChisq + 1.5*(Trials.Cond - 1);

% Test whether the combined results across subjects reject the H0 of no contingency.
% Make this test separately for each condition.
outResultTable = CondMetaChisq(Trials,'ObsChisq','df','Cond')
% This table contains total chi-square & df values across the independent tests (different Ss),
% and an attained p value for the overall total chi-square.
% Generally should get significant results in conditions 2 & 3 because of arbitrary increase

%% CondMetaFisher Demo.

% Imagine the same subjects and conditions as before, but now in each case
% we have an observed p value for any statistical test.
Trials.pObs = rand(height(Trials),1) ./ Trials.Cond;  % Reduce p values in Conds 2 & 3 so H0 is false for those.

outResultTable = CondMetaFisher(Trials,'pObs','Cond')
% This table contains the total value of the Fisher test statistic across the independent tests (different Ss),
% the total df for the overall test, and an attained p value for the overall test.
% Generally should get significant results in conditions 2 & 3 because their p values were divided by the Cond number.
