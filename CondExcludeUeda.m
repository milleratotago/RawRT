function [TooLo, TooHi] = CondExcludeUeda(inTrials,sDV,CondSpecs,varargin)
    % Compute a vector of scores indicating whether each trial in inTrials would be excluded
    %   using Ueda's procedure.
    % Remember UedaOutliers checks all possible combinations of throwing away 1:smax scores
    %   at each end of the distribution: The varargin parameters HalfCutoff and smaxMaxProp
    %   of this function allow some control over how smax changes with the number of trials.
    % If there are less than HalfCutoff trials (default 40), smax is allowed to go up to
    %   the maximum possible (around NTrials/2).
    % If there are more than HalfCutoff trials (default 40), smax is allowed to go up to
    %   HalfCutoff/2+smaxMaxProp*(NTrials-HalfCutoff) trials, with 0.15 as the default smaxMaxProp.
    %
    % varargin:
    %   'HalfCutoff': a cutoff N of data values such that smax may be limited if there are more than this.
    %   'smaxMaxProp': 1 or 2 element vector indicating the maximum proportion of scores
    %      at both ends or the low/hi ends that should be considered for exclusion.
    %      These upper limits are only applied if the number of data points exceed NCutoff.
    %   Include/Exclude options passed through.
    %
    % Outputs: logical vectors TooLo & TooHi corresponding to the sequence of data values in sDV:
    %   1 = Excluded
    %   0 = considered but not excluded, or not considered at all
    
    [HalfCutoff, varargin] = ExtractNameVali('HalfCutoff',40,varargin);
    [smaxMaxProp, varargin] = ExtractNameVali('smaxprop',0.1,varargin);
    
    TooLo = false(height(inTrials),1);
    TooHi = false(height(inTrials),1);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(CondLabels);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        OneDV = OneSubTable.(sDV);
        
        thisN = numel(OneDV);
        smax = GetSMax(thisN);
        if smax == 0
            thisTooLow = false(thisN,1);
            thisTooHi = thisTooLow;
        else
            [thisTooLow, thisTooHi] = UedaOutliers(OneDV,smax);
        end
        
        TooLo(Indices) = thisTooLow;
        TooHi(Indices) = thisTooHi;
    end
    
    function smax = GetSMax(thisN)
        if thisN < 4
            smax = 0;
        elseif thisN <= HalfCutoff
            smax = floor(thisN/2) - 1;  % 4,1  5,1  6,2  7,2   8,3  9,3
        else
            smax = floor(HalfCutoff/2) - 1 + round((thisN-HalfCutoff)*smaxMaxProp);
        end
    end
    
end % CondExcludeUeda
