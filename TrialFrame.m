function Trials = TrialFrame(FactorNames,Levels,varargin)
% Generate a Trials table with the conditions defined by FactorNames (but no data),
%  each having the indicated number of levels.
% Use a fake replication factor to get more than one trial per condition.
% Optional arguments:
%   'DropVar',{VarList}: A list of variables to be dropped from the final table (e.g., fake replication factor).
%   'SortBy',{VarList}: Sort the output table according to the values of the variables in this list.
%   'Shuffle': A boolean toggle indicating that the order of the trials should be randomized _except for_ the SortBy variables.
%   'Between'/'Nested',{{BetweenFactors},SubjectsFactor}: This argument is tricky!
%           It is used to signal that some factors are between-Ss (i.e., nested in other factors).
%           The argument is a cell array with 2 cells.
%               1. Another cell array that is a list of the between-Ss factors.
%               2. A string that is the name of the subjects factor.
%           Examples:
%             'Between',{{'A'},'S'}   % Factor A is a between-Ss factor, and the subjects factor is called 'S'.
%             'Between',{{'A','C'},'Subj'}   % Factors A & B are between-Ss factors, and the subjects factor is called 'Subj'.
%           This option can be specified multiple times to nest multiple factors.
%              Example: 'Between',{{'A','C'},'Subj'},'Between',{{'A','C','Subj'},'Rep'}
%              In this example, Subjects are nested in A and C, and then Replications are nested in A, C, and Subj.
%           Note that the default is for no factors to be between-Ss (i.e., fully repeated-measures design).

[DropVariables, varargin] = ExtractNameVali({'Drop','DropVar','DropVariable','DropVariables'},{},varargin);
[SortVars, varargin] = ExtractNameVali({'Sort','SortBy','SortVars'},{},varargin);
[Shuffle, varargin] = ExtractNamei('Shuffle',varargin);

% Extract Between/nested parameters, of which there may be more than one.
NNesting = 0;
Nesting = cell(0,0);
TryAgain = true;
while TryAgain
    [tempNesting, varargin] = ExtractNameVali({'Between','Nested'},{},varargin);
    if numel(tempNesting) > 0
        NNesting = NNesting + 1;
        Nesting{NNesting} = tempNesting;
    else
        TryAgain = false;
    end
end

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin')]);

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

% Change the nested-factor level numbers to indicate any requested nesting:
for iNest = 1:NNesting
    thisNesting = Nesting{iNest};
    if numel(thisNesting)==2
        BetweenFacs = thisNesting{1};
        BetweenFacs = EnsureCell(BetweenFacs);
        SName = thisNesting{2};
        % GroupSize = max(Trials.(SName));
        [mySubTableIndices, tempTbl] = SubTableIndices(Trials,BetweenFacs);
        NConds = height(tempTbl);
        PrevMax = max(Trials.(SName)(mySubTableIndices{1}));
        for iCond = 2:NConds  % OK to skip the first group
            Trials.(SName)(mySubTableIndices{iCond}) = Trials.(SName)(mySubTableIndices{iCond}) + PrevMax;
            if sum(mySubTableIndices{iCond})>0
                PrevMax = max(Trials.(SName)(mySubTableIndices{iCond}));
            end
        end
    elseif ~(numel(thisNesting)==0)
        warning('Ignoring incorrectly specified between-Ss factors.');
    end
end  % for iNest

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
