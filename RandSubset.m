function [SubTbl, TargetVars] = RandSubset(Trials,sVar,NinSubset)
    % Select NinSubset random values of Trials.(sVar).
    % Return a subset table with all rows of the Trials table in which the
    % column sVar is one of those NinSubset randomly selected values.

    % What are the unique values of sVar?
    VarList = unique(Trials.(sVar));
    TotalNVarValues = numel(VarList);
    assert(NinSubset <= TotalNVarValues,'SubsampleSubs cannot sample more subs than there are.');

    % Decide which NinSubset random Var values in VarList to take.
    randVars = randperm(TotalNVarValues);
    SelectedVals = randVars(1:NinSubset);

    % Collect the random subject IDs to be used for this sample.
    TargetVars = VarList(SelectedVals);

    % Extract all of the trials for those subject IDs
    SubTbl = Trials(ismember(Trials.(sVar),TargetVars),:);

end

