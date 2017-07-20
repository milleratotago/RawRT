function [outResultTable, outDVNames] = Condranksum(inTable,sX,sY,CondSpecs,varargin)
% Call the ranksum function for each combination of CondSpecs.
% (ranksum computes the Wilcoxon rank sum test for 2-sample data)
% sX and sY are strings that, when processed by eval, output the lists of X & Y values to be compared.
% Note that within these strings, the data table is always called "inTable" regardless of its name
% outside this function.  For example, suppose you had a trials table with a variable for RT
% and another variable called Compat to indicate whether trials were compatible or incompatible.
%   To compute rank sum tests for each subject, you could say:
%   Example: t = Condranksum(inTable,'inTable.RT(inTable.Compat==1)','inTable.RT(inTable.Compat==2)','SubNo')


% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the ranksum function}.
%   Example: t = Condranksum(inTable,'inTable.RT(inTable.Compat==1)','inTable.RT(inTable.Compat==2)',CondSpecs,'Parms',{'method','exact'})

[Parms, varargin] = ExtractNameVali('Parms',{},varargin);

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2,sX,sY,Parms{:});

% Break up and relabel the multiple output variables in the output table.
NDVsOut = 4;
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,'p');
outDVNames{2} = UniqueVarname(outResultTable,'h');
outDVNames{3} = UniqueVarname(outResultTable,'ranksum');
outDVNames{4} = UniqueVarname(outResultTable,'zval');
for i=1:NDVsOut
    outResultTable.(outDVNames{i}) = outResultTable.(outDVNames1{1})(:,i);
end

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

% Cannot be nested so that sDV1 and sDV2 are recognized.
function out = Compute(inTable,sX,sY,varargin)
x = eval(sX);
y = eval(sY);
[p,h,stats] = ranksum(x,y,varargin{:});
% Note that the output is a list of several component values:
out = [p h stats.ranksum stats.zval];
end

