function [outResultTable, outDVNames] = CondMeans(inTrials,sDVs,CondSpecs,varargin)
%
% Include/Exclude options passed through to SubTableIndices.
% 'UseMeanSuffix' says to change the name of each sDV to sDVmean

[sDVs, NDVs] = EnsureCell(sDVs);

[UseMeanSuffix, varargin] = ExtractNamei({'UseMeanSuffix' 'MeanSuffix'},varargin);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@mean,varargin{:});

if ~UseMeanSuffix
   for iDV = 1:NDVs
       outResultTable.Properties.VariableNames{outDVNames{iDV}} = sDVs{iDV};
   end
   outDVNames = sDVs;
end

end
