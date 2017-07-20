function [outResultTable, outDVName] = CondFitlm(inTrials,sModel,CondSpecs,varargin)
% For each combination of CondSpecs, fit the model sModel using all rows with that combination.
%
% Optional arguments:
%   Include/Exclude options passed through to SubTableIndices.

[NPassThru, varargin, FirstPassThruArgPos] = ExtractNameVali('NPassThru',0,varargin);  % Save NPassThru arguments for passing to FunHandle
if NPassThru>0
    PassThruArgs = varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1);
    varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1) = [];
else
    PassThruArgs = {};
end

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDVName = UniqueVarname(outResultTable,'mdl');

outResultTable.(outDVName) = cell(height(outResultTable),1);

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    outResultTable.(outDVName){iCond} = fitlm(OneSubTable,sModel,PassThruArgs{:});
end
end


