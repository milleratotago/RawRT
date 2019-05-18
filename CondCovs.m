function [outResultTable, outDVNames] = CondCovs(inTable,sDV1,sDV2,CondSpecs,varargin)
% For each combination of CondSpecs, compute the covariance of SDV1 & sDV2
% across all rows with that combination.

% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the corr function}.
%   Example: t = CondCorrs(inTable,sDV1,sDV2,CondSpecs,'Parms',{'Type','Spearman'})
%   Note that the corr function accepts these optional parameters, e.g., rs = corr(x,y,'Type','Spearman');

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2,sDV1,sDV2);

% Break up and relabel the multiple output variables in the output table.
NDVsOut = 3; % r p
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,['Var_' sDV1]);
outDVNames{2} = UniqueVarname(outResultTable,['Cov_' sDV1 '_' sDV2]);
outDVNames{3} = UniqueVarname(outResultTable,['Var_' sDV2]);
for i=1:NDVsOut
    outResultTable.(outDVNames{i}) = outResultTable.(outDVNames1{1})(:,i);
end

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

% Cannot be nested so that sDV1 and sDV2 are recognized.
function out = Compute(inTable,sDV1,sDV2,varargin)
Cov = cov(inTable.(sDV1),inTable.(sDV2),varargin{:});
out = zeros(3,1);
out(1) = Cov(1,1);
out(2) = Cov(1,2);
out(3) = Cov(2,2);
end

