function [outResultTable, outDVNames, CenMoms] = CondCenMoment(inTrials,sDVs,CondSpecs,NMoment,varargin)
% NEWJEFF: Note 3rd output argument with values; this is convenient & should be used elsewhere (eg CondMeans)
% Include/Exclude options passed through to SubTableIndices.

[sDVs, NDVs] = EnsureCell(sDVs);

[UseMeanSuffix, varargin] = ExtractNamei({'UseMeanSuffix' 'MeanSuffix'},varargin);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@obscenmoment,'NPassThru',1,NMoment,varargin{:});

%NEWJEFF: Maybe relabel the output DVs to include NMoment.
%oldStrLabel = 'CenMoment';
%newStrLabel = ['CenMoment' num2str(NMoment)];
%   for iDV = 1:NDVs
%       outResultTable.Properties.VariableNames{outDVNames{iDV}} = sDVs{iDV};
%   end
%   outDVNames = sDVs;

CenMoms = outResultTable{:,outDVNames};

end
