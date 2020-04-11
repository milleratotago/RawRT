function [outResultTable, outSelectedIndices] = CondSubsample(inTrials,SampleSize,CondSpecs,varargin)
% Make an output table with a random sample of trials from each condition indicated by CondSpecs.
% The number of rows in the sample (NSample) is controlled by SampleSize as follows (let NTotal be the number of
%   trials in each condition):
%   SampleSize >= +1: NSample = SampleSize.
%   0 < SampleSize < 1: NSample = round(SampleSize*NTotal)
%   SampleSize <= -1: NSample = NTotal+SampleSize.
%
% Include/Exclude options passed through to SubTableIndices.

mySubTableIndices = SubTableIndices(inTrials,CondSpecs,varargin{:});

outResultTable = table;
outSelectedIndices = zeros(0,0);

NConds = numel(mySubTableIndices);

if SampleSize >= 1
   SampleType = 1;
elseif SampleSize > 0
   SampleType = 2;
elseif SampleSize <= -1
   SampleType = 3;
else
   error('Illegal SampleSize parameter.');
end

% Selected = false(height(inTrials),1);

for iCond = 1:NConds
    RelevantIndices = mySubTableIndices{iCond};
    NTotal = numel(RelevantIndices);
    RandomRelevant = RelevantIndices(randperm(NTotal));
    switch SampleType
        case 1
            NSample = min(NTotal,SampleSize);
        case 2
            NSample = round(SampleSize*NTotal);
        case 3
            NSample = NTotal + SampleSize;
    end
    SelectedIndices = RandomRelevant(1:NSample);
    OneSubTable = inTrials(SelectedIndices,:);
%     Selected(SelectedIndices) = true;
    outResultTable = [outResultTable; OneSubTable(1:NSample,:)]; %#ok<AGROW>
    outSelectedIndices = [outSelectedIndices; SelectedIndices]; %#ok<AGROW>
end

end
