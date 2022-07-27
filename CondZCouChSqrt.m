function ZofYs = CondZCouChSqrt(inTrials,sDV,CondSpecs,varargin)
    % Compute a vector of scores indicating the ZCouChSqrt score for each trial in inTrials
    % by the transformation approach in CousineauChartier2010, starting at Eqn (1).
    % varargin: Include/Exclude options passed through.
    
    ZofYs = nan(height(inTrials),1);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(CondLabels);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        OneDV = OneSubTable.(sDV);
        
        ZofYs(Indices) = ZCouChSqrt(OneDV);
        
    end
    
end % CondZCouChSqrt
