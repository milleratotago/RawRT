function sysResult = CallMrf(Trials,sDV,BetweenFacs,WithinFacs,SubjectSpec,sOutFileName,varargin)
% Call the MrF program (mrfb.exe or mrfub.exe) to compute ANOVAs on the variables listed in sDV.
% For more information on this program, see:   https://web.psy.otago.ac.nz/miller/progs/mrf.zip

% NEWJEFF: mrfub has a shorter limit on the length of a factor name.  Should probably check for that or update mrfub.

% Required input arguments:
%   sDV: Name(s) of the DV(s) to be analyzed.  If 2+ DVs are specified (in a cell array), ANOVAs are run separately for each one.
%   BetweenFacs: A cell array, possibly empty, listing the names of the variables coding the between-Ss factors.
%   WithinFacs : A cell array, possibly empty, listing the names of the variables coding the within-Ss factors.
%   SubjectSpec: The name of the variable indicating the subject identifier--these must be distinct, unique identifiers for each S.
%   sOutFileName: The name used for the output files (i.e., *.RPT, *.LGF, *.FPR, and *.FBK).

% Optional input arguments (that can appear in any order):
%   Include/Exclude selection criteria, as usual (passed thru to MaybeSelect).
%   'Function',function_handle: A function handle indicating what function to compute, if not the mean.
%                               Limitation: The function can only return one output value.
%   'SaveFBK', 'SaveLGF', 'SaveRPT': Switches indicating that the temporary file should be saved (e.g., for debugging).
%   'KillFPR': A switch indicating that the output FPR file should be deleted (after it is loaded into the editor).
%   'NoEdit': Don't load the output file into the MATLAB editor.
%   'Notepad',sNotepadLines: A possibly multi-line string, each line starting with '*', which is to be written to LGF file as notepad lines.
%   'NoNotepad': Don't write any notepad lines into the output FPR file.
%   'Path',sPath: A path that is to be added to the DOS path.  This indicates where mrfb.exe and mrfub.exe are found.
%                 The path should include backslashes but no final backslash, e.g.: 'Path','C:\binw\jpas'
%                 The path is removed from the DOS path at the end of this function.

% Notes for programmers about the DOS path:  NewJeff
%  By default, the location of this *.m file is added to the path, so both exe files
%    will be found if they are located there.
%  Specify the option 'Path',sPathString to add a different path.
%  Specify the option 'NoPath' to tell this file not to add anything to the path (if your default path already includes these exe files).


% Programmer notes:
%  o  groups are always "together" in the RPT file.
%  o  mrfub calls mrfb, so both mrfb and mrfub must be on the DOS path for the "system" command to work, even if only mrfub is used.


% **************** Process the function input arguments ****************

% Make sure these arguments are cell arrays:
[sDV, NDVs] = EnsureCell(sDV);
[BetweenFacs, NBetweenFacs] = EnsureCell(BetweenFacs);
[WithinFacs, NWithinFacs] = EnsureCell(WithinFacs);

% Extract the optional arguments:
[ThisFun, varargin] = ExtractNameVali('Function',@mean,varargin);
[SaveFBK, varargin] = ExtractNamei('SaveFBK',varargin);
[SaveLGF, varargin] = ExtractNamei('SaveLGF',varargin);
[SaveRPT, varargin] = ExtractNamei('SaveRPT',varargin);
[KillFPR, varargin] = ExtractNamei('KillFPR',varargin);
[NoEdit,  varargin] = ExtractNamei({'NoEdit','NoLoad'},varargin);
[NotepadLines, varargin] = ExtractNameVali('Notepad','',varargin); %#ok<ASGLU>

[NoNotepad, varargin] = ExtractNamei('NoNotepad',varargin);
if ~NoNotepad
    NotePadSwitchToMrf = '';
else
    NotePadSwitchToMrf = ' -notepad';
end

% The default path assumption is that mrfb.exe & mrfub.exe are in the same folder as CallMrf.m:
MyPathAndName = mfilename('fullpath');   % Get the full name and path of this file.
DefaultPath = fileparts(MyPathAndName);       % Get just the folder name
[MyPath, varargin] = ExtractNameVali('Path',DefaultPath,varargin);

% Construct the file names.  Note that mrfb and mrfub assume these suffixes:
RPTfName = [sOutFileName '.RPT'];
LGFfName = [sOutFileName '.LGF'];
FBKfName = [sOutFileName '.FBK'];
FPRfName = [sOutFileName '.FPR'];
FERfName = [sOutFileName '.FER'];

% Remove the FER file if one is left over from a previous run.
if exist(FERfName, 'file')==2
    delete(FERfName);
end


% **************** Select the Included/Excluded data.
% This must be done before checking factors, because the selected
% data are used to determine the factor levels.
[Trials, varargin] = MaybeSelect(Trials,varargin{:});

% Halt if there are any unprocessed input arguments:
assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);


% **************** Process between-Ss factor(s) & Subjects factor:

if NBetweenFacs > 0
    [NGroups, ~, BetweenLevels, ~, ~, GroupSpecIndices] = CondList(Trials,BetweenFacs);
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
NEachGroup = NSubsPerGroup(1);
temp = abs(NSubsPerGroup - NEachGroup);
EqualNs = sum(temp)==0;
if EqualNs
    ProgName = 'mrfb';
else
    ProgName = 'mrfub';
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

if NWithinFacs > 0
    [NCondsPerSub, ~, WithinLevels, ~, ~, ~] = CondList(Trials,WithinFacs);
else
    NCondsPerSub = 1;
end

% SubCondCombos determines the data to be written out for all subjects.
SubCondCombos = [SubjectSpec WithinFacs];  % Subject factor assumed first

% [NSubsTimesNConds, ~, ~, ~, ~, ~] = CondList(Trials,SubCondCombos);



% **************** Compute the values of the DVs that are to be analyzed:

[MeansToUse, MeanDVNames] = CondFunsOfDVs(Trials,sDV,SubCondCombos,ThisFun);
OneIsMissing = ismissing(MeansToUse);
NofNans = sum(OneIsMissing(1:end));
assert(NofNans==0,['ANOVA aborted because ' num2str(NofNans/NDVs) ' empty cell(s) found.']);


% **************** Write the RPT file:
RPTfile = fopen(RPTfName, 'wt');
% Header line(s):
fprintf(RPTfile,'* RPT file written by CallMrf.m\n');
if ~EqualNs
    % Write Group size header lines:
    fprintf(RPTfile,'* Group sizes:\n');
    for iGrp=1:NGroups
        fprintf(RPTfile,'*  %i { number of subjects in group %i }\n',NSubsPerGroup(iGrp),iGrp);
    end
end
fprintf(RPTfile,' %d %d %d\n',NGroups,NCondsPerSub,NDVs);   % Header line
% Write the RPT file data lines.  Note that the groups are always together.
for iGrp=1:NGroups
    for iSub=1:NSubsPerGroup(iGrp)
        TheseMeans = RowsWhichSatisfy(MeansToUse,{SubjectSpec},GroupList{iGrp}(iSub));
        if ~(height(TheseMeans)==NCondsPerSub)
            warning('Must abort CallMrf due to mismatch between ANOVA design and data set!');
            disp(['Error: Expected ' num2str(NCondsPerSub) ' conditions for subject ' num2str(iSub)]);
            disp(['  but only found these ' num2str(height(TheseMeans)) ' conditions:']);
            disp('Recommendation: check condition coding carefully--crosstabs is often helpful.');
            disp('Also check for NaNs on the DV, which can cause conditions to be dropped.');
            TheseMeans %#ok<NOPRT>
            fclose(RPTfile);
            return
        end
        fprintf(RPTfile,'* Subject %d\n',GroupList{iGrp}(iSub));
        for iCond = 1:NCondsPerSub
            for iDV=1:NDVs %#ok<FXUP>
                fprintf(RPTfile,' %f',TheseMeans.(MeanDVNames{iDV})(iCond));
            end
            fprintf(RPTfile,'\n');
        end
    end
end
fclose(RPTfile);

% **************** Write the LGF file ****************
LGFfile = fopen(LGFfName, 'wt');
fprintf(LGFfile,'* LGF file written by CallMrf.m\n');
if ~EqualNs
    fprintf(LGFfile,'* UNWEIGHTED MEANS ANALYSIS with unequal group sizes.\n');
    fprintf(LGFfile,'* WARNING: The "Standard error of contrast and confidence interval halfwidths" are not correct.\n');
end
if (numel(NotepadLines)>0) && (~NoNotepad)
    fprintf(LGFfile,NotepadLines);
end

fprintf(LGFfile,'Data File:\n');
WriteBetweenFac;
% Note the following NSubs is correct when all groups are the same size, for mrfb,
% and it is unused when the group sizes differ, for mrfub.
fprintf(LGFfile,'By-Group: %i\n',NSubsPerGroup(1));
WriteWithinFac;

fprintf(LGFfile,'DVs\n');
for iDV=1:NDVs %#ok<FXUP>
    fprintf(LGFfile,'%s\n',sDV{iDV});
end

fprintf(LGFfile,'ANOVA:\n');
WriteBetweenFac;
WriteWithinFac;

fclose(LGFfile);


% **************** Run mrfb or mrfub

% Adjust the path if required:
if numel(MyPath)>0
    oldpath = getenv('PATH');
    setenv('PATH', [oldpath ';' MyPath]);
end

sSysCmd = [ProgName '.exe "' sOutFileName '"' NotePadSwitchToMrf];
sysResult = system(sSysCmd);
% Abort because something went wrong if an error code was returned or an *.FER file was created.
assert(sysResult==0,['ERROR: ' sSysCmd ' returned ' num2str(sysResult)]);
assert(exist(FERfName, 'file')~=2,['ERROR: ' ProgName ' failed.  Check error message in file ' FERfName '.']);

% Return the path to its original state, if required:
if numel(MyPath)>0
    setenv('PATH', oldpath);
end


% **************** Display the MrF output file in the MATLAB editor window:
if ~NoEdit
    edit(FPRfName);
end

% Done with processing, so clean up files.
% Default is to delete RPT, LGF, and RPT but keep FPR
if (~SaveRPT) && exist(RPTfName, 'file')==2
    delete(RPTfName);
end
if (~SaveLGF) && exist(LGFfName, 'file')==2
    delete(LGFfName);
end
if (~SaveFBK) && exist(FBKfName, 'file')==2
    delete(FBKfName);
end
if KillFPR && exist(FPRfName, 'file')==2
    delete(FPRfName);
end

% **************** Nest functions start here ****************

    function WriteBetweenFac
        fprintf(LGFfile,'%d Between Ss Factor(s)\n',NBetweenFacs);
        for iFac=1:NBetweenFacs
            fprintf(LGFfile,'%s %d\n',BetweenFacs{iFac},BetweenLevels(iFac));
        end
    end % WriteBetweenFac

    function WriteWithinFac
        fprintf(LGFfile,'%d Within Ss Factor(s)\n',NWithinFacs);
        for iFac=1:NWithinFacs
            fprintf(LGFfile,'%s %d\n',WithinFacs{iFac},WithinLevels(iFac));
        end
    end % WriteWithinFac

end  % CallMrf


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

