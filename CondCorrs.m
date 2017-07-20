function [outResultTable, outDVNames] = CondCorrs(inTable,sDV1,sDV2,CondSpecs,varargin)
% For each combination of CondSpecs, compute the correlation of SDV1 & sDV2
% across all rows with that combination.
% NewJeff: Add 'permute' option to estimate p based on random permutations.

% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the corr function}.
%   Example: t = CondCorrs(inTable,sDV1,sDV2,CondSpecs,'Parms',{'Type','Spearman'})
%   Note that the corr function accepts these optional parameters, e.g., rs = corr(x,y,'Type','Spearman');

[Parms, varargin] = ExtractNameVali('Parms',{},varargin);

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2+numel(Parms),sDV1,sDV2,Parms{:});

% Break up and relabel the multiple output variables in the output table.
NDVsOut = 2; % r p
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,'r');
outDVNames{2} = UniqueVarname(outResultTable,'p');
for i=1:NDVsOut
    outResultTable.(outDVNames{i}) = outResultTable.(outDVNames1{1})(:,i);
end

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

% Cannot be nested so that sDV1 and sDV2 are recognized.
function out = Compute(inTable,sDV1,sDV2,varargin)
[r,p] = corr(inTable.(sDV1),inTable.(sDV2),varargin{:});
out = [r p];
end

