% The goals of this demo are to illustrate how to:
%   * compute the values dPrime and Beta (from Signal Detection Theory) for a Yes/No task.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data
Trials = DemoData('DemoTSD_YN');

NTrials = height(Trials);  % Count the trials--often useful.

% Compute dPrime, Beta, and Criterion separately for each subject in each condition.
TSDResults = CondTSD_YN(Trials,{'SubNo','Cond'},'Stim','Resp');

% Do an ANOVA to see whether these measures differ across conditions:
CallMrf(TSDResults,{'dPrime','Beta','Criterion'},{},{'Cond'},'SubNo','DemoTSD_YN');

% Plot the computed values for each subject and condition.
CondPlot(TSDResults,'dPrime',{'SubNo','Cond'});
CondPlot(TSDResults,'Beta',{'SubNo','Cond'});
CondPlot(TSDResults,'Criterion',{'SubNo','Cond'});




%% This section demonstrates the adjustments for cases when PrHit=1 or PrFA=0.
% It takes advantage of the fact that the data were generated in small blocks, so there would be
% some SubNo/Blk/Cond combinations with these extreme probabilities.

% Tabulate without any adjustment.  Note that there are some NaN results where PrHit=1 or PrFA=0:
TSDResultsByBlk = CondTSD_YN(Trials,{'SubNo','Blk','Cond'},'Stim','Resp');

% Tabulate with the LogLinear adjustment...
TSDResultsByBlkLogLin = CondTSD_YN(Trials,{'SubNo','Blk','Cond'},'Stim','Resp','LogLinear');

% and with the 1/2N adjustment
TSDResultsByBlk1Over = CondTSD_YN(Trials,{'SubNo','Blk','Cond'},'Stim','Resp','1/2N');

TSDResultsByBlkLogLin.NCorrect = TSDResultsByBlkLogLin.NHits + TSDResultsByBlkLogLin.NCorrectRejections;
figure
plot(TSDResultsByBlkLogLin.NCorrect,TSDResultsByBlkLogLin.dPrime,' ok')

TSDResultsByBlk1Over.NCorrect = TSDResultsByBlk1Over.NHits + TSDResultsByBlk1Over.NCorrectRejections;
figure
plot(TSDResultsByBlk1Over.NCorrect,TSDResultsByBlk1Over.dPrime,' ok')

figure
plot(TSDResultsByBlkLogLin.dPrime,TSDResultsByBlk1Over.dPrime,' ok')


%% This section demonstrates the nonparametric measures.
TSDResultsNonparm = CondTSD_YN(Trials,{'SubNo','Cond'},'Stim','Resp','Nonparametric');

TSDResultsBoth = CondTSD_YN(Trials,{'SubNo','Cond'},'Stim','Resp','Both');

TSDResultsCorBoth = CondTSD_YN(Trials,{'SubNo','Cond'},'Stim','Resp','Both','1/2N');

% % Do an ANOVA to see whether dPrime & Beta differ across conditions:
% CallMrf(TSDResultsLogLin,{'dPrime','Beta','Criterion'},{},{'Cond'},'SubNo','DemoTSD_YN');
% 
% % Plot the dPrime values for each subject and condition.
% CondPlot(TSDResultsLogLin,'dPrime',{'SubNo','Cond'});
% CondPlot(TSDResultsLogLin,'Beta',{'SubNo','Cond'});
% CondPlot(TSDResultsLogLin,'Criterion',{'SubNo','Cond'});
