function figs = PlotRMICDFs(inRMItable,sRMISpec,CondSpecs,Prctiles,varargin)
% Plot percentile values in 4 conditions for race model inequality analysis.
% This is done separately for each combination of CondSpecs.
%
% Inputs:
%
%   inRMItable: A table made by CondRMItable. It should include one variable called sRMISpec with the
%               condition codes 1-4 for single1,single2,red,sumsingle and a variable called Pct
%               with the percentile values.  There may also be other variables indicating conditions
%               to be distinguished (i.e., CondSpecs), and averages will be computed across the other
%               variables (e.g., SubNo).
%   sRMISpec  : name of variable in inRMItable that is coded 1/2/3/4 to indicate single1, single2, redundant, sumsingle
%               (trials with values other than 1/2/3/4 are ignored)
%   CondSpecs : Other conditions to be kept separate when plotting CDFs (e.g., Task, Intensity)
%   Prctiles  : Vector of numbers 0-1 indicating the cumulative proportions at which CDF values were computed
%             : (If max(Prctiles)>1, it is assumed that the numbers are percentiles instead of proportions.)
%
% varargin options:
%
%   Include/Exclude options passed through as usual.
%
% Outputs:
%
%   figs : the handle(s) of the figure(s) produced when 'plot' is requested.

% Vincentize: Do this before calling Plot
% outResultTable = CondMeans(inRMItable,'Pct',CondSpecs);

[mySubTableIndices, outResultTable] = SubTableIndices(inRMItable,CondSpecs,varargin{:});

NConds = height(outResultTable);

sDV = 'Pct';

for iCond=1:NConds
    Indices = mySubTableIndices{iCond};
    TheseTrials = inRMItable(Indices,:);
    aX = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==1,:);
    aY = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==2,:);
    aRed = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==3,:);
    aSumSgl = TheseTrials.(sDV)(TheseTrials.(sRMISpec)==4,:);
    figs(iCond) = figure;
    plot(aX,Prctiles,aY,Prctiles,aRed,Prctiles,aSumSgl,Prctiles);
end

end
