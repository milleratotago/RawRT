function anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrialsPerCell)

% NEWJEFF: This should just be AnovaPower constructor.

if NTrialsPerCell==1
    ReplicParms = cell(0,0);
    ReplicLevels = [];
    ReplicName = [];
else
    ReplicParms = [{'NReplications'} {NTrialsPerCell}];
    ReplicLevels = NTrialsPerCell;
    Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
    ReplicName = UniqueVarname(Trials,'replic');
end
Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs ReplicName] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels ReplicLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

end
