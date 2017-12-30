function [FinalPool, Report, NExclude, PctExclude] = ExcludeFromPool(StartingPool,ExclusionDescriptionStr,varargin)
% Set a list of 0/1 indicators to indicate whether each trial should be included in an analysis.
%
% Inputs:
%
% StartingPool: A set of 0/nonzero indicators, one per trial,
%  indicating whether each trial is included in the starting pool.
%
% ExclusionDescriptionStr: A string to be printed out as a description/label
%  for the exclusion(s) being implemented.
%
% varargin: A set of 0/nonzero indicators, where nonzero indicates
%  that a trial should be excluded.
%
% Optional input: 'Silent' => do not display the report.
%
% Outputs:
%
% FinalPool: A revised set of 0/nonzero indicators, one per trial,
%  indicating whether each trial is included in the final pool.
%  Note that FinalPool values equal StartingPool values except
%  for the trials that are excluded, whose values are set to zero.
%
% Report: A cell array of strings containing a summary of
%  how many trials were excluded (same as is printed out).
%
% NExclude: The number of trials excluded.
%
% PctExclude: The percentage of the starting pool that was excluded.

FinalPool = StartingPool;

[Silent, varargin] = ExtractNamei('Silent',varargin);

NCriteria = numel(varargin);  % Number of criteria used to exclude criteria.

NStartingPool = sum(~StartingPool==0);

% Create some arrays to hold counts generated at each step:
NExclude = zeros(NCriteria,1);     % Number of starting pool trials excluded by each criterion.

for iCrit=1:NCriteria
   ThisCrit = varargin{iCrit};
   NExclude(iCrit) = sum(~StartingPool==0&~ThisCrit==0);     % N of original candidates that fail this criterion
   FinalPool(~ThisCrit==0) = 0;
end

% Make & display a report from here.

% Compute some other values that will be reported.
PctExclude = 100 * NExclude/NStartingPool;
NFinalPool = sum(~FinalPool==0);

TtlNExclude = NStartingPool - NFinalPool;
TtlPctExclude = 100 * TtlNExclude / NStartingPool;

sPrefix = '* ';  % Prefix appearing at the beginning of each line of the report.
sHdr0 = sprintf('\n%s',[ sPrefix ExclusionDescriptionStr]);
sHdr1  = sprintf('%s',[sPrefix ' Starting pool of ' num2str(NStartingPool) ' trials:']);
sHdr2  = sprintf('%s',[sPrefix '      Criterion  NExclude  %Exclude']);
sDelim = sprintf('%s',[sPrefix '-----------------------------------']);

sLineFmt = '%s%15s%10d%10.2f';   % Format of each line writing criterion, NExclude, etc

Report = [{sHdr0} {sHdr1} {sHdr2} {sDelim}];
for iCrit=1:NCriteria
   sCrit = ['Criterion ' num2str(iCrit)];
   sLine = sprintf(sLineFmt,sPrefix,sCrit,NExclude(iCrit),PctExclude(iCrit));
   Report = [Report {sLine}];
end

sTotal = sprintf(sLineFmt,sPrefix,'Total Excluded',TtlNExclude,TtlPctExclude);
sFinal  = sprintf('%s\n',[sPrefix ' Final pool of ' num2str(NFinalPool) ' trials.']);

Report = [Report {sDelim} {sTotal} {sDelim} {sFinal}];

if ~Silent
    s = strjoin(Report,'\n');  % Display the report.
    disp(s);
end

end

