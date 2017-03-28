function [ t, ViolCDF, figs ] = CondRMIViol(inRMItable,sRMISpec,CondSpecs,Prctiles,varargin)
% For each combination of CondSpecs, compute (and optionally plot)
%  o a range of t values over which RMI violations can be computed, and
%  o the size of the RMI violations at each of the t values.
%
% Inputs:
%   Prctiles: the percentile points for which the RTs were estimated (e.g., 5, 15, 25, ..95).
%   SumSingle: the RT at which  NEWJEFF: NOT DONE

[WantPlot, varargin] = ExtractNamei('Plot',varargin);

[mySubTableIndices, outResultTable] = SubTableIndices(inRMItable,CondSpecs,varargin{:});

NConds = height(outResultTable);

sDV = 'Pct';

% Make cell arrays to hold outputs
t = cell(1,NConds);
ViolCDF = cell(1,NConds);
% figs = cell(1,NConds);

if WantPlot
    figs = figure;
    hold on
end

for iCond=1:NConds
    Indices = mySubTableIndices{iCond};
    TheseTrials = inRMItable(Indices,:);
    Red = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==3,:);
    SumSingle = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==4,:);
    % find the range of t's where the curves overlap:
    tMin = max(Red(1),SumSingle(1));
    tMin = ceil(tMin);
    tMax = min(Red(end),SumSingle(end));
    tMax = floor(tMax);
    t{iCond} = tMin:tMax;  % The list of time points at which CDF differences will be computed.
    
    SplineRedCDF = spline(Red,Prctiles,t{iCond});  % The CDF values of the redundant curve at the indicated t values
    SplineSumSglCDF = spline(SumSingle,Prctiles,t{iCond});  % The CDF values of the sum-single curve at the indicated t values
    ViolCDF{iCond} = SplineRedCDF - SplineSumSglCDF;  % These are the differences in CDFs between the two curves at each value of t
    if WantPlot
        % figs{iCond} = figure;
        plot(t{iCond},ViolCDF{iCond});
        xlabel('RT');
        ylabel('RMI Violation %');
    end
end % for iCond

end

