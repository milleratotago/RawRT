function [outResultTable, outDVName] = CondNs(inTrials,CondSpecs,varargin)
%
% Include/Exclude options passed through to SubTableIndices.

[wantProportions, varargin] = ExtractNamei({'p','proportions'},varargin);

% [inTrials, varargin] = MaybeSelect(inTrials,varargin{:})

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});

outDVName = UniqueVarname(outResultTable,'N');

outResultTable.(outDVName) = cellfun(@numel,mySubTableIndices);

if wantProportions
    ttl = sum(outResultTable.(outDVName));
    outResultTable.(outDVName) = outResultTable.(outDVName) / ttl;
end

outDVName = {outDVName};

end
