function [outResultTable, outDVNames] = CondMedians(inTrials,sDVs,CondSpecs,varargin)
%
% Include/Exclude options passed through to SubTableIndices.

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@median,varargin{:});

end
