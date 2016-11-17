% function DemoMassage(varargin)
% The goals of this demo are to illustrate how to make new variables to classify trials
% in various additional ways not illustrated in other demos. In particular:
%   * compute each trial's Z-score relative to other trials in the same condition
%   * compute each trial's rank relative to other trials in the same condition
%   * randomly or systematically split up the trials within a condition into several new sub-conditions
%   * randomly permute the trials within a condition

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.

Trials = DemoData('Demo0');

Trials.RTOK = true(height(Trials),1);  % Mark the trials as all OK for the analysis (this demo ignores the possibility of outliers).


%% Compute the Z score of each trial relative to the other trials from the same subject and condition.
Trials.ZofRT = CondZs(Trials,'RT',{'SubNo','Cond'});
% You might use these Z scores, for example, to reject trials with extreme Z scores as outliers:
Trials.ZOK = (Trials.ZofRT > -2) & (Trials.ZofRT < 2);

ZDescribe = CondDescribe(Trials,'ZofRT',{'SubNo','Cond'})


%% Compute the rank of each trial relative to the other trials from the same subject and condition.
Trials.RankofRT = CondRanks(Trials,'RT',{'SubNo','Cond'});
% You might use these ranks, for example, in a non-parametric analysis.

RankDescribe = CondDescribe(Trials,'RankofRT',{'SubNo','Cond'})


%% Compute the rank of each trial relative to the other trials from the same subject and condition as a proportion 0-1.
Trials.RankPropofRT = CondRankProp(Trials,'RT',{'SubNo','Cond'});
% You might use these RankProp, for example, to exclude trials in the top and bottom 10%.

RankPropDescribe = CondDescribe(Trials,'RankPropofRT',{'SubNo','Cond'})


%% Split the trials from the same subject and condition into subgroups.
NSubgroups = 3;
Randomize = true;
Trials.Subgroup = CondSplitter(Trials,{'SubNo','Cond'},NSubgroups,Randomize);
SubgroupDescribe = CondDescribe(Trials,'RT',{'SubNo','Cond','Subgroup'})
% You might compare different random subgroups in a simulation checking the
% Type I error rate of some procedure, for example.

% Alternatively, you might do an odd/even split for a reliability analysis.
NSubgroups = 2;
Randomize = false;
Trials.OddEven = CondSplitter(Trials,{'SubNo','Cond'},NSubgroups,Randomize);
OddEvenDescribe = CondDescribe(Trials,'RT',{'SubNo','Cond','OddEven'})


%% Permute the RTs for each subject within a condition.
% Could be used for simulations where the order of trials is important,
% e.g., with some type of sequential analysis.
Trials.PermutedRT = CondPermute(Trials,'RT',{'SubNo','Cond'});
OriginalDescribe = CondDescribe(Trials,'RT',{'SubNo','Cond'});
PermuteDescribe = CondDescribe(Trials,'RT',{'SubNo','Cond'});
if isequal(Trials.RT,Trials.PermutedRT)
   disp('ERROR: The original and permuted RTs are the same, but they should NOT be.')
   pause
else
   disp('The original and permuted RTs are different, as they should be.')
end
if isequal(OriginalDescribe,PermuteDescribe)
   disp('The original and permuted tables have the same statistics, as they should.')
else
   disp('ERROR: The original and permuted tables do NOT have the same statistics, but they should.')
   pause
end


% end

