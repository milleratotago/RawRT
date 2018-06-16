function [outResultTable, outDVName, RowAddresses] = CondMins(inTrials,sDV,CondSpecs,varargin)
% Make a table with the min DV for each condition, and the row addresses in inTrials where each min was found.
% Only one DV is allowed
%
% Include/Exclude options passed through to SubTableIndices.

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDVName = UniqueVarname(inTrials,'min');

RowAddresses = zeros(NConds,1);
Mins = zeros(NConds,1);

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    OneDV = OneSubTable.(sDV);
    [Mins(iCond), thisRow] = min(OneDV);
    RowAddresses(iCond) = mySubTableIndices{iCond}(thisRow);
end
outResultTable.(outDVName) = Mins;

end
