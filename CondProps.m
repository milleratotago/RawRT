function [outResultTable, outDVName] = CondProps(inTrials,CondSpecs,varargin)
% Compute the proportion of trials in each condition
% Include/Exclude options passed through to SubTableIndices.

% [inTrials, varargin] = MaybeSelect(inTrials,varargin{:})

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});

Ns = cellfun(@numel,mySubTableIndices);

Total = sum(Ns);

outDVName = UniqueVarname(outResultTable,'Prop');

outResultTable.(outDVName) = Ns / Total;

outDVName = {outDVName};

end
