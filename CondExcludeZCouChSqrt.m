function [TooLo, TooHi] = CondExcludeZCouChSqrt(inTrials,sDV,CondSpecs,Zcutoff,varargin)
    % Compute a vector of scores indicating whether each trial in inTrials would be excluded
    % by the transformation approach in CousineauChartier2010, starting at Eqn (1).
    % varargin: Include/Exclude options passed through.
    %
    % Logical output vectors TooLo & TooHi:
    %   1 = Excluded
    %   0 = considered but not excluded, or not considered at all
    
    TooLo = false(height(inTrials),1);
    TooHi = false(height(inTrials),1);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,OtherArgs{:});
    
    NConds = height(CondLabels);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        OneDV = OneSubTable.(sDV);
        
        ZofYs = ZCouChSqrt(OneDV);
        
        TooLo(Indices) = ZofYs < -Zcutoff;
        TooHi(Indices) = ZofYs >  Zcutoff;
    end
    
end % CondExcludeZCouChSqrt
