function [outResultTable, outDVNames] = CondCIs(inTrials,sDVs,CondSpecs,varargin)
% For each combination of CondSpecs, compute a 95\% t confidence interval for the mean of each sDV

% Or alpha
[confid, varargin] = ExtractNameVali('Conf',.95,varargin);

sDVs = EnsureCell(sDVs);

[outResultTable1, outDVNames1] = CondNs(inTrials,CondSpecs,varargin{:});
sN = outDVNames1{1};
[outResultTable2, outDVNames2] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,{@mean @std},varargin{:});
outResultTable = join(outResultTable1,outResultTable2);
outDVNames = [outDVNames1 outDVNames2];

sSqrtN = UniqueVarname(outResultTable,'SqrtN');
outResultTable.(sSqrtN) = sqrt(outResultTable.(sN));
df = outResultTable.(sN) - 1;

for iDV=1:numel(sDVs)
   sDV = sDVs{iDV};
   sMean = [sDV '_mean'];
   sSD = [sDV '_std'];
   tCrit = tinv(confid+(1-confid)/2,df);
   HalfWidth = outResultTable.(sSD) .* tCrit ./ outResultTable.(sSqrtN);
   sLower = [sDV 'LowerBound'];
   sUpper = [sDV 'UpperBound'];
   outResultTable.(sLower) = outResultTable.(sMean) - HalfWidth;
   outResultTable.(sUpper) = outResultTable.(sMean) + HalfWidth;
end
outResultTable.(sSqrtN) = [];

end % CondCIs

