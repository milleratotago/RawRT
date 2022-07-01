function [Prctiles, IQR, Dists2Box, IQRLo, IQRHi] = BoxplotCalcsSkew(DVs)
   % This is a version of BoxplotCalcs that seems more appropriate (to JOM)
   %  for identifying outliers with skewed datasets.
   % Specifically, Dists2Box are scaled relative to separate IQRLo/IQRHi
   %  values for values below the 25th percentile versus above 75th.
   % IQRLo & IQRHi are calculated as TWICE the distance from the relevant
   %  percentile to the median (doubling to make these comparable to IQR).
   %
   % For the vector of scores in DVs, compute values relevant for a boxplot:
   %  o 3 percentile values for 25, 50, 75 percentiles respectively.
   %  o Interquartile range IQR
   %  o Distance of each score outside the 25/75 bounds:
   %    negative distances indicate "below 25"
   %    positive distances indicate "above 75"
   %    zero distances indicate "between 25 & 75 (inclusive)"
   % NEWJEFF: Still need error checking in case 25/75 PCTs cannot be computed.
   Prctiles = prctileTies(DVs,[25, 50, 75]);
   This25Pct = Prctiles(1);
   This75Pct = Prctiles(3);
   IQR = This75Pct - This25Pct;
   Median = Prctiles(2);
   if nargout >= 3
      IQRLo = 2 * (Median - This25Pct);
      IQRHi = 2 * (This75Pct - Median);
      Dists2Box = zeros(size(DVs));
      below = DVs < This25Pct;
      Dists2Box(below) = (DVs(below) - This25Pct) / IQRLo;
      above = DVs > This75Pct;
      Dists2Box(above) = (DVs(above) - This75Pct) / IQRHi;
   end
end
