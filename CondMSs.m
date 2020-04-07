function [outResultTable, outDVNames] = CondMSs(inTrials,sDVs,CondSpecs,varargin)  % NEWJEFF: No demo--does not work for arrays
   % Compute the mean of the squared values.

[sDVs, NDVs] = EnsureCell(sDVs);

[UseMSSuffix, varargin] = ExtractNamei({'UseMSSuffix' 'MSSuffix'},varargin);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@meansqr,varargin{:});

if ~UseMSSuffix
   for iDV = 1:NDVs
       outResultTable.Properties.VariableNames{outDVNames{iDV}} = sDVs{iDV};
   end
   outDVNames = sDVs;
end

end

