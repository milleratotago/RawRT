function [outIndicators, outBinTops] = CondBinLabels(inTrials,sDV,CondSpecs,NBins,varargin)
% Produce a list of output indicators in the range [1-NBins] for all trials in inTrials (NaN indicates unused).
% The bin assignment indicates whether inTrials.sDV is in the smallest bin (1), 2nd smallest (2), etc.
% There are approximately equal numbers of trials in all bins.

% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   sDV       : name of the variable determining bin membership
%   CondSpecs : Other conditions to be kept separate when computing bins (e.g., subject, task, etc)
%   NBins     : number of bins to use for each condition.
%
% varargin options:
%   Include/Exclude options passed through.
%   Jitter: either:
%     (1) An array of (presumably small random) numbers to be added into the successive sDV values.
%         These numbers should be large enough to break ties but small enough not to change the
%         order of different sDV values. For example, if sDV is whole numbers then the jitters might be 0-0.5.
%     (2) A single number that is an upper bound on the Jitter (e.g., 0.5 with whole numbers).
%
% Outputs:
%
%   outIndicators : List of NaN or numbers 1-to-NBin indicating bin for each trial.
%   outBinTops : A table showing the max values of each bin for each combination of conditions.

NinTrials = height(inTrials);

[Jitter, varargin] = ExtractNameVali({'Jitter'},zeros(NinTrials,1),varargin);
if numel(Jitter) == 1
   Jitter = Jitter*rand(NinTrials,1);  % Add a small random number (0-Jitter) to break ties
end

outIndicators = NaN(NinTrials,1);

[mySubTableIndices, outBinTops] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(outBinTops);

outBinTops.BinTops = NaN(NConds,NBins);

for iCond = 1:NConds

    Indices = mySubTableIndices{iCond};
    TheseVals = inTrials.(sDV)(Indices) + Jitter(Indices);
    nItems = numel(TheseVals);

    assert(nItems>=NBins,['ERROR: Cannot distinguish ' num2str(NBins) ' bins with only ' num2str(nItems) ' trials.']);

    % Find the bin cutoffs for this set of values:
    TheseVals = sort(TheseVals);
    for iBin = 1:NBins
        ThisBinHi = floor(nItems*iBin/NBins+0.5);
        TheseBinTops(iBin) = TheseVals(ThisBinHi);
    end

    outBinTops.BinTops(iCond,:) = TheseBinTops(:);

    % Classify each trial into its corresponding bin
    for iTrial = 1:nItems
        jTrial = Indices(iTrial);            % The trial's number.
        TrialVal = inTrials.(sDV)(jTrial) + Jitter(jTrial);       % The trial's value on the binning DV
        outIndicators(jTrial) = find(TheseBinTops>=TrialVal,1);   % Save the bin number of this value.
    end
end

end
