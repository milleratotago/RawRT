function theseMADZs = MADZs(inDVs)
   ThisMedian = median(inDVs);
   ThisMAD   = mad(inDVs,1);  % 1 tells MATLAB's mad function to compute median of absolute deviations; 0 would request mean.
   theseMADZs = (inDVs - ThisMedian) / ThisMAD;
end
