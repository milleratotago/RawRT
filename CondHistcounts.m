function [outResultTable, outDVNames] = CondHistcounts(inTrials,sDVs,CondSpecs,Edges,varargin)
    % Make a table of histogram counts for the bins defined by edges.
    
    % Drop assignment of scores to bins because this fails if different conditions have different numbers of trials.
    [outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@histcounts,varargin{:}, ...
        'DropOutputs',[false false true],  'NPassThru',3,Edges,'Normalization','probability');
    
end

