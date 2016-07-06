function [UniqueVals Counts CumCounts] = UniqueCounts( InputVector )
% Return a sorted list of the unique values in a vector,
% the number of occurrences of each value,
% and the cumulative sum of the numbers of occurrences.

UniqueVals = unique(InputVector);

Counts = histc(InputVector,UniqueVals);

CumCounts = cumsum(Counts);

end

