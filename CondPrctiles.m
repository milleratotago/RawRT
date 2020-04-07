function [outResultTable, outDVNames] = CondPrctiles(inTrials,sDVs,CondSpecs,Prctiles,varargin)
% Prctiles in range 0-100
%
% varargin options:
%   Include/Exclude options passed through.

% MATLAB prctile function handles ties differently (incorrectly, in my view):
% [outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@prctile,varargin{:},'NPassThru',1,Prctiles);

% This version handles ties as described by Ulrich, Miller, & Schroeter (2007):
[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@prctileTies,varargin{:},'NPassThru',1,Prctiles);

for i=1:numel(outDVNames)
    outDVNames{i} = strrep(outDVNames{i},'prctileTies','prctiles');
end

for i=1:numel(outResultTable.Properties.VariableNames)
    outResultTable.Properties.VariableNames{i} = strrep(outResultTable.Properties.VariableNames{i},'prctileTies','prctiles');
end

end

