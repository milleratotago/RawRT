function outTrials = CondBootsample(inTrials,CondSpecs,varargin)
% Generate outTrials as a random bootstrap sample of inTrials, separately for each combination of CondSpecs.
% outTrials will have exactly the same number of trials as inTrials at each combination of conditions,
% but these will be a bootstrap sample of the original trials at that combination.
% Notes:
%   The order of the condition combinations in outTrials will be the same as in inTrials.
%   Any excluded trials in inTrials will be copied exactly into outTrials.

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outTrials = inTrials;

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    OneSample = datasample(OneSubTable,height(OneSubTable));
    outTrials(mySubTableIndices{iCond},:) = OneSample(:,:);
end

end
