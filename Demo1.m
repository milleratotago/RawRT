% This is the first demo that might actually represent the full analysis of an RT experiment.

% The goals of this demo are to illustrate how to:
%   * check the data for outlier subjects & trials
%   * exclude selected trials from the analysis based on various criteria
%   * keep track of how many trials were excluded by each criterion.
%   * compute a table of means using trials remaining after exclusions
%   * carry out an ANOVA using trials remaining after exclusions

%% Generate some simulated data for a demonstration.
% Include some low-accuracy Ss & some slow trials so that we can illustrate how
% to throw them out:
Trials = DemoData('Demo0','Replicate','BadSs',[5 14],'PctSlow',.05);

NTrials = height(Trials);  % Count the trials--often useful.


%% Check the generated data to see whether any subjects should be removed.

% Make figures & tables showing the PC & mean RT for each subject, to look for subjects who are outliers.
CondPlot(Trials,'Cor','SubNo');
CondPlot(Trials,'RT','SubNo');
SubAvgs = CondMeans(Trials,{'RT','Cor'},'SubNo')

disp('Normally you would pause here to check the subject averages and decide whether to drop any Ss.');

% Suppose you decided to exclude Ss 5 & 14 as bad Ss.  You could do that in either of two ways:

% You might indicate the list of bad Ss manually, like this:
BadSubList = [5 14];

% Alternatively, you might indicate it programmatically, based on an 80% correct cut-off, like this:
BadSubList = find(SubAvgs.Cor<.80);
BadSubNums = SubAvgs.SubNo(BadSubList)

% After you have made a list of the bad Ss, set up a new variable to label the trials from bad Ss:
Trials.BadSub = ismember(Trials.SubNo,BadSubNums);



%% Next, look at practice effects across blocks to see whether it seems necessary to drop any blocks:

CondPlot(Trials,'Cor','Blk','Exclude',Trials.BadSub);
CondPlot(Trials,'RT','Blk','Exclude',Trials.BadSub);
BlkAvgs = CondMeans(Trials,{'RT','Cor'},'Blk')

disp('Normally you would pause here to check the block averages and decide whether to drop any blocks.');

% Suppose you decide to drop Blk 1 as practice (i.e., because it has distinctly longer RTs and lower PCs).

% You might indicate the list of practice blocks manually, like this:
PracBlkList = [1];

% Set up a new variable to label trials from bad Ss,
Trials.Practice = ismember(Trials.SubNo,PracBlkList);


%% For this demo, I will use all good S's non-practice trials in the analyses of PC.
% Here is a new variable for coding that:
Trials.IncludeForPC = (~Trials.BadSub) & (~Trials.Practice);



%% Next make a frequency distribution of correct RTs (from good Ss, after practice) to check for outliers.

FreqDist(Trials,'RT','Exclude',Trials.BadSub|Trials.Practice|(~Trials.Cor));    % Exclude trials from bad subs, practice trials, & errors.

% Based on this frequency distribution of RT, it looks like it would be appropriate to define
% cutoffs for the "real" RTs, with anything outside these bounds considered to be an outlier.
MinRT =  250;
MaxRT = 1200;

% Thus, I will set up an indicator variable to code which trials to include for the RT analyses:
Trials.IncludeForRT = (~Trials.BadSub) & (~Trials.Practice) & (Trials.IncludeForPC&Trials.Cor==1) ...
    & (Trials.RT >= MinRT) & (Trials.RT <= MaxRT);

% Here is a slightly better way to do the same thing.
% The following handy command sets up this very same indicator variable, but it also prints
% a brief report telling how many trials were excluded:
[Trials.IncludeForRT, ExclusionReport, NExclude, PctExclude]= ExcludeFromPool( ...
    (~Trials.BadSub) & (~Trials.Practice) & (Trials.IncludeForPC&Trials.Cor==1), ...  % This line defines the starting pool of trials from which some will be excluded.
    '*** Exclude slow and fast outliers:',Trials.RT>MaxRT,Trials.RT<MinRT);  % This line specifies 2 types of exclusions (too slow, too fast).



%% Make plots for a quick look at the data after exclusions.
% Important note: These plots average across trials, counting each trial equally.
% The means produced by the later statistical analyses will be slightly different,
% because those means will count each subject equally. More about this in documentation (NEWJEFF).

% Use some optional condition labels in some plots to illustrate this option.
Labels.Cond = {'Compatible','Neutral','Incompatible'};
% !! CondPlot has _many_ more optional parameters, as described in CondPlot.m

% Condition PCs including only trials with IncludeForPC==1
CondPlot(Trials,'Cor','Cond','Include',Trials.IncludeForPC);
% RT condition means including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT,'Labels',Labels);
% RT condition medians including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT,'Function',@median,'Labels',Labels);
% RT condition standard deviations including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT,'Function',@std,'Labels',Labels);



%% Run Blk x Cond ANOVAs on RTs and PCs

DVs = {'RT'};           % name(s) of dependent variable(s)
BetweenFac = {};               % name(s) of variable(s) coding between-Ss factors
WithinFac = {'Blk','Cond'};  % name(s) of variable(s) coding within-Ss factors
SubFac = 'SubNo';              % name of variable coding subjects factor
OutFileName = 'Demo1BlkCondRT';     % name used to write ANOVA output file
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,OutFileName,'Include',Trials.IncludeForRT);

% The exact same ANOVA could be run like this without defining the separate variables:
% CallMrf(Trials,{'RT'},{},{'BlkNo','Cond'},'SubNo','Demo1BlkCondRT','Include',Trials.IncludeForRT);

% Here is another ANOVA, for PC, written with some explicit values instead of variables.
CallMrf(Trials,'Cor',BetweenFac,WithinFac,SubFac,'Demo1BlkCondPC','Include',Trials.IncludeForPC);


%% Another option for data cleaning is to exclude trials that are more than 2 or 3 SDs
%  from the condition mean, computed separately for each subject and condition.
%  I don't personally like this approach, but here is one way to do it with this software:

% Compute each trial's Z score relative to the other trials for its combination of SubNo, Blk, and Cond.
Trials.RTZ = CondZs(Trials,'RT',{'SubNo','Blk','Cond'},'Include',Trials.IncludeForRT);

Zcutoff = 3;  % My arbitrary Z cutoff
Trials.ZOK = (Trials.RTZ >= -Zcutoff) & (Trials.RTZ <= Zcutoff);
Trials.IncludeForRTusingZ = (~Trials.BadSub) & (~Trials.Practice) & (Trials.IncludeForPC&Trials.Cor==1) & Trials.ZOK;

% The analysis would proceed as before with this new indicator variable, e.g.:
% RT condition means including only trials with IncludeForRTusingZ==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRTusingZ);
