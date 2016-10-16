% The goals of this demo are to illustrate how to:
%   * label trials according to whether the RT is in the fastest bin, 2nd fastest, etc
%   * compute & analyze conditional accuracy functions
%   * compute & analyze "delta plots"

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.

Trials = DemoData('DemoBin');

Trials.RTOK = true(height(Trials),1);  % Mark the trials as all OK for the analysis (this demo ignores the possibility of outliers).

%% Conditional Accuracy Function Analysis
% Assign each trial to a bin based on its RT.
% Include both correct and error trials since we will be tabulating PC in each bin.

NBins = 5;

% Note: If DVs are rounded to the nearest msec, then before assigning trials to bins, you may
% want to add some random jitter to the RTs to avoid ties, and keep the bin sizes equal.
% This can be done by including the optional parameter pair: 'Jitter',0.1
%   Jitter says to add a random number to each RT, and 0.1 says to keep the
%   random number in the range of 0 to +0.1.
% The present simulated RTs are not rounded so I won't use that here.
[Trials.CAFBinNum, BinTops] = CondBinLabels(Trials,'RT',{'SubNo','Cond'},NBins,'Include',Trials.RTOK);

% Trials now has an extra column for CAFBinNum with values of 1-5.
% Note that CAFBinNum was set to NaN for trials with ~RTOK, because they were excluded.
% BinTops holds the maximum values for each bin (in case you want them).

%% Check a few values to see what was done:

SubToCheck = 5;   % Pick any subject number
CondToCheck = 1;  % Pick the condition to check (1 or 2).
BinToCheck = 3;   % Pick any bin 1-4; it will be compared against the next larger bin.

% Whichever subject, condition, & bin you selected, you can see from the following values that the
% bins don't overlap;
disp('Here is the maximum in the bin you selected:')
max(Trials.RT(Trials.RTOK&Trials.SubNo==SubToCheck&Trials.Cond==CondToCheck&Trials.CAFBinNum==BinToCheck))
disp('Here is the minimum in the next larger bin, which should be a little bigger:')
min(Trials.RT(Trials.RTOK&Trials.SubNo==SubToCheck&Trials.Cond==CondToCheck&Trials.CAFBinNum==BinToCheck+1))
disp('Here are all of the RTs in the bin you selected (sorted):')
sort(Trials.RT(Trials.RTOK&Trials.SubNo==SubToCheck&Trials.Cond==CondToCheck&Trials.CAFBinNum==BinToCheck))'
disp('Here are all of the RTs in the next larger bin (sorted):')
sort(Trials.RT(Trials.RTOK&Trials.SubNo==SubToCheck&Trials.Cond==CondToCheck&Trials.CAFBinNum==BinToCheck+1))'


% Here are frequency distributions that allow you to compare the RTs in the different bins, pooling across Ss:
CondFreqDist(Trials,'RT',{'CAFBinNum','Cond'},'Include',Trials.RTOK);
% Notes:
%  o The X ranges vary across panels of the graph, because MATLAB chooses the ranges separately for each.
%  o The bins of these distributions do overlap; this happens because the bin boundaries are at
%    different points for different Ss, even though the bins don't overlap for any subject/condition.


%% Conditional accuracy functions:

% Here is a plot of the mean accuracy for each bin, by condition:
CondPlot(Trials,'Cor',{'CAFBinNum','Cond'},'Include',Trials.RTOK);

% Here is a plot of the mean accuracy for each bin against the mean RT for
% that bin.  CondPlot uses some tricks when multiple DVs are specified!
CondPlot(Trials,{'RT','Cor'},{'CAFBinNum','Cond'},'Include',Trials.RTOK);

% Here is a table with the PC and mean RT combination of subject, condition, and bin:
CAFTable = CondMeans(Trials,{'Cor','RT'},{'SubNo','Cond','CAFBinNum'},'Include',Trials.RTOK);



%% Delta plot analysis, to see at whether/how the condition 1 versus 2 effect changes across RT bins.

% One type of delta plot analysis is completely automated and carried out by the function CondDelta.
% That function also does the RT binning, so the CAFBinNum values used above are not needed here.
% Check that function for more documentation, but here is an example of its use.

NBins = 4;       % Use 4 bins.
PolyDegree = 2;  % Fit effect size versus mean RT as a 2nd order polynomial.
CompareLevels = [1 2]; % Measure condition effect as condition 2 minus condition 1.

[RTBinMeans, RTBinDiffsAvgs, RTDeltaVsMean, RTDeltaVsMeanNames, BinAssignments] = ...
 CondDelta(Trials,'RT','RT','SubNo','Cond',CompareLevels,NBins,PolyDegree,'Include',Trials.RTOK);

% The outputs of CondDelta can be used in many ways.  Here are some examples:

% Plot the bin's condition effect on the vertical axis against the bin's mean RT on the horizontal:
CondPlot(RTBinDiffsAvgs,{'BinAvgs','BinDiffs'},'Bin');

% Do an ANOVA to see whether the Cond effect changes significantly across bins:
CallMrf(RTBinMeans,'RT',{},{'Bin','Cond'},'SubNo','DemoBinDPRT1');

% Means of the intercept, linear slope, and quadratic terms.
mean(RTDeltaVsMean.Intercept)
mean(RTDeltaVsMean.Slope1)
mean(RTDeltaVsMean.Slope2)

% 1-sample t-test of whether the average slope is zero:
[sig, p, ci, stats]=ttest(RTDeltaVsMean.Slope1)
 
% 1-sample t-test of whether the average multiplier of the quadratic term is zero:
[sig2, p2, ci2, stats2]=ttest(RTDeltaVsMean.Slope2)


% Here is the start of a comparable analysis of the condition effects on PC for each bin.
% Note that the first variable ('RT') is used to define bins, and the second variable ('Cor')
% is used to compute the effect
[PCBinMeans, PCBinDiffsAvgs, PCDeltaVsMean, PCDeltaVsMeanNames, ~] = ...
 CondDelta(Trials,'RT','Cor','SubNo','Cond',CompareLevels,NBins,PolyDegree,'Include',Trials.RTOK);
CallMrf(PCBinMeans,'Cor',{},{'Bin','Cond'},'SubNo','DemoBinDPPC1');


