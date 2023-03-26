function outTrials = revTrials(inTrials,CondSpecs,FirstN,varargin)
    % Create a new Trials array reversing the order of the first FirstN trials
    % within each combination of conditions defined by CondSpecs.
    % e.g., with FirstN=10, the new table will have trials within each
    % combinations of conditions in the order 10,9,8,...1,11,12,13,...

    CondSpecs = EnsureCell(CondSpecs);

    mySubTableIndices = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = numel(mySubTableIndices);

    outTrials = inTrials;  % The copy outTrials will be changed

    for iCond = 1:NConds
        origIndices = mySubTableIndices{iCond};
        nInThisCond = numel(origIndices);
        nToReverse = min(FirstN,nInThisCond);  % Can't reverse more than there are
        IndicesWithReversal = origIndices;    % Just a copy
        IndicesWithReversal(1:nToReverse) = origIndices(nToReverse:-1:1);  % Reverse the positions of the first nToReverse trials.
        outTrials(origIndices,:) = inTrials(IndicesWithReversal,:);
    end

end