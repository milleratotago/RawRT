function [outResultTable, outDVNames] = CondWeightedSum(Trials,sDVs,CondSpecs,CondName,Weights,varargin)
    % For each DV, for each combination defined by CondSpecs, compute a weighted linear function
    % of the different conditions distinguished within the variable CondName,
    % as specified by weights, averaging across any other (unspecified) dimensions of the Trials dataset.
    %
    % Include/Exclude options passed through to SubTableIndices.
    
    NContrasts = 1;
    % sMean = 'mean';
    
    % Make sure sDV is a cell array.
    [sDVs, nDVs] = EnsureCell(sDVs);
    
    [CondSpecs, ~] = EnsureCell(CondSpecs);
    
    [BaseMeanTable, BaseMeanNames] = CondMeans(Trials,sDVs,[CondSpecs(:); {CondName}],varargin{:});
    
    warning('off', 'MATLAB:table:ModifiedVarnamesUnstack');
    outResultTable = unstackvec(BaseMeanTable,BaseMeanNames,CondName);
    warning('on', 'MATLAB:table:ModifiedVarnamesUnstack');
    NConds = height(outResultTable);
    
    % Make columns to hold contrast values:
    outDVNames = cell(nDVs,1);
    for iDV=1:nDVs
        outDVNames{iDV} = UniqueVarname(outResultTable,[BaseMeanNames{iDV} 'Contrast']);
        outResultTable.(outDVNames{iDV}) = zeros(NConds,NContrasts);
    end
    
    for iDV=1:nDVs
        %     outResultTable.(outDVNames{iDV}) = (Weights * outResultTable.(sDVsMeans{iDV})')';
        outResultTable.(outDVNames{iDV}) = (Weights * outResultTable.(BaseMeanNames{iDV})')';
    end
    
    % Kill the columns holding the vectors of values across each sDV:
    for iDV = 1:nDVs
        outResultTable.(BaseMeanNames{iDV}) = [];
    end
    
end

