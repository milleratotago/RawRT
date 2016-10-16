function [outTallTable, outResultTable, outDVName, AllStims, AllResps] = CondSRCrosstab(Trials,sStimVar,sRespVar,CondSpecs,varargin)
% For each combination of CondSpecs, for each value of the stimulus variable,
%  count the number of trials for which each of the possible responses is given.
% This function can be used for confusion matrices, psychometric function analysis, etc.
%
% Optional parameters:
%    'NoTall': Do not bother to compute outTallTable
%    Include/Exclude options passed through to SubTableIndices.
%
% Outputs:
%    outTallTable: This table has each count appearing in a different row, with labels for all of the CondSpecs and response.
%    outResultTable: This table has the counts appearing as a vector within a single SRCounts DV, in the order Cond1Resp1, Cond1Resp2, Cond1Resp3, ...Cond2Resp1, ...
%    outDVName:
%    AllStims: a list of all stimulus values that were found (across all conditions)
%    AllResps: a list of all response values that were found.


[NoTall, varargin] = ExtractNamei({'NoTall','No Tall'},varargin);

% Make lists of all the stimuli and responses across all the included trials.
AllIndices = SubTableIndices(Trials,{},varargin{:});  % A cell array containing a master list of all trials that will be included in this analysis.
AllIndices = AllIndices{1};  % The master list (as a vector rather than a cell).
AllStims = unique(Trials.(sStimVar)(AllIndices))';  % A list of all the different stimuli in these trials.
AllResps = unique(Trials.(sRespVar)(AllIndices))';  % A list of all the different responses in these trials.
NStims = numel(AllStims);
NResps = numel(AllResps);

% Construct NStims*NResps extra "fake" trials, one with each combination of stimuli & responses.
% These are used to ensure that the crosstab command always produces a NStims x NResps output table, even if some cells are empty in some conditions.
FakeStims = repmat(AllStims,1,NResps)';
FakeStims = sort(FakeStims);   % something like 1 1 1 2 2 2 3 3 3
FakeResps = repmat(AllResps,1,NStims)';   % something like 1 2 3 4 1 2 3 4 1 2 3 4

[mySubTableIndices, outResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});

NConds = height(outResultTable);

outDVName = UniqueVarname(outResultTable,'SRCounts');

NCounts = numel(AllStims) * numel(AllResps);

outResultTable.(outDVName) = zeros(NConds,NCounts);

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    Counts = crosstab([Trials.(sRespVar)(Indices); FakeResps],[Trials.(sStimVar)(Indices); FakeStims]);
    outResultTable.(outDVName)(iCond,:) = Counts(1:end) - 1;  % minus 1 because of Fakes
    % In the list of counts, Stim moves slower and Resp moves faster, so the successive counts are
    %  S1R1 S1R2 S1R3 ... S2R1 S2R2 S2R3 ...
end

outDVName = {outDVName};

if NoTall
    outTallTable = table;
else
    % Make an output table with columns for CondSpec indicators, Stim, Resp, and count.
    outTallTable = sortrows(repmat(outResultTable,NStims*NResps,1));
    SRCombs = allcomb(AllStims,AllResps);
    ManySRCombs = repmat(SRCombs,NConds,1);
    outTallTable.(sStimVar) = ManySRCombs(:,1);
    outTallTable.(sRespVar) = ManySRCombs(:,2);
    outTallTable.Count = reshape(outResultTable.SRCounts(:,:)',NConds*NStims*NResps,1);
    outTallTable.SRCounts = [];
end

end
