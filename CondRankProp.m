function outVals = CondRankProp(inTrials,sDV,CondSpecs,varargin)
% For each CondSpecs combination of conditions, rank the trials on inTable.(sDV),
%  then output Rank/N, where N is the number of trials in that condition.
%
% *** SPECIFY VARARGIN 'Adjust' if you want %ile estimates 0.5/N to N-0.5/N ***
%
% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable determining ranking
%   CondSpecs : Conditions to be kept separate when ranking (e.g., subject, task, etc)
%
% varargin options:
%   'Adjust' to subtract 1/2N from all outputs so that the outputs go from 0.5/N to (N-0.5)/N
%     instead of 1 to N.
%   'NoAvgTies' to rank only unique scores, so the maximum rank may be less than the total number of scores.
%     The default behavior is to average the ranks of tied scores (e.g., give 3.5 for tied scores at ranks 3 & 4).
%   Include/Exclude options passed through.
%
% Outputs:
%
%   outVals : List indicating rank for each trial.

[NoAvgTies, varargin] = ExtractNamei('NoAvgTies',varargin);
[Adjust, varargin] = ExtractNamei('Adjust',varargin);

NinTrials = height(inTrials);
outVals = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

Adjustment = 0;

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    TheseVals = inTrials.(sDV)(Indices);
    nItems = numel(TheseVals);
    if Adjust
       Adjustment = 0.5 / nItems;
    end
    if ~NoAvgTies
       rank_vector = tiedrank(TheseVals);
    else
       [~,~,rank_vector] = unique(TheseVals);
    end
    outVals(Indices) = rank_vector / nItems - Adjustment;
end

end
