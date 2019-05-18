function [outResultTable, outDVNames] = CondMeansTrimmed(inTrials,sDVs,CondSpecs,PctTrim,varargin)
% Exclude the PctTrim/2 highest and lowest values, then compute the mean of the rest.
% Round PctTrim/2, and round down if PctTrim/2 is exactly k.5.
%
% varargin options:
%   Include/Exclude options passed through.

% Note: by the trimmean default, MATLAB rounds the number of scores to trim. It has other options but these are not supported.

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@trimmean,varargin{:},'NPassThru',1,PctTrim);

for i=1:numel(outDVNames)
    outDVNames{i} = strrep(outDVNames{i},'prctileTies','prctiles');
end

for i=1:numel(outResultTable.Properties.VariableNames)
    outResultTable.Properties.VariableNames{i} = strrep(outResultTable.Properties.VariableNames{i},'prctileTies','prctiles');
end

end

