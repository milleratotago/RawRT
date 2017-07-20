function [outResultTable, outDVName] = CondNs(inTrials,CondSpecs,varargin)
%
% Include/Exclude options passed through to SubTableIndices.

% [inTrials, varargin] = MaybeSelect(inTrials,varargin{:})

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});

outDVName = UniqueVarname(outResultTable,'N');

outResultTable.(outDVName) = cellfun(@numel,mySubTableIndices);

outDVName = {outDVName};

end
