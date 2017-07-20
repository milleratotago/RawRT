function outScores = CondSummaryScores(inTrials,sDV,CondSpecs,Function,varargin)  % NEWJEFF: Not currently demo'ed.
% Produce a list of output scores for all trials in inTrials, where the outScores are computed
% using a specified summary function relative to the other trials in the same CondSpec combination.
% Return NaN for any excluded trials.
%
% Example: Compute a new DV that is the mean of all RTs for a given subject & trial type:
%    Trials.MeanRT = CondSummaryScores(Trials,'RT',{'SubNo','Trty'},@mean,varargin)

% Inputs:
%
%   inTrials  : Table holding the trial-by-trial data for all subjects and conditions
%   sDV       : Name of the variable to which the Function is to be applied when computing new scores.
%   CondSpecs : Other conditions to be kept separate when computing the outScores (e.g., subject, task, etc)
%   Function  : The function of all the scores in each condition that is used to compute the new DV.
%
% varargin options:
%   Include/Exclude options passed through to indicate which trials should be included in
%      computation of mean & sd for Z.  Trials that are _not_ included get Z scores of NaN.
%
% Outputs:
%
%   outScores : List of output values or NaN's.

NinTrials = height(inTrials);
outScores = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

for iCond = 1:NConds
   Indices = mySubTableIndices{iCond};
   ThisScore = Function(inTrials.(sDV)(Indices));
   outScores(Indices) = ThisScore;
end

end
