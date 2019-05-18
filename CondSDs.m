function [outResultTable, outDVNames] = CondSDs(inTrials,sDVs,CondSpecs,varargin)

[sDVs, NDVs] = EnsureCell(sDVs);

[UseSDSuffix, varargin] = ExtractNamei({'UseSDSuffix' 'SDSuffix'},varargin);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@std,varargin{:});

if ~UseSDSuffix
   for iDV = 1:NDVs
       outResultTable.Properties.VariableNames{outDVNames{iDV}} = sDVs{iDV};
   end
   outDVNames = sDVs;
end

end
