function outDists = CondDistToBoxSkew(inTrials,sDV,CondSpecs,varargin)
    % Produce a list of "distance to box" lengths for all trials in inTrials,
    %   computed relative to the other trials in the same CondSpec combination.
    % outDists are computed by BoxplotCalcsSkewe:
    %   0 for scores between the 25th and 75th percentiles of the data.
    %   (score - 25th percentile) / IQRLo for scores below the 25th percentile (i.e., negative)
    %   (score - 75th percentile) / IQRHi for scores above the 55th percentile (i.e., positive)
    %  where IQRHi = 2 * (75th percentile - median) 
    %  Return NaN for any excluded trials.
    
    % Inputs:
    %
    %   inTrials  : table holding the trial-by-trial data for all subjects and conditions
    %   sDV       : name of the variable for which Z scores are to be computed
    %   CondSpecs : Other conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
    %
    % varargin options:
    %   Include/Exclude options passed through to indicate which trials should be included in
    %      computation of mean & sd for Z.  Trials that are _not_ included get Z scores of NaN.
    %
    % Outputs:
    %
    %   outDists : List of DistToBoxSkew values or NaN's.
    
    NinTrials = height(inTrials);
    outDists = NaN(NinTrials,1);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(CondLabels);
    
    % NEWJEFF: Still need error checking in case 25/75 PCTs cannot be computed.
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        DVs = inTrials.(sDV)(Indices);
        [~, ~, Dists2BoxSkew] = BoxplotCalcsSkew(DVs);
        outDists(Indices) = Dists2BoxSkew;
    end
    
end
