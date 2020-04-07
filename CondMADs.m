function [outResultTable, outDVNames] = CondMADs(inTrials,sDVs,CondSpecs,varargin)
%
% Compute median absolute deviation from median for each condition.
% Include/Exclude options passed through to SubTableIndices.

Fun = @(x) mad(x,1);  % 1 tells MATLAB's mad function to compute median of absolute deviations; 0 would request mean.
[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,Fun,varargin{:});

end
