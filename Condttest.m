function [outResultTable, outDVNames] = Condttest(inTable,sDV1,sDV2,CondSpecs,varargin)
% Call the ttest function for each combination of CondSpecs.
% For paired scores, specify both sDV1 and sDV2
% For a single score, specify sDV2 as ''

% Optional parameter: 'Parms',{CellArray of optional parms to be passed to the ttest function}.
%   Example: t = Condttest(inTable,sDV1,sDV2,CondSpecs,'Parms',{'Tail','left'})

[Parms, varargin] = ExtractNameVali('Parms',{},varargin);

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Compute,varargin{:},'NPassThru',2,sDV1,sDV2,Parms{:});

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
function out = Compute(inTable,sDV1,sDV2,varargin)
if numel(sDV2)==0
    [h,p,ci,stats] = ttest(inTable.(sDV1),varargin{:});
else
    [h,p,ci,stats] = ttest(inTable.(sDV1),inTable.(sDV2),varargin{:});
end
% Note that the output is a list of several component values:
out = [h p ci(1) ci(2) stats.tstat stats.df stats.sd];
end

