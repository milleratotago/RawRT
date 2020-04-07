function outRanks = CondRanks(inTrials,sDV,CondSpecs,varargin)
% For each CondSpecs combination of conditions, rank the trials on inTable.(sDV).
% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable determining ranking
%   CondSpecs : Conditions to be kept separate when ranking (e.g., subject, task, etc)
%
% varargin options:
%   'NoAvgTies' to rank only unique scores, so the maximum rank may be less than the total number of scores.
%     The default behavior is to average the ranks of tied scores (e.g., give 3.5 for tied scores at ranks 3 & 4).
%   Include/Exclude options passed through.
%
% Outputs:
%
%   outRanks : List indicating rank for each trial.

[NoAvgTies, varargin] = ExtractNamei('NoAvgTies',varargin);

NinTrials = height(inTrials);
outRanks = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    TheseVals = inTrials.(sDV)(Indices);
%     nItems = numel(TheseVals);
    if ~NoAvgTies
       rank_vector = tiedrank(TheseVals);
    else
       [~,~,rank_vector] = unique(TheseVals);
    end
    outRanks(Indices) = rank_vector;
end

end
