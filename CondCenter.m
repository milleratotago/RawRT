function outDV = CondCenter(inTrials,sDV,CondSpecs,varargin)
% "Centers" the values of RV for each combination of all-but-one of
% the CondSpecs and returns the result as the output DV.
% Centering subtracts the mean of the values in that condition
% from each value, so that the new mean of the values is zero.
% Note this just removes the overall mean if there is only any one identifier in CondSpecs.

CondSpecs = EnsureCell(CondSpecs);

outDV = inTrials.(sDV);

for iDrop = 1:numel(CondSpecs)
    % Drop each of the specs once.
    SubConds = {CondSpecs{1:iDrop-1} CondSpecs{iDrop+1:end}};
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,SubConds,varargin{:});
    NConds = height(outResultTable);
    for iCond = 1:NConds
        condMean = mean(outDV(mySubTableIndices{iCond}));
        outDV(mySubTableIndices{iCond}) = outDV(mySubTableIndices{iCond}) - condMean;
    end
end

end
