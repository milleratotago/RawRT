% The goals of this demo are to illustrate how to:
%   * compute a stimulus-response confusion matrix.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data
Trials = DemoData('DemoSRCrosstab');

NTrials = height(Trials);  % Count the trials--often useful.
NSubs = numel(unique(Trials.SubNo));

%% Make two equivalent tables counting the total number of trials for each condition with each response:
% The "short" table has the counts in the order Cond1Resp1, Cond1Resp2, Cond1Resp3, ...Cond2Resp1, ...
% The "tall" table has the counts labelled.
[Ttall, Tshort] = CondSRCrosstab(Trials,'Cond','Resp',{})
% Here are some alternative ways of getting the counts, as a check:
numel(Trials.Cond(Trials.Cond==1&Trials.Resp==1))
numel(Trials.Cond(Trials.Cond==1&Trials.Resp==2))
numel(Trials.Cond(Trials.Cond==1&Trials.Resp==3))
numel(Trials.Cond(Trials.Cond==2&Trials.Resp==1))
numel(Trials.Cond(Trials.Cond==2&Trials.Resp==2))
numel(Trials.Cond(Trials.Cond==2&Trials.Resp==3))

%% Some analogous computations broken down by subject:
[Tsubtall, Tsubshort] = CondSRCrosstab(Trials,'Cond','Resp',{'SubNo'});
% Now get the same totals as Ttall by summing across subjects.
Ttall2 = CondTotal(Tsubtall,'Count',{'Cond','Resp'})

%% Exclude one of the conditions or one of the responses & check the totals.
TsubtallminusCond3 = CondSRCrosstab(Trials,'Cond','Resp',{'SubNo'},'Exclude',Trials.Cond==3);
CondTotal(TsubtallminusCond3,'Count',{'Cond','Resp'})
TsubtallminusResp3 = CondSRCrosstab(Trials,'Cond','Resp',{'SubNo'},'Exclude',Trials.Resp==3);
CondTotal(TsubtallminusResp3,'Count',{'Cond','Resp'})

%% Don't bother computing the tall version of the table (this should be a little faster):
[~, Tshort2] = CondSRCrosstab(Trials,'Cond','Resp',{},'Exclude',Trials.Cond==3,'NoTall')
