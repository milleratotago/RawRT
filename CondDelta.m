function [DVBinMeans, BinDiffsAvgs, DeltaVsMean, DeltaVsMeanNames, BinAssignments] ...
 = CondDelta(Trials,sRT,sDV,CondSpecs,sDiffSpec,LevelNums,NBins,PolyDegree,varargin)
% Delta plot analysis to see how the size of a condition effect changes depending on the size of the RT.
% Throughout this function, "RT" refers to the variable that is used to assign trials to bins,
%   and DV refers to the variable used to index the size of the effect.  Often these are the same, but as
%   an example where they are different, one could bin trials according to RT & then measure effect size on PC.
%
% Required arguments (see DemoBin for an example):
%   Trials: data table
%   sRT : name of the RT variable used to assign trials to bins
%   sDV : name of the dependent variable used to measure the condition effect (usually RT or Cor)
%   CondSpecs: Label(s) defining the conditions to be kept separate during computation.
%              For example, one CondSpec would be 'SubNo' if the computations were to be done separately for each subject.
%   sDiffSpec: String defining the condition for which the effect is to be computed
%              (i.e., the effect that might change depending on the size of the RT).
%   LevelNums: An array of 2 integers indicating the values of sDiffSpec that are to be compared in determining the effect.
%              That is, the effect being examined is the difference: sDiffSpec(LevelNums(2)) - sDiffSpec(LevelNums(1))
%   NBins: The number of bins to use in dividing up RT values.
%   PolyDegree: The degree of the polynomial to use when predicting effect size from RT.
% Optional arguments:
%   Include/Exclude: passed through to CondBinLabels and CondMeans
%   Jitter: passed through to CondBinLabels
%
% Outputs:
%   DVBinMeans  : A table of the mean values of the DV, separately for each combination of CondSpecs, sDiffSpec, & Bin.
%   BinDiffsAvgs: A combined table of the mean values of the DV & the condition effect (difference) for each value of CondSpec.
%   DeltaVsMean: A table for each CondSpec of the intercept, slope(s), p, Rsqr & RMSE of the PolyDegree fit of the effect size against the bin mean.
%   DeltaVsMeanNames: The names of the variables in DeltaVsMean.
%   BinAssignments: A trial-by-trial list indicating the bin assignment of each trial.

% Here is the procedure:
%
% 1. For each combination of CondSpecs X sDiffSpec, divide the trials
%    into NBins bins based on the value of sRT (sRT is a single RT).
%
% 2. Compute the means on sDV within each CondSpecs X sDiffSpec x Bin.
%
% 3. For each combination of CondSpecs x Bin, compute
%    the average and difference of indicated levels of sDiffSpec.
%    LevelNums(1) should be the condition with the smaller mean RT.
%
% 4. For each combination of CondSpecs, fit a polynomial of degree PolyDegree
%    to predict the Bin's difference from the Bin's mean.
%

assert(NBins>PolyDegree,'The number of bins must exceed the polynomial degree.');
if NBins<=PolyDegree+1
    warning('Cannot test regression hypotheses because DFE==0; increase NBins or decrease PolyDegree for Ho testing.');
end

sTempName = UniqueVarname(Trials,'Bin');

% Label the bin for each trial, separately for each subject, congruence, & n of targets:
BinAssignments = CondBinLabels(Trials,sRT,[CondSpecs {sDiffSpec}],NBins,varargin{:});
Trials.(sTempName) = BinAssignments;

% Compute the mean for each combination of CondSpecs, sDiffSpec, and Bin for both sorting variable (RT) & dependent variable (DV)
[RTBinMeans, RTBinMeanNames] = CondMeans(Trials,sRT,[CondSpecs {sDiffSpec} {sTempName}],varargin{:});
[DVBinMeans, DVBinMeanNames] = CondMeans(Trials,sDV,[CondSpecs {sDiffSpec} {sTempName}],varargin{:});

AvgWeights = zeros(1,numel(unique(RTBinMeans.(sDiffSpec))));
AvgWeights(LevelNums) = 0.5;
[RTBinAvgs, RTBinAvgsNames] = CondWeightedSum(RTBinMeans,RTBinMeanNames,[CondSpecs {sTempName}],sDiffSpec,AvgWeights);
sAvgsName = UniqueVarname(RTBinAvgs,[sRT 'Mn']);
RTBinAvgs.Properties.VariableNames{end} = sAvgsName;

DiffWeights = zeros(size(AvgWeights));
DiffWeights(LevelNums(1)) = -1;
DiffWeights(LevelNums(2)) = 1;
[DVBinDiffs, DVBinDiffsNames] = CondWeightedSum(DVBinMeans,DVBinMeanNames,[CondSpecs {sTempName}],sDiffSpec,DiffWeights);

% Assemble averages and differences into a single table
BinDiffsAvgs = RTBinAvgs;
sDiffsName = UniqueVarname(BinDiffsAvgs,[sDV 'Diff']);
BinDiffsAvgs.(sDiffsName) = DVBinDiffs.(DVBinDiffsNames{1});
BinDiffsAvgs.([sRT 'Mn1']) = RTBinMeans.(sRT)(RTBinMeans.(sDiffSpec)==LevelNums(1));
BinDiffsAvgs.([sRT 'Mn2']) = RTBinMeans.(sRT)(RTBinMeans.(sDiffSpec)==LevelNums(2));
if ~strcmp(sRT,sDV)
    BinDiffsAvgs.([sDV 'Mn1']) = DVBinMeans.(sDV)(DVBinMeans.(sDiffSpec)==LevelNums(1));
    BinDiffsAvgs.([sDV 'Mn2']) = DVBinMeans.(sDV)(DVBinMeans.(sDiffSpec)==LevelNums(2));
end

[DeltaVsMean, DeltaVsMeanNames] = CondRegr(BinDiffsAvgs,sAvgsName,sDiffsName,CondSpecs,PolyDegree);

end
