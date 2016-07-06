function [outResultTable, outDVNames] = CondDescribe(inTrials,sDVs,CondSpecs,varargin)
% Make a table describing each condition in terms of its N, mean, sd, median, min, max
%
% Include/Exclude options passed through to SubTableIndices.

[outResultTable1, outDVNames1] = CondNs(inTrials,CondSpecs,varargin{:});
[outResultTable2, outDVNames2] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,{@mean @std @median @min @max},varargin{:});

outResultTable = join(outResultTable1,outResultTable2);
outDVNames = [outDVNames1 outDVNames2];

end
