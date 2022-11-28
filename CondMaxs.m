function [outResultTable, outDVName, RowAddresses] = CondMaxs(inTrials,sDV,CondSpecs,varargin)
% Make a table with the max DV for each condition, and the row addresses in inTrials where each max was found.
% Only one DV is allowed
%
% Include/Exclude options passed through to SubTableIndices.

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDVName = UniqueVarname(inTrials,'max');

RowAddresses = nan(NConds,1);
Maxs = nan(NConds,1);

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    OneDV = OneSubTable.(sDV);
    [m, thisRow] = max(OneDV);
    if numel(m)>0
        Maxs(iCond) = m;
        RowAddresses(iCond) = mySubTableIndices{iCond}(thisRow);
    end
end
outResultTable.(outDVName) = Maxs;

end
