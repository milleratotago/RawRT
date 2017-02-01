function outDV = CondAssign(inTrials,CondSpecs,NewValues,varargin)
% The values in NewValues are assigned to outDV in accordance
% with the conditions specified in CondSpecs.

CondSpecs = EnsureCell(CondSpecs);
[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);
assert(numel(NewValues)==NConds,['Error: Do not know how to assign ' num2str(numel(NewValues)) ' new values to ' num2str(NConds) ' conditions.']);

outDV = NaN(height(inTrials),1);

for iCond = 1:NConds
    outDV(mySubTableIndices{iCond}) = NewValues(iCond);
end

end
