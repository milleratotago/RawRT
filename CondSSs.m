function [outResultTable, outDVNames] = CondSSs(inTrials,sDVs,CondSpecs,varargin)  % NEWJEFF: No demo--does not work for arrays
   % Compute the sum of the squared values.

[sDVs, NDVs] = EnsureCell(sDVs);

[UseSDSuffix, varargin] = ExtractNamei({'UseSDSuffix' 'SDSuffix'},varargin);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@sqr,varargin{:});

if ~UseSDSuffix
   for iDV = 1:NDVs
       outResultTable.Properties.VariableNames{outDVNames{iDV}} = sDVs{iDV};
   end
   outDVNames = sDVs;
end

end

function x2 = sqr(x)
   x2 = x.^2;
end
