function outResultTable = CondWeightedRowAvg(Trials,sDVs,CondSpecs,sWeights,varargin)
    % For each DV, for each combination defined by CondSpecs, compute a new value of DV
    % that is the weighted average of all DV values in different rows,
    % with row weights indicated by the variable sWeights.
    % Also compute the number of rows and the sum of the row weights for each combination.
    %
    % Include/Exclude options passed through to SubTableIndices.
    
    % Make sure sDV is a cell array.
    [sDVs, nDVs] = EnsureCell(sDVs);
    
    [CondSpecs, ~] = EnsureCell(CondSpecs);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    % Make sure that the weights column is recognized as a double:
    Trials.(sWeights) = cast(Trials.(sWeights),'double');
    
    % Make output variables with the same name as input:
    for iDV=1:nDVs
        siDV = sDVs{iDV};
        outResultTable.(siDV) = zeros(NConds,1);
    end
    outResultTable.NRowsAveraged = zeros(NConds,1);
    outResultTable.SumWeights = zeros(NConds,1);
    
    % Iterate through conditions & produce the output values
    % (siDV), SumWeight, and NRowsAveraged for each condition
    for iCond = 1:NConds
        OneSubTable = Trials(mySubTableIndices{iCond},:);
        wts = OneSubTable.(sWeights);
        wtSum = sum(wts);
        for iDV=1:nDVs
            siDV = sDVs{iDV};
            prods = wts .* OneSubTable.(siDV);
            outResultTable.(siDV)(iCond) = sum(prods) / wtSum;
        end
        outResultTable.SumWeights(iCond) = wtSum;
        outResultTable.NRowsAveraged(iCond) = height(OneSubTable);
    end
    
end