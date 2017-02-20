function [p, tbl, stats] = CallAnovan(Trials,sDV,BetweenFacs,WithinFacs,SubjectSpec,varargin)
% Call MATLAB's anovan function to compute ANOVAs on the variables listed in sDV.
%
% Required input arguments:
%   sDV: Name of the DV to be analyzed.  If 2+ DVs are specified (in a cell array), ANOVAs are run separately for each one.
%   BetweenFacs: A cell array, possibly empty, listing the names of the variables coding the between-Ss factors.
%   WithinFacs : A cell array, possibly empty, listing the names of the variables coding the within-Ss factors.
%   SubjectSpec: The name of the variable indicating the subject identifier--these must be distinct, unique identifiers for each S.
%
% Optional input arguments (that can appear in any order):
%   Include/Exclude selection criteria, as usual (passed thru to MaybeSelect).
%   'Function',function_handle: A function handle indicating what function to compute, if not the mean.
%                               Limitation: The function can only return one output value.
%   'NoDisplay': Tell MATLAB not to display the anovan output.
%   'WantMu' : Augment the anovan output tbl by adding a line for the constant term in the model.

% Outputs p, tbl, and stats are produced by anovan.


% **************** Process the function input arguments ****************

% Make sure these arguments are cell arrays:
%[sDV, NDVs] = EnsureCell(sDV);  % UNNEEDED BECAUSE ONLY ONE DV ALLOWED AT THE MOMENT
[BetweenFacs, NBetweenFacs] = EnsureCell(BetweenFacs);
[WithinFacs, NWithinFacs] = EnsureCell(WithinFacs);
NExptlFacs = NBetweenFacs + NWithinFacs;

% Extract the optional arguments:
[ThisFun, varargin] = ExtractNameVali('Function',0,varargin);  % e.g., @mean
[NoDisplay,  varargin] = ExtractNamei({'NoDisplay','NoLoad'},varargin);
[WantMu,  varargin] = ExtractNamei({'Mean','WantMean','WantMu','AddMean','Mu'},varargin);

% **************** Select the Included/Excluded data.
% This must be done before checking factors, because the selected
% data are used to determine the factor levels.
[Trials, varargin] = MaybeSelect(Trials,varargin{:});

% Halt if there are any unprocessed input arguments:
assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);


% **************** Process between-Ss factor(s) & Subjects factor:

if NBetweenFacs > 0
    [NGroups, ~, ~, ~, ~, GroupSpecIndices] = CondList(Trials,BetweenFacs);
else
    NGroups = 1;
end

% Get a list and a count of the subjects in each group:
NSubsPerGroup = zeros(NGroups,1);
GroupList = cell(NGroups,1);  % Each cell holds the list of subjects in one group
for iGrp = 1:NGroups
    if NGroups > 1
        TableForOneGroup = RowsWhichSatisfy(Trials,BetweenFacs,GroupSpecIndices(iGrp,:));
    else
        TableForOneGroup = Trials;
    end
    GroupList{iGrp} = unique(TableForOneGroup.(SubjectSpec));
    NSubsPerGroup(iGrp) = numel(GroupList{iGrp});
end

% Check to make sure that all subject numbers are unique even if there are between-Ss factors.
% Without such a check, there can be problems (e.g., if the user numbers Ss from 1-N in every group).
if NGroups>1
    for iGroup=1:NGroups-1
        for jGroup=iGroup+1:NGroups
            iSet = intersect(GroupList{iGroup},GroupList{jGroup});
            assert(numel(iSet)==0,['ERROR: Subjects ' num2str(iSet') ' belongs to more than one group.']);
        end
    end
end


% **************** Process within-Ss factor(s):

% if NWithinFacs > 0
%     [NCondsPerSub, ~, WithinLevels, ~, ~, ~] = CondList(Trials,WithinFacs);
% else
%     NCondsPerSub = 1;
% end


if isa(ThisFun,'function_handle')
    % Compute the summary values of the DVs that are to be analyzed:
    % SubCondCombos determines the data to be written out for all subjects.
    SubCondCombos = [SubjectSpec BetweenFacs WithinFacs];  % Subject factor assumed first
    [ValsToUse, MeanDVNames] = CondFunsOfDVs(Trials,sDV,SubCondCombos,ThisFun);
    sDV = MeanDVNames{1};
else
    % Analyze the DVs in Trials, without summarizing them.
    ValsToUse = Trials;
end
OneIsMissing = ismissing(ValsToUse);
NofNans = sum(OneIsMissing(1:end));
assert(NofNans==0,['ANOVA aborted because ' num2str(NofNans) ' empty cell(s) found.']);

% Call anovan
if NoDisplay
   sDisplay = 'off';
else
   sDisplay = 'on';
end
factorCodes = cell(1,NExptlFacs+1);
for iFac=1:NBetweenFacs
    factorCodes{1,iFac} = ValsToUse.(BetweenFacs{iFac});
end
for iFac=1:NWithinFacs
    factorCodes{1,NBetweenFacs+iFac} = ValsToUse.(WithinFacs{iFac});
end
factorCodes{1,end} = ValsToUse.(SubjectSpec);

% Define nesting if any between-Ss factors:
if NBetweenFacs>0
   NestArgs = cell(1,2);
   NestArgs{1} = 'nested';
   NestArgs{2} = zeros(NExptlFacs+1,NExptlFacs+1);  % +1 represents the subjects factor
   % Each row corresponds to one factor:
   %   Row 1 = 1st between-Ss factor, etc
   %   Put 1 in last col for Between factors to indicate Ss nested in these.
   % arg(i,j) = 1 if variable i is nested in variable j.
   NestArgs{2}(NExptlFacs+1,1:NBetweenFacs) = ones(1,NBetweenFacs);  % Ss factor is nested in all the between facs.
else
   NestArgs = {};
end

[p tbl stats] = anovan(ValsToUse.(sDV),factorCodes, ...
     'model','full','random',NExptlFacs+1, NestArgs{:}, ... % 'nested',NestSpecs,
     'varnames',[BetweenFacs WithinFacs {SubjectSpec}],'display',sDisplay);

 if WantMu
     
     % Increment the total df
     tbl{end,3} = tbl{end,3} + 1;  % df

     % Insert a row to p and to tbl.
     p = [0; p];
     tbl = [tbl(1,:); tbl];
     
     % Construct the string name of the pure Ss error term:
     if NBetweenFacs > 0
         ETName = [SubjectSpec '(' BetweenFacs{1}];
         for iFac = 2:NBetweenFacs
            ETName = [ETName ',' BetweenFacs{iFac}];
         end
         ETName = [ETName ')'];
     else
         ETName = SubjectSpec;
     end
     
     ierrsrc = find(strcmp(tbl(:,1),ETName)); % Find the row of tbl with the pure Ss error term:
     
     % Compute Fmean & its p level:
     obsmean = stats.coeffs(1);
     SS = obsmean^2*tbl{end,3};  % mean^2 * total df

     dferr = tbl{ierrsrc,3};
     MSerr = tbl{ierrsrc,5};
     Fobs = SS / MSerr;
     
     % Add values into the table
     [~, tblcols] = size(tbl);
     tbl(2,1) = cellstr('Mu');
     tbl{2,2} = SS;  % SS
     tbl{2,3} = 1;  % df
     tbl{2,4} = 0;  % Singular
     tbl{2,5} = tbl{2,2};  % MS
     tbl{2,6} = Fobs;
     tbl{2,7} = 1 - fcdf(Fobs,1,dferr);
     if tblcols > 7
         tbl{2,8} = 'fixed';
         tbl{2,9} = 'E[MS] UNKNOWN';
         tbl{2,10} = MSerr;
         tbl{2,11} = dferr;
         tbl{2,12} = ['MS(' ETName ')'];  % Denom defn
         tbl{2,13} = [];
         tbl{2,14} = [];
         tbl{2,15} = [];
     end

end

end  % CallAnovan

function TrialsOut = RowsWhichSatisfy(Trials,Variables,Values)
% Return the set of trials that have a certain pattern of variable values.
% That is, return trials for which Trials.(Variables{i}) == Values(i) for all i
% If no variables & values are specified, all rows are returned: e.g., RowsWhichSatisfy(Trials,{},[])
%
% Inputs:
%    Trials: The starting trials table.
%    Variables: A cell array indicating the names of the variables to be checked.
%    Values: A vector of values that the corresponding variables must take on.
%
% Outputs:
%    TrialsOut: A revised copy of the trials array with only trials satisfying the criteria.

NChecks = numel(Values);  % Number of criteria used to exclude criteria.
assert(NChecks == numel(Variables),'Must indicate the same number of variables and values.');

TempVarName = UniqueVarname(Trials,'Asdf');

Temp = Trials;
Temp.(TempVarName) = ones(height(Trials),1);

for iCrit=1:NChecks
    sCrit = Variables{iCrit};    % Name of variable being checked.  It must have value   Values(iCrit)
    Temp.(TempVarName)(~(Temp.(sCrit)==Values(iCrit))) = 0;  % Mark as bad any trials that do not have the desired value.
end

TrialsOut = Temp(Temp.(TempVarName)>0,:);
TrialsOut.(TempVarName) = [];

end  % RowsWhichSatisfy

