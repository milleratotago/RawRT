% The goals of this demo are to illustrate how to:
%   * identify & exclude warm-up trials
%   * identify & exclude trials following errors
%   * classify each trial according to the condition of the trial that preceded it
%   * perform ANOVA with "previous trial type" as a factor
% The crucial new function for these things is:
%   SeqFinder(Trials,Offset,sCondition) --- check its header for documentation.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data
Trials = DemoData('DemoSeq');

NTrials = height(Trials);  % Count the trials--often useful.

Trials.IncludeForRT = Trials.Cor==1;  % Maybe also check RT outlier cutoffs, etc, as you wish.


%% %%%%% Exclude warm-up trials at the beginning of each block; e.g., the first four trials:

Trials.Warmup = ones(NTrials,1);    % Use 1 to indicate warm-up trials; initially, make every trial a warm-up trial by default.

% Find trials in the same block as the trial that was 4 trials earlier.
% These are NOT in the first four trials of the block, so they are not warm-up trials.
NotFirstFour  = SeqFinder(Trials,-4,'Trials.Blk(CheckTrial)==Trials.Blk(CurrentTrial)');

Trials.Warmup(NotFirstFour) = 0;    % Set to 0 to indicate these are not warm-up trials.

% Report the total number of trials and the numbers marked vs not marked as warm-up.
height(Trials)
sum(Trials.Warmup==1)
sum(Trials.Warmup==0)



%% %%%%% Exclude (for example) 2 recovery trials after each error.

Error1Back = SeqFinder(Trials,-1,'Trials.Cor(CheckTrial)==0','MustMatch',{'SubNo','Blk'});
Error2Back = SeqFinder(Trials,-2,'Trials.Cor(CheckTrial)==0','MustMatch',{'SubNo','Blk'});

% MustMatch is used to make sure that the checktrial came from the same subject & block
%  as the current trial, because we only want to consider within-block errors.

Trials.Recovery = Error1Back|Error2Back;

% Report the total number of trials and the numbers marked vs not marked as recovery.
height(Trials)
sum(Trials.Recovery==1)
sum(Trials.Recovery==0)



%% %%%%% Classify trials according to the condition of the preceding trial:

Trials.Seq = nan(NTrials,1);    % Make a new variable to hold the labels for the sequential condition.

PrevCompat = SeqFinder(Trials,-1,'Trials.Compat(CheckTrial)==1','MustMatch',{'SubNo','Blk'});

% PrevCompat is now a list of boolean, one per trial, indicating whether each trial:
%   follows a trial with Compat==1 and
%   follows a trial with the same SubNo and
%   follows a trial with the same Blk
% We are checking to make sure that the trial came from the same subject & block
%  as the current trial because we only want to consider within-block sequential effects.

Trials.Seq( PrevCompat  ) = 1;   % Assign the Seq value of 1 to trials identified as PrevCompat.

% Now do the analogous thing to look for trials after an incompatible trial:
PrevIncompat = SeqFinder(Trials,-1,'Trials.Compat(CheckTrial)==2','MustMatch',{'SubNo','Blk'});
Trials.Seq( PrevIncompat  ) = 2;

%%%%%%% Done classifying trials according to the trial sequence.

% Do an ANOVA to see whether the Compat depends on the previous trial:
% Must exclude Trials with Seq=NaN (e.g., first trial in each block).
% Also exclude warm-up trials, since we marked them.
CallMrf(Trials,'RT',{},{'Seq','Compat'},'SubNo','DemoSeq','Include',Trials.IncludeForRT&Trials.Seq>=1&Trials.Warmup==0);

