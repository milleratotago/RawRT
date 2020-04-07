function [outIndices, outCondLabels] = SubTableIndices(Trials,CondSpecs,varargin)
%
% Find the indicated subset of trials for each combination of the conditions indicated by CondSpecs.
%
% NConds subsets will be found, where NConds is the number of different combinations of CondSpecs.
% Note that some subsets may be empty if not all combinations of CondSpecs are present.
%
% outIndices is a cell array of NConds cells. Each cell contains a 1-dimensional
%  array of integers indicating the row outIndices within the input array Trials
%  of the different trials included in the iCond'th subset.
%
% outCondLabels is a table with NConds rows and NCondSpecs columns showing
%  the combination of the NCondSpecs conditions for each of the NConds subsets.
%
% Optional arguments:
%   Include/Exclude selection criteria.

[IncludeIndicators, outArg] = ExtractNameVali({'Include','IncludeOnly'},ones(height(Trials),1),varargin);

[ExcludeIndicators, outArg] = ExtractNameVali({'Exclude','ExcludeOnly'},zeros(height(Trials),1),outArg);

if numel(CondSpecs)==0
    % Include all selected trials in a single condition called 'All'.
    NConds = 1;
    outIndices = cell(NConds,1);
    outIndices{1} = find(IncludeIndicators&~ExcludeIndicators);
    tempoutCondLabels.All = ones(NConds,1);
    outCondLabels = struct2table(tempoutCondLabels);
    return
end

[CondSpecs, NCondSpecs] = EnsureCell(CondSpecs);

[NConds, NSpecs, ~, ~, CondCombos, ~ ] = CondList(Trials(IncludeIndicators&~ExcludeIndicators,:),CondSpecs);

% Make columns to hold the condition labels:
for iSpec=1:NCondSpecs
    tempoutCondLabels.(CondSpecs{iSpec}) = zeros(NConds,1);
end

% Make a cell array to hold the outIndices:
outIndices = cell(NConds,1);

for iCond=1:NConds
    
    % Identify this condition in terms of its combination of CondSpecs, and save
    % the values of these specifications as named fields in the tempoutCondLabels structure.
    sTarg = '';
    for iSpec=1:NSpecs
        tempoutCondLabels.(CondSpecs{iSpec})(iCond) = CondCombos(iCond,iSpec);
%       ThisSpec = ['Trials.' CondSpecs{iSpec} '==' num2str(CondCombos(iCond,iSpec))];  % This has problems with floating point precision.
        ThisSpec = ['abs(Trials.' CondSpecs{iSpec} '-' num2str(CondCombos(iCond,iSpec)) ')<=eps'];
        sTarg = [sTarg ThisSpec];
        if iSpec<NSpecs
            sTarg = [sTarg '&'];
        end
    end
%     sTarg
%     size(eval(sTarg))  % NWJEFF
%     size(IncludeIndicators)
%     size(ExcludeIndicators)
    outIndices{iCond} = find(eval(sTarg)&IncludeIndicators&~ExcludeIndicators);
end

outCondLabels = struct2table(tempoutCondLabels);

end
