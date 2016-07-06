function [outResultTable, outDVNames] = CondHistcounts(inTrials,sDVs,CondSpecs,Edges,varargin)
% Make a table of histogram counts for the bins defined by edges.

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@histcounts,varargin{:},'NPassThru',3,Edges,'Normalization','probability');

end

