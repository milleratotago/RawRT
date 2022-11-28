function outPositionCounters = CondIthTrial(inTrials,CondSpecs,varargin)
    % Produce a list of 1/2/3/... to indicate the sequential position of each trial
    %  within the group of trials with its CondSpecs.
    
    % Inputs:
    %
    %   inTrials  : Table holding the trial-by-trial data for all subjects and conditions
    %   CondSpecs : Conditions to be kept separate when doing the splitting (e.g., subject, task, etc)
    %
    % varargin options:
    %   Include/Exclude options passed through.
    %
    % Outputs:
    %
    %   outPositionCounters : List of 1/2/3/... of sequence numbers
    
    NinTrials = height(inTrials);
    outPositionCounters = NaN(NinTrials,1);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(CondLabels);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        NPositions = numel(Indices);
        outPositionCounters(Indices) = 1:NPositions;
    end
    
end
