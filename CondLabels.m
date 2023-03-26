function newLabels = CondLabels(Trials,CondSpecs,varargin)
    % Generate a list of integer labels, one per trial, labelling
    % the distinct conditions specified by CondSpecs from 1..k
    % Excluded files are coded 0.
    % Optional input arguments that can appear in any order:
    %   Include/Exclude selection criteria
    newLabels = zeros(height(Trials),1);
    [mySubTableIndices, outResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        newLabels(Indices) = iCond;
    end

end

