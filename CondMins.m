function [outResultTable, outDVName, RowAddresses] = CondMins(inTrials,sDV,CondSpecs,varargin)
% Make a table with the min DV for each condition, and the row addresses in inTrials where each min was found.
% Only one DV is allowed
%
% Include/Exclude options passed through to SubTableIndices.

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDVName = UniqueVarname(inTrials,'min');

RowAddresses = nan(NConds,1);
Mins = nan(NConds,1);

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    OneDV = OneSubTable.(sDV);
    [m, thisRow] = min(OneDV);
    if numel(m)>0
        Mins(iCond) = m;
        RowAddresses(iCond) = mySubTableIndices{iCond}(thisRow);
    end
end
outResultTable.(outDVName) = Mins;

end
