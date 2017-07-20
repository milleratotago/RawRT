function [outResultTable, outDVNames] = Condttest2(inTable,sX,sY,CondSpecs,varargin)
% Call the ttest2 function for each combination of CondSpecs.
% sX and sY are strings that, when processed by eval, output the lists of X & Y values to be compared.
% Note that within these strings, the data table is always called "inTable" regardless of its name
% outside this function.  For example, suppose you had a trials table with a variable for RT
% and another variable called Compat to indicate whether trials were compatible or incompatible.
%   To compute t-tests for each subject, you could say:
%   Example: t = Condttest2(inTable,'inTable.RT(inTable.Compat==1)','inTable.RT(inTable.Compat==2)','SubNo')


% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the ttest2 function}.
%   Example: t = Condttest2(inTable,'inTable.RT(inTable.Compat==1)','inTable.RT(inTable.Compat==2)',CondSpecs,'Parms',{'Vartype','unequal'})

[Parms, varargin] = ExtractNameVali('Parms',{},varargin);

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2,sX,sY,Parms{:});

% Break up and relabel the multiple output variables in the output table.
NDVsOut = 7;
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,'h');
outDVNames{2} = UniqueVarname(outResultTable,'p');
outDVNames{3} = UniqueVarname(outResultTable,'LowerCI');
outDVNames{4} = UniqueVarname(outResultTable,'UpperCI');
outDVNames{5} = UniqueVarname(outResultTable,'t');
outDVNames{6} = UniqueVarname(outResultTable,'df');
outDVNames{7} = UniqueVarname(outResultTable,'sd');
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
[h,p,ci,stats] = ttest2(x,y,varargin{:});
% Note that the output is a list of several component values:
out = [h p ci(1) ci(2) stats.tstat stats.df stats.sd];
end

