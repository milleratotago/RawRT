function [outResultTable, outDVNames] = CondDescribe(inTrials,sDVs,CondSpecs,varargin)
% Make a table describing each condition on each DV in terms of its N, mean, sd, median, min, max
%
% Optional arguments:
%   'DVRows': Include this argument if you want each DV to come out on a separate row
%             with columns for N, mean, sd, min, max, etc.
%   Include/Exclude options passed through to SubTableIndices.

[DVRows, varargin] = ExtractNamei({'DVsInRows','DVsByRows','DVsRows','DVRows'},varargin);

[outResultTable1, outDVNames1] = CondNs(inTrials,CondSpecs,varargin{:});

% CondFunsOfDVs causes problems if some combinations of CondSpecs are empty,
% because in that case some functions produce NANs but min & max produce empty outputs.
% For this reason I have written special min/max functions (minNAN4empty, maxNAN4empty)
% that also produce NaN outputs when the input array is empty.

if DVRows
    outResultTable = table;
    NSummaries = 7;  % N, Mean, StdDev, etc
    for iDV=1:numel(sDVs)
        inTrials.(sDVs{iDV}) = double(inTrials.(sDVs{iDV})); % @std only works on floating point numbers
        [outResultTable2, outDVNames2] = CondFunsOfDVs(inTrials,sDVs{iDV},CondSpecs,{@mean @std @stderr @median @minNAN4empty @maxNAN4empty},'SaveNaNs',varargin{:});
        outResultTable2 = join(outResultTable1,outResultTable2);
        [outResultTable2.Properties.VariableNames(end-NSummaries+1:end)] = deal({'N', 'Mean', 'StdDev', 'StdErr', 'Median', 'Min', 'Max'});
        DVName = repmat(sDVs(iDV),height(outResultTable2),1);
        outResultTable2.DV = DVName;
        outResultTable = [outResultTable; outResultTable2]; %#ok<AGROW>
    end
    LastCol = width(outResultTable);
    outResultTable = outResultTable(:,[LastCol 1:(LastCol-1)]);
else
   [outResultTable2, outDVNames2] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,{@mean @std @stderr @median @minNAN4empty @maxNAN4empty},'SaveNaNs',varargin{:});
   outResultTable = join(outResultTable1,outResultTable2);
   outDVNames = [outDVNames1 outDVNames2];
end

end
