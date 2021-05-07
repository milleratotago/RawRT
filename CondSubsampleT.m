function [outResultTable, outSelectedIndices] = CondSubsampleT(inTrials,NTrials,CondSpecs,varargin)
% Make an output table with a random sample of trials from each condition indicated by CondSpecs.
% Use all of the subjects.
% The number of rows in the sample (NSample) is controlled by NTrials as follows (let NTotal be the number of
%   trials in each condition):
%   NTrials >= +1: NSample = NTrials.
%   0 < NTrials < 1: NSample = round(NTrials*NTotal)
%   NTrials <= -1: NSample = NTotal+NTrials.
%
% Include/Exclude options passed through to SubTableIndices.

mySubTableIndices = SubTableIndices(inTrials,CondSpecs,varargin{:});

outResultTable = table;
outSelectedIndices = zeros(0,0);

NConds = numel(mySubTableIndices);

if NTrials >= 1
   SampleType = 1;
elseif NTrials > 0
   SampleType = 2;
elseif NTrials <= -1
   SampleType = 3;
else
   error('Illegal NTrials parameter.');
end

% Selected = false(height(inTrials),1);

for iCond = 1:NConds
    RelevantIndices = mySubTableIndices{iCond};
    NTotal = numel(RelevantIndices);
    RandomRelevant = RelevantIndices(randperm(NTotal));
    switch SampleType
        case 1
            NSample = min(NTotal,NTrials);
        case 2
            NSample = round(NTrials*NTotal);
        case 3
            NSample = NTotal + NTrials;
    end
    SelectedIndices = RandomRelevant(1:NSample);
    OneSubTable = inTrials(SelectedIndices,:);
%     Selected(SelectedIndices) = true;
    outResultTable = [outResultTable; OneSubTable(1:NSample,:)]; %#ok<AGROW>
    outSelectedIndices = [outSelectedIndices; SelectedIndices]; %#ok<AGROW>
end

end
