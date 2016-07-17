function [outResultTable, outDVNames] = CondTotal(inTrials,sDVs,CondSpecs,varargin)
%
% Include/Exclude options passed through to SubTableIndices.

[sDVs, NDVs] = EnsureCell(sDVs);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@sum,varargin{:});

end
