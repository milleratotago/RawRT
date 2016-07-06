% The goals of this demo are to illustrate how to:
%   * compute and plot condition means
%   * identify and exclude bad subjects
%   * examine practice effects and exclude practice blocks
%   * exclude error trials
%   * identify and exclude trials with outlier RTs
%   * count trials excluded by various criteria
%   * compute and plot condition means including only non-excluded trials
%   * compute ANOVAs including only non-excluded trials

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.

Trials = DemoData('Demo0','Replicate','BadSubs',[5 14],'PctFast',0.02,'PctSlow',.05);

% For illustrative purposes, the simulated data contain two subjects who
% make a lot of errors and will be excluded from the analysis, and it will
% also contain some trials with fast and slow outlier RTs.



%% This section illustrates how to compute and plot some means.
% This provides a quick look at the data, but it is only a preliminary look
% because we have not checked for bad Ss or outliers yet.

% The function 'CondMeans' computes averages for each condition, averaging across subjects, blocks,
% and trials (basically, the function averages across any trial descriptors that are _not_ listed).

% In the first example, we asked for mean values of the variables RT and Cor,
% separately for each value of Cond (and averaging over everything else).
% Those means are stored in the MATLAB variable 'ConditionMeans'.

ConditionMeans = CondMeans(Trials,{'RT','Cor'},{'Cond'});

% In the next example, means are computed separately for each combination of Blk and Cond.

BlkByCondMeans = CondMeans(Trials,{'RT','Cor'},{'Blk','Cond'});

% Note: The next two commands produce identical plots.
% The Figure parameter lets you pass through commands to MATLAB's figure function.
CondPlot(Trials,'RT',{'Cond'}, ...
    'Figure',{'Name','First of 2 identical plots.'});
CondPlot(ConditionMeans,'RT',{'Cond'}, ...
    'Figure',{'Name','Second of 2 identical plots.'});

% Plot the mean RT for each subject in each condition.
CondPlot(Trials,'RT',{'SubNo','Cond'}, ...
    'Figure',{'Name','Plot of conditon mean RTs for each subject.'});

CondPlot(Trials,'RT',{'Blk','Cond'});

CondPlot(BlkByCondMeans,'RT',{'Blk','Cond'});
CondPlot(BlkByCondMeans,'RT',{'Cond','Blk'});



%% Start checking the generated data to see which trials should be analyzed.

% Make figures & tables showing the PC & mean RT for each subject.
% This is helpful in identifying bad/outlier subjects who should be excluded,
% although this is a pretty subjective judgment.

CondPlot(Trials,'Cor','SubNo');
CondPlot(Trials,'RT','SubNo');
SubAvgs = CondMeans(Trials,{'RT','Cor'},'SubNo');

openvar('SubAvgs')

disp('Check the subject averages in the graphs and SubAvgs table to decide whether to drop any Ss.');
disp('Type any key to continue:');

pause;

% The next 2 lines show a useful technique for indicating which Ss, blocks, etc are bad.
BadSubs = [5 14];   % Specify any desired list of bad subjects, including none: []
Trials.BadSub = ismember(Trials.SubNo,BadSubs);

NGoodSubTrials = sum(~Trials.BadSub)   % How many trials do we have for the good subjects?


%% Make figures to look at practice effects across blocks:

CondPlot(Trials,'Cor','Blk','Include',~Trials.BadSub);
CondPlot(Trials,'RT','Blk','Include',~Trials.BadSub);

% Again, this is somewhat subjective, but based based on the preceding figures,
% I would regard block 1 as "practice", because it has distinctly longer RTs and lower PCs.

% Here again is the useful pattern for indicating which Ss, blocks, etc are OK or are bad.
PracticeBlocks = [1];   % Specify any desired list of practice blocks, e.g. [1 2 3]
Trials.Practice = ismember(Trials.Blk,PracticeBlocks);

% For this demo, I will use all good S's non-practice trials in the analyses of PC.
% Here is a new variable for coding that:
Trials.IncludeForPC = ~Trials.BadSub&~Trials.Practice;
NTrialsForPC = sum(Trials.IncludeForPC)

% Similarly, I will limit the RT analyses to these same trials
% but also include only correct responses.
% The next command shows one way to do this & also print out a useful count of excluded trials.

Trials.IncludeForRT = ExcludeFromPool(Trials.IncludeForPC,'*** Exclude errors:',Trials.Cor==0);


%% Make a frequency distribution of RTs to check for outliers.

% FreqDist(Trials,'RT');    % This would include _all_ trials, but we don't want them all.
FreqDist(Trials,'RT','Include',Trials.IncludeForRT);    % Exclude trials from bad subs, practice trials, & errors.


%% Select which trials will be included in the analysis of RTs.

% Based on the previous frequency distributions of RT, it looks like it would be appropriate to define
% cutoffs for the "real" RTs, with anything outside these bounds considered to be an outlier.
MinRT =  250;
MaxRT = 1200;

% This command starts with the revised "pool" of all non-practice trials with errors excluded,
% and it further excludes trials with outlier RTs:
Trials.IncludeForRT = ExcludeFromPool(Trials.IncludeForRT,'*** Exclude slow and fast outliers:',Trials.RT>MaxRT,Trials.RT<MinRT);

% Note that the percentages would be different if you excluded RT outliers first and errors second;
% this is because of these trials that are both outliers and errors:
NExcludedTwice = sum( ~Trials.Practice&Trials.Cor==0&(Trials.RT>MaxRT|Trials.RT<MinRT) );
fprintf('** %d trials were both errors and outliers.\n',NExcludedTwice);



%% Make some preliminary plots to have a quick look at the data.
% Important note: These plots average across trials, counting each trial equally.
% The means produced by the later statistical analyses will be slightly different,
% because those means will count each subject equally. More about this in documentation (NEWJEFF).

% RT condition means including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT);
% RT condition medians including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT,'Function',@median);
% RT condition standard deviations including only trials with IncludeForRT==1
CondPlot(Trials,'RT','Cond','Include',Trials.IncludeForRT,'Function',@std);



%% Run an ANOVA
DVs = {'RT'};           % name(s) of dependent variable(s)
BetweenFac = {};               % name(s) of variable(s) coding between-Ss factors
WithinFac = {'Blk','Cond'};  % name(s) of variable(s) coding within-Ss factors
SubFac = 'SubNo';              % name of variable coding subjects factor
OutFileName = 'Demo1BlkCondRT';     % name used to write ANOVA output file
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,OutFileName,'Include',Trials.IncludeForRT);

% The exact same ANOVA could be run like this without defining the separate variables
% as shown in the next line:
% CallMrf(Trials,{'RT'},{},{'Blk','Cond'},'SubNo','BlkCondRT','Include',Trials.IncludeForRT);


%% To have a closer look, examine separate frequency distributions of RT for each condition/block:
CondFreqDist(Trials,'RT','Cond','Include',Trials.IncludeForRT); % Make separate FDs for each condition for selected trials.
CondFreqDist(Trials,'RT',{'Blk','Cond'},'Include',Trials.IncludeForRT); % Make separate FDs for each condition for selected trials.


%% Next, make & process tables of subject means rather than the starting table of individual trials.

% Make a table of subject means from the original Trials table.
MeansSubByBlkByCond = CondMeans(Trials,{'RT'},{'SubNo','Blk','Cond'},'Include',Trials.IncludeForRT);

% Run an ANOVA on the subject means in this new table.  You can check that this ANOVA
% gives _exactly_ the same results as the original ANOVA based on the Trials table,
% which it should.
CallMrf(MeansSubByBlkByCond,{'RT'},{},{'Blk','Cond'},'SubNo','BlkCondRT2');

% Compute and plot a table of Block x Cond means, averaged across Ss.
% Note that each subject counts equally in the resulting MeansBlkByCond table,
% which is the same as the ANOVA.
MeansBlkByCond = CondMeans(MeansSubByBlkByCond,{'RT'},{'Blk','Cond'});
CondPlot(MeansBlkByCond,'RT','Cond');

