function SubSampleTrials = SubsampleSubs(Trials,NSubs,sSubNo)
    % Make an output table with all of the trials from a random subset of the subjects, where
    %  sSubNo is a string indicating the column of Trials holding the numeric subject identifier.
    % Example:
    %   SubSampleTrials = SubsampleSubs(Trials,10,'SubNo'); % select 10 random Ss
    %       with numeric subject number IDs in Trials.SubNo.
    %       (SubNo's need not start at 1 or be sequential).

    % What are the unique subject IDs?
    SubNumList = unique(Trials.(sSubNo));
    TotalNSubs = numel(SubNumList);
    assert(NSubs <= TotalNSubs,'SubsampleSubs cannot sample more subs than there are.');

    % Decide which NSubs random subject IDs in SubNumList to take.
    randSubs = randperm(TotalNSubs);
    randSubs = randSubs(1:NSubs);

    % Collect the random subject IDs to be used for this sample.
    TargetSubNums = SubNumList(randSubs);

    % Extract all of the trials for those subject IDs
    SubSampleTrials = Trials(ismember(Trials.(sSubNo),TargetSubNums),:);

end
