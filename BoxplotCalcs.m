function [Prctiles, IQR, Dists2Box] = BoxplotCalcs(DVs)
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
   if nargout >= 3
      Dists2Box = zeros(size(DVs));
      below = DVs < This25Pct;
      Dists2Box(below) = (DVs(below) - This25Pct) / IQR;
      above = DVs > This75Pct;
      Dists2Box(above) = (DVs(above) - This75Pct) / IQR;
   end
end
