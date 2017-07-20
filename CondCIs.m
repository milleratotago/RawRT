function [outResultTable, outDVNames] = CondCIs(inTable,sDVs,CondSpecs,varargin)  % NEWJEFF: IN PROGRESS--add to DemoBootstrap
% For each combination of CondSpecs, compute a 95\% t confidence interval:
%  for a single mean
%  for a paired difference
%  for the difference of unpaired scores

% Or alpha
[confid, varargin] = ExtractNameVali('Conf',.95,varargin);

[outResultTable1, outDVNames1] = CondNs(inTrials,CondSpecs,varargin{:});
[outResultTable2, outDVNames2] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,{@mean @std},varargin{:});

outResultTable = join(outResultTable1,outResultTable2);
outDVNames = [outDVNames1 outDVNames2];

end

