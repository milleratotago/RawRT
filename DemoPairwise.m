% This demo illustrates how to make pairwise comparisons among 3+ levels of a single factor using a series of t-tests.

%% Generate some simulated data for a demo with a between-Ss factor.
TrialsBet = DemoData('DemoGroups','Replicate');
ResultsBetween = Pairwise(TrialsBet,'RT','Group','SubNo');

%% Generate some simulated data for a demo with a within-Ss factor.
TrialsWit = DemoData('Demo0','Replicate');
ResultsWithin = Pairwise(TrialsWit,'RT','Cond','SubNo');
