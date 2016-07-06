function Trials = TrialFrame(FactorNames,Levels,varargin)
% Generate a Trials table with the conditions defined by FactorNames (but no data),
%  each having the indicated number of levels.
% Use a fake replication factor to get more than one trial per condition.
% Optional arguments:
%   'DropVar',{VarList}: A list of variables to be dropped from the final table (e.g., fake replication factor).
%   'SortBy',{VarList}: Sort the output table according to the values of the variables in this list.
%   'Shuffle': A boolean indicating that the order of the trials should be randomized _except for_ the SortBy variables.

[DropVariables, varargin] = ExtractNameVali({'Drop','DropVar','DropVariable','DropVariables'},{},varargin);
[SortVars, varargin] = ExtractNameVali({'Sort','SortBy','SortVars'},{},varargin);
[Shuffle, varargin] = ExtractNamei('Shuffle',varargin);

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

NFactorNames = numel(FactorNames);
assert(NFactorNames==numel(Levels),'Numbers of specified factor names and levels must match.');

% Generate matrix of factorial combinations for all conditions, including Ss & blocks
LevelLists = cell(NFactorNames,1);
for iFac=1:NFactorNames
    LevelLists{iFac} = 1:Levels(iFac);
end
AllCombos = allcomb(LevelLists{:});   % This has all combinations of factor combinations.

% Convert the array to a table
Trials = array2table(AllCombos,'VariableNames',FactorNames);
NTrials = height(Trials);

if ~isnumeric(DropVariables)
   [DropVariables, NVars] = EnsureCell(DropVariables);
   for iVar = 1:NVars
       Trials.(DropVariables{iVar}) = [];
   end
end

if Shuffle
    ShuffleVarName = UniqueVarname(Trials);
    Trials.(ShuffleVarName) = rand(NTrials,1);
    SortVars = [SortVars {ShuffleVarName}];
end

Trials = sortrows(Trials,SortVars);

if Shuffle
    Trials.(ShuffleVarName) = [];
end

end
