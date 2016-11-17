function outVals = CondRankProp(inTrials,sDV,CondSpecs,varargin)
% For each CondSpecs combination of conditions, rank the trials on inTable.(sDV),
%  then output Rank/N, where N is the number of trials in that condition.
% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable determining ranking
%   CondSpecs : Conditions to be kept separate when ranking (e.g., subject, task, etc)
%
% varargin options:
%   'AvgTies' to average the ranks of tied scores (e.g., give 3.5 for tied scores at ranks 3 & 4).
%   Include/Exclude options passed through.
%
% Outputs:
%
%   outVals : List indicating rank for each trial.

[AvgTies, varargin] = ExtractNamei('AvgTies',varargin);

NinTrials = height(inTrials);
outVals = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    TheseVals = inTrials.(sDV)(Indices);
    nItems = numel(TheseVals);
    if AvgTies
       rank_vector = tiedrank(TheseVals);
    else
       [~,~,rank_vector] = unique(TheseVals);
    end
    outVals(Indices) = rank_vector / nItems;
end

end
