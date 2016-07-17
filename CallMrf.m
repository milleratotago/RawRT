function sysResult = CallMrf(Trials,sDV,BetweenFacs,WithinFacs,SubjectSpec,sOutFileName,varargin)
% Call the MrF program to compute ANOVAs on the variables listed in sDV.
% ANOVAs have the between-Ss & within-Ss factors indicated in the two cell arrays.
% SubjectSpec is the name of the variable indicating the subject number--these must be distinct, unique identifiers for each S.
% sOutFileName is the name of the output RPT, FPR, and FBK files.
% On any factor, levels/conditions coded with values <= 0 are excluded.
% Optional input arguments that can appear in any order:
%   Include/Exclude selection criteria.
%   ThisFun: A function handle indicating what function to compute, if not the mean.
%   Suffixes: A cell array of strings indicating which files to delete.
%   GroupsTogether: A special string indicating that the subjects are "together":
%     i.e., Ss 1-k belong to group 1, k+1-2k belong to group 2, etc
%   NotepadLines: A possibly multi-line string starting with '*', which is to be written to LGF file as notepad lines.
%   NoLoad: Don't load the output file into the MATLAB editor.
%   NoNotepad: Don't write any notepad lines into the output file.

% NewJeff: Need option to specify MrFpath.

% Make sure these are cell arrays.
[sDV, NDVs] = EnsureCell(sDV);
[BetweenFacs, NBetweenFacs] = EnsureCell(BetweenFacs);
[WithinFacs, NWithinFacs] = EnsureCell(WithinFacs);

[NoEdit, varargin] = ExtractNamei('NoEdit',varargin);
EditFileAtEnd = ~NoEdit;

[NoNotepad, varargin] = ExtractNamei('NoNotepad',varargin);
WriteNotepadToFile = ~NoNotepad;
if WriteNotepadToFile
    NotePadSwitchToMrf = '';
else
    NotePadSwitchToMrf = ' -notepad';
end

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

[ThisFun, Suffixes, GroupsTogether, NotepadLines] = OptArgs(varargin{:});

% Mrfb assumes suffixes!
RPTfileName = [sOutFileName '.RPT'];
LGFfileName = [sOutFileName '.LGF'];
FBKfileName = [sOutFileName '.FBK'];
FPRfileName = [sOutFileName '.FPR'];
FERfileName = [sOutFileName '.FER'];

% Remove any FER file created in a previous run.
if exist(FERfileName, 'file')==2
    delete(FERfileName);
end

% sMnSuffix = '';

% Determine and process between-Ss factors & Subjects factor:

if NBetweenFacs > 0
    [NGroups, ~, BetweenLevels, BetweenLevelVals, BetweenCondCombos, GroupSpecIndices] = CondList(Trials,BetweenFacs);
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
% Check whether all groups are the same size
EqualGroups = range(NSubsPerGroup) == 0;   % Evaluates to 1 if true
if ~EqualGroups
    warning('Sorry--the ability to handle unequal group sizes has not been implemented yet!');  % NEWJEFF
    disp('FYI, here are the unequal group sizes:');
    NSubsPerGroup
    return;
end
NEachGroup = NSubsPerGroup(1);  % HERE ONLY VALID FOR EQUAL N
temp = abs(NSubsPerGroup - NEachGroup);
assert(sum(temp)==0,'Sorry!  CallMrf does not work with unequal group sizes.');

% Check to make sure that all subject numbers are unique even if there are between-Ss factors.
% Without such a check, there can be problems (e.g., if the user numbers Ss from 1-N in every group).
if NGroups>1
    for iGroup=1:NGroups-1
        for jGroup=iGroup+1:NGroups
            iSet = intersect(GroupList{iGroup},GroupList{jGroup});
            assert(numel(iSet)==0,['ERROR: Subjects ' num2str(iSet) ' belongs to more than one group.']);
        end
    end
end

if NWithinFacs > 0
    [NCondsPerSub, ~, WithinLevels, WithinLevelVals, WithinCondCombos, CondSpecIndices] = CondList(Trials,WithinFacs);
else
    NCondsPerSub = 1;
end

%NCondsPerSub = prod(NAllLevels(FirstWithinFac:FirstWithinFac+NWithinFacs-1));

% SubCondCombos determines the data to be written out for all subjects.
SubCondCombos = [SubjectSpec WithinFacs];  % Subject factor assumed first

% [NSubsTimesNConds, ~, ~, ~, ~, ~] = CondList(Trials,SubCondCombos);

% Compute the DVs to be sent to Mrf
[MeansToUse, MeanDVNames] = CondFunsOfDVs(Trials,sDV,SubCondCombos,ThisFun);
OneIsMissing = ismissing(MeansToUse);
NofNans = sum(OneIsMissing(1:end));
assert(NofNans==0,['ANOVA aborted because ' num2str(NofNans/NDVs) ' empty cell(s) found.']);

% Write the RPT file:
RPTfile = fopen(RPTfileName, 'wt');
fprintf(RPTfile,'* RPT file written by MatLab/RawRT/CallMrf.m\n');
if numel(NotepadLines)>0&WriteNotepadToFile
    fprintf(RPTfile,NotepadLines);
end
fprintf(RPTfile,' %d %d %d\n',NGroups,NCondsPerSub,NDVs);   % Header line
for iSub=1:NEachGroup
    for iGrp=1:NGroups
        TheseMeans = RowsWhichSatisfy(MeansToUse,{SubjectSpec},GroupList{iGrp}(iSub));
        if ~(height(TheseMeans)==NCondsPerSub)
            warning('Must abort CallMrf due to mismatch between ANOVA design and data set!');
            disp(['Error: Expected ' num2str(NCondsPerSub) ' conditions for subject ' num2str(iSub)]);
            disp(['  but only found these ' num2str(height(TheseMeans)) ' conditions:']);
            disp('Recommendation: check condition coding carefully--crosstabs is often helpful.');
            disp('Also check for NaNs on the DV, which can cause conditions to be dropped.');
            TheseMeans
            fclose(RPTfile);
            return
        end
        fprintf(RPTfile,'* Subject %d\n',GroupList{iGrp}(iSub));
        for iCond = 1:NCondsPerSub
            for iDV=1:NDVs
                fprintf(RPTfile,' %f',TheseMeans.(MeanDVNames{iDV})(iCond));
            end
            fprintf(RPTfile,'\n');
        end
    end
end
fclose(RPTfile);

% Write the LGF file:
LGFfile = fopen(LGFfileName, 'wt');
fprintf(LGFfile,'* LGF file written by MatLab/RawRT/CallMrf.m\n');

if GroupsTogether  % No longer used/needed with between-Ss coding.
    NPerGroupCode = NPerGroup;
else
    NPerGroupCode = 0;
end

fprintf(LGFfile,'Data File:\n');
WriteBetweenFac;
fprintf(LGFfile,'By-Group: %i\n',NPerGroupCode);
WriteWithinFac;

fprintf(LGFfile,'DVs\n');
for iDV=1:NDVs
    fprintf(LGFfile,'%s\n',sDV{iDV});
end

fprintf(LGFfile,'ANOVA:\n');
WriteBetweenFac;
WriteWithinFac;

fclose(LGFfile);

% Run MrF:
%sSysCmd = ['c:\binw\jpas\mrfb.exe ' RPTfileName ' ' LGFfileName];

% I assume that my ANOVA program mrfb.exe is in the same folder as CallMrf.m, so ...
MyPathAndName = mfilename('fullpath');   % Get the full name and path of this file.
MyPath = fileparts(MyPathAndName);       % Get just the folder name
sSysCmd = [MyPath '\mrfb.exe ' '"' sOutFileName '"' NotePadSwitchToMrf];
sysResult = system(sSysCmd);

% Abort because something went wrong if an error code was returned or an *.FER file was created.
assert(sysResult==0,['ERROR: ' sSysCmd ' returned ' num2str(sysResult)]);
assert(exist(FERfileName, 'file')~=2,['ERROR: Mrfb failed.  Check error message in file ' FERfileName '.']);

FPRName=[sOutFileName '.fpr'];
% Display the MrF output file in the MATLAB editor window:
if EditFileAtEnd
    edit(FPRName);
end

% Done with processing, so clean up files.
% Default is to delete RPT, LGF, and RPT but keep FPR
if (numel(Suffixes)==0)||(sum(strcmpi('RPT',Suffixes))==0)
    if exist(RPTfileName, 'file')==2
        delete(RPTfileName);
    end
end
if numel(Suffixes)==0||sum(strcmpi('LGF', Suffixes))==0
    if exist(LGFfileName, 'file')==2
        delete(LGFfileName);
    end
end
if numel(Suffixes)==0||sum(strcmpi('FBK', Suffixes))==0
    if exist(FBKfileName, 'file')==2
        delete(FBKfileName);
    end
end
if numel(Suffixes)>0&&sum(strcmpi('FPR', Suffixes))>0
    if exist(FPRfileName, 'file')==2
        delete(FPRfileName);
    end
end

    function WriteBetweenFac
        fprintf(LGFfile,'%d Between Ss Factor(s)\n',NBetweenFacs);
        for iFac=1:NBetweenFacs
            fprintf(LGFfile,'%s %d\n',BetweenFacs{iFac},BetweenLevels(iFac));
        end
    end

    function WriteWithinFac
        fprintf(LGFfile,'%d Within Ss Factor(s)\n',NWithinFacs);
        for iFac=1:NWithinFacs
            fprintf(LGFfile,'%s %d\n',WithinFacs{iFac},WithinLevels(iFac));
        end
    end

end

function [ThisFun, Suffixes, GroupsTogether, NotepadLines] = OptArgs(varargin)
% Extract three optional input arguments that can appear in any order:
%   ThisFun: A function handle indicating what function to compute, if not the mean.
%   NotepadLines: A cell array with '*' as the first character.
%   Suffixes: Any other cell array.

ThisFun = @mean; % function handle
Suffixes = cell(0);
NotepadLines = cell(0);
GroupsTogether = false;
for iArg = 1:numel(varargin)
    thisArg = varargin{iArg};
    %  whos('thisArg')
    if ischar(thisArg)
        if strcmpi(thisArg,'groups together')||strcmpi(thisArg,'groupstogether')
            GroupsTogether = true;  % Unused / unneeded
        elseif (numel(thisArg) > 0) && (thisArg(1) == '*')
            NotepadLines = thisArg;
        end
    elseif iscell(thisArg)
        Suffixes = thisArg; % cell array
    elseif isa(thisArg,'function_handle')
        ThisFun = thisArg; % function handle
    else
        warning('Unrecognized argument!');
    end
end

end


function TrialsOut = RowsWhichSatisfy(Trials,Variables,Values)
% Return the set of trials have a certain pattern of variable values.
% That is, return trials for which Trials.(Variables{i}) == Values(i) for all i
% If no variables & values are specified, all rows are returned: e.g., RowsWhichSatisfy(Trials,{},[])
%
% Inputs:
%
% Trials: The starting trials table.
%
% Variables: A cell array indicating the names of the variables to be checked.
%
% Values: A vector of values that the corresponding variables must take on.
%
% Outputs:
%
% TrialsOut: A revised copy of the trials array with only trials satisfying the criteria.

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

end

