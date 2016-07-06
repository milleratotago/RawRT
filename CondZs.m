function outZs = CondZs(inTrials,sDV,CondSpecs,varargin)
% Produce a list of Z scores for all trials in inTrials, where the Z scores
%  are computed relative to the other trials in the same CondSpec combination.
%  Return NaN for any excluded trials.

% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable for which Z scores are to be computed
%   CondSpecs : Other conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
%
% varargin options:
%   Include/Exclude options passed through to indicate which trials should be included in
%      computation of mean & sd for Z.  Trials that are _not_ included get Z scores of NaN.
%
% Outputs:
%
%   outZs : List of Z values or NaN's.

NinTrials = height(inTrials);
outZs = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

for iCond = 1:NConds
   Indices = mySubTableIndices{iCond};
   ThisMean = mean(inTrials.(sDV)(Indices));
   ThisSD   = std(inTrials.(sDV)(Indices));
   ThisZ = (inTrials.(sDV)(Indices) - ThisMean) / ThisSD;
   outZs(Indices) = ThisZ;
end

end
