function ResultTable = CondDiff(Trials,sDVs,CondSpecs,sDifferenceSpec,PlusLevel,MinusLevel,varargin)
% For each combination defined by CondSpecs, compute the difference
% DifferenceSpec(PlusLevel) - DifferenceSpec(MinusLevel),
% averaging across any other (unspecified) dimensions of the Trials dataset.
%
% Include/Exclude options passed through to SubTableIndices.

% Make sure sDV is a cell array.
[sDVs, nDVs] = EnsureCell(sDVs);

sMean = ['Diff' sDifferenceSpec num2str(PlusLevel) 'vs'  num2str(MinusLevel)];

DiffWeights = zeros(1,numel(unique(Trials.(sDifferenceSpec))));
DiffWeights(PlusLevel) = 1;
DiffWeights(MinusLevel) = -1;

[ResultTable, sDVNames] = CondWeightedSum(Trials,sDVs,CondSpecs,sDifferenceSpec,DiffWeights,varargin{:});

for iDV = 1:nDVs
%   disp(['Change ' sDVNames{iDV} ' to ' [sDVs{iDV} sMean]]);
    ResultTable.Properties.VariableNames{sDVNames{iDV}} = [sDVs{iDV} sMean];
end

end
