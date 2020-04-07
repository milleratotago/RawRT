function [ Prctiles ] = prctileTies( InputVector, PrctilesWanted )
%Compute the requested percentile values using the data provided in the input vector.
% This is the same as MATLAB's prctile function except when there are ties.  When there are ties, this function eliminates the "flat spots" in the cumulative
% frequency polygon that prctile gives.  Such flat spots are undesirable when estimating a continuous probability distribution, where ties might arise
% due to e.g. rounding.

% More technically, this function handles ties as described by Ulrich, Miller, & Schroeter (2007, Behavior Research Methods, vol. 39 (2), 291-302).
% Example:
% >> Xdata = [5    10    15    15    15    15    20    25]
% >> prctile(Xdata,30:5:70)
% ans =
%         14.5           15           15           15           15           15           15           15         15.5
% >> prctileTies(Xdata,30:5:70)
% ans =
%         11.8         12.6         13.4         14.2           15         15.8         16.6         17.4         18.2

NWanted = numel(PrctilesWanted);

Prctiles = nan(1,NWanted);

if length(InputVector) < NWanted
    return;
end

[UniqueVals, Counts, CumCounts] = UniqueCounts( InputVector );

NInputs = CumCounts(end);

CumPcts = (CumCounts - Counts/2) * 100 / NInputs;

if (PrctilesWanted(1)<CumPcts(1))||(PrctilesWanted(end)>CumPcts(end))
    % NEWJEFF: KILLED THE ERROR MESSAGE FOR SIMULATIONS disp('Not enough distinct values to compute requested percentiles!');
    return;
end

for i=1:NWanted
    UpperIdx = find(CumPcts>PrctilesWanted(i),1);
    LowerIdx = UpperIdx - 1;
    Prctiles(i) = UniqueVals(LowerIdx) + (UniqueVals(UpperIdx) - UniqueVals(LowerIdx)) * (PrctilesWanted(i) - CumPcts(LowerIdx)) / (CumPcts(UpperIdx)- CumPcts(LowerIdx));
end

end

