function [outResultTable, outDVNames] = Condsignrank(inTable,sDV1,sDV2,CondSpecs,varargin)
% Call the signrank function for each combination of CondSpecs.
% (signrank computes the Wilcoxon signed rank test for 1-sample or paired data)
% For paired scores, specify both sDV1 and sDV2
% For a single score, specify sDV2 as ''

% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the signrank function}.
%   Example: t = Condsignrank(inTable,sDV1,sDV2,CondSpecs,'Parms',{'Tail','left'})

[Parms, varargin] = ExtractNameVali('Parms',{},varargin);

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2,sDV1,sDV2,Parms{:});

% Break up and relabel the multiple output variables in the output table.
NDVsOut = 4;
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,'p');
outDVNames{2} = UniqueVarname(outResultTable,'h');
outDVNames{3} = UniqueVarname(outResultTable,'zval');
outDVNames{4} = UniqueVarname(outResultTable,'signedrank');
for i=1:NDVsOut
    outResultTable.(outDVNames{i}) = outResultTable.(outDVNames1{1})(:,i);
end

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

% Cannot be nested so that sDV1 and sDV2 are recognized.
function out = Compute(inTable,sDV1,sDV2,varargin)
if numel(sDV2)==0
    [p,h,stats] = signrank(inTable.(sDV1),varargin{:});
else
    [p,h,stats] = signrank(inTable.(sDV1),inTable.(sDV2),varargin{:});
end
% Note that the output is a list of several component values:
if isfield(stats,'zval')
    thisz = stats.zval;  % Only returns z for largish samples.
else
    thisz = nan;
end
out = [p h thisz stats.signedrank];
end

