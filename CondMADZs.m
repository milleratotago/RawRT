function outMADZs = CondMADZs(inTrials,sDV,CondSpecs,varargin)  % NEWJEFF: No demo of this or CondMAD
% Produce a list of Z-score-like quantities for all trials in inTrials, where the MADZ scores
%  are computed relative to the other trials in the same CondSpec combination.
% Each trial's MADZ score is its distance from the median in MAD units.
% For example, a MADZ score of -2 indicates that the score was below the median
%  by exactly 2*(median of the absolute deviations of all scores from median).
% Return NaN for any excluded trials.

% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable for which Z scores are to be computed
%   CondSpecs : Other conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
%
% varargin options:
%   Include/Exclude options passed through to indicate which trials should be included in
%      computation of MADZ.  Trials that are _not_ included get MADZ scores of NaN.
%
% Outputs:
%
%   outMADZs : List of MADZ values or NaN's.

NinTrials = height(inTrials);
outMADZs = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

for iCond = 1:NConds
   Indices = mySubTableIndices{iCond};
%   ThisMedian = median(inTrials.(sDV)(Indices));
%   ThisMAD   = mad(inTrials.(sDV)(Indices),1);  % 1 tells MATLAB's mad function to compute median of absolute deviations; 0 would request mean.
%   ThisZ = (inTrials.(sDV)(Indices) - ThisMedian) / ThisMAD;
%   outMADZs(Indices) = ThisZ;
   outMADZs(Indices) = MADZs( inTrials.(sDV)(Indices) );;
end

end
