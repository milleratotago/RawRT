function [outResultTable, outDVNames] = CondRMItable(inTrials,sDV,sRMISpec,CondSpecs,Prctiles,SOA,varargin)
% Compute table of percentile values in 4 conditions for race model inequality analysis.
%
% Inputs:
%
%   inTrials  : A table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of RT variable in inTrials
%   sRMISpec  : name of variable in inTrials that is coded 1/2/3 to indicate single1, single2, redundant
%               (trials with values other than 1/2/3 are ignored)
%   CondSpecs : Other conditions to be kept separate when computing CDFs (e.g., Subject, Task, Intensity)
%   Prctiles  : Vector of numbers 0-1 indicating the cumulative proportions at which to check the RMI
%             : (If max(Prctiles)>1, it is assumed that the numbers are percentiles instead of proportions.)
%   SOA       : time from onset of Single1 to onset of Single2; negative means Single2 was first
%
% varargin options:
%
%   Include/Exclude options passed through as usual.
%
%   'KTTsimple' : performs the "kill-the-twin" analysis for a simple RT task.
%                 If this option is specified, then the variable sRMISpec should be coded 0-3 rather than 1-3,
%                 with a value of 0 indicating the catch trials.  The value of sDV should be some very large
%                 number for these trials.
%                 When this option is specified, make sure that the relevant catch trials are NOT excluded
%                 (e.g., excluded by analyzing correct only or by excluding trials with large RTs)
%                 by the Include/Exclude specification.
%                 
%   'SaveNaNs' indicates that the output should include rows for which all computed values are NaNs.
%             By default these all-NaN rows are deleted.
%
% Outputs:
%
%   CDFsTable : Labelled by CondSpecs, Single1/Single2/Redundant/SumSingle; DVs = Prctiles
%               If KTTsimple is specified, then SumSingle is actually SumSingle-CatchCDF to kill twins.

[KTTsimple, varargin] = ExtractNamei('KTTsimple',varargin);
[SaveNaNs, varargin] = ExtractNamei('SaveNaNs',varargin);
DropNaNs = ~SaveNaNs;

NPcts = numel(Prctiles);
if max(Prctiles)>1
   Prctiles = Prctiles/100;
end
if (min(Prctiles)<=0) || (max(Prctiles)>=1)
    error('Prctiles must be greater than 0 and less than 1')
end

% Some "condition" names:
NSglRedConds = 4;
CondNames = {'Single1' 'Single2' 'Redundant' 'SumSingle'};

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(outResultTable);

% Make variables to hold Percentiles
for iSRCond = 1:NSglRedConds
    outResultTable.(CondNames{iSRCond}) = zeros(NConds,NPcts);
end

NaNIndices = [];  % Keep a list of any rows that have all NaNs.

for iCond=1:NConds
    Indices = mySubTableIndices{iCond};
    TheseTrials = inTrials(Indices,:);
    aX = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==1);
    aY = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==2);
    aRed = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==3);
    if KTTsimple
       aCatch = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==0);
    end
    %    aX=sort(aX);
    %    aY=sort(aY);
    %    aRed=sort(aRed);
    if numel(aX)*numel(aY)*numel(aRed) == 0
        PctsX = NaN(numel(Prctiles),1);
        PctsY = PctsX;
        PctsRed = PctsX;
        PctsSum = PctsX;
    else
        [PctsX, PctsY, PctsRed, PctsSum] = RaceModel(aX',aY',aRed',Prctiles,SOA);
        if isnan(PctsX(1))
            disp('Problem with RTs for condition X:');
            aX
        end
        if ~isnan(PctsX(1))&&isnan(PctsY(1))
            disp('Problem with RTs for condition Y:');
            aY
        end
        if ~isnan(PctsX(1))&&~isnan(PctsY(1))&&isnan(PctsRed(1))
            disp('Problem with RTs for condition Z:');
            aRed
        end
    end
    outResultTable.(CondNames{1})(iCond,:) = PctsX;
    outResultTable.(CondNames{2})(iCond,:) = PctsY;
    outResultTable.(CondNames{3})(iCond,:) = PctsRed;
    outResultTable.(CondNames{4})(iCond,:) = PctsSum;
    if sum(isnan(PctsX))==NPcts&&sum(isnan(PctsY))==NPcts&&sum(isnan(PctsRed))==NPcts&&sum(isnan(PctsSum))==NPcts
        NaNIndices = [NaNIndices iCond];
    end
end

if DropNaNs
    outResultTable(NaNIndices,:) = [];
end

% sCond = UniqueVarname(outResultTable,'Cond');
sScores  = UniqueVarname(outResultTable,'Pct');
outResultTable = stack(outResultTable,CondNames,'NewDataVariableName',sScores,'IndexVariableName',sRMISpec);
outResultTable.(sRMISpec) = double(ordinal(outResultTable.(sRMISpec),{},CondNames));

outDVNames = cell(NPcts,1);
for iPct = 1:NPcts
    PctSuffix = num2str(Prctiles(iPct)*1000,'%03.0f');
    outDVNames{iPct} = [sDV '_' PctSuffix];
end

for iPct = 1:NPcts
    outResultTable.(outDVNames{iPct}) = outResultTable.(sScores)(:,iPct);
end

% outResultTable.(sScores) = [];

end
