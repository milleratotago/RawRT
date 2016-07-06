% The goals of this demo are to illustrate how to:
%   * organize the data within MATLAB
%   * plot means for a set of conditions
%   * plot frequency distributions of scores, possibly in each of a set of conditions
%   * compute a table of means
%   * carry out an ANOVA

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data
% (although you certainly could use RawRT for analyzing simulated data),
% but I cannot demo your read-in process because I don't know your data format.

Trials = DemoData('Demo0','Replicate');



%% Pause here to look at Trials.
% Please look now at the Trials data structure in the MATLAB main window.
% Each row is one trial, and the columns record the info about that trial,
% such as subject number, block number, condition, correctness of response,
% and RT.

% In general, you will have to construct a table like this for your own RT
% data.  There are so many different data formats that I will leave to you the
% initial problem of getting your data into such a table format (but MATLAB
% has some very helpful tools for that).

% Once the data have been read into a Trials table like this, the RawRT
% routines can be used for analysis.

NTrials = height(Trials)  % Count the trials--often useful.

disp('Please look at the Trials table.  You must read your data into a MATLAB table with this kind of format.');
disp('Type any key to continue:');
pause

%% Some examples of means plots.

CondPlot(Trials,'RT','Cond');    % Plot the mean RT in each condition.

CondPlot(Trials,'Cor','SubNo');  % Plot the mean Cor for each subject.

CondPlot(Trials,'RT',{'SubNo','Cond'});  % Plot the mean RT for each subject in each condition.

CondPlot(Trials,'RT',{'SubNo','Cond','Blk'});    % Plot the mean RT for each subject in each condition in each block
                                                 % You may want to expand this picture.

% You can also plot summary functions other than the mean.
% Here are two examples with MATLAB's built-in median and std functions.
CondPlot(Trials,'RT','Cond','Function',@median);   % Plot the median RT in each condition.
CondPlot(Trials,'RT','Cond','Function',@std);      % Plot the std deviation of RT in each condition.
% You could use your own function instead of @median or @std.


%% Some examples of frequency distribution plots:

FreqDist(Trials,'RT');   % across all trials
CondFreqDist(Trials,'RT','Cond');  % separately for each condition


%% Compute the means for each subject in each condition:
MeansTable = CondMeans(Trials,'RT',{'SubNo','Cond'});

% Look at the new MeansTable variable.  It is again a table--the same data type as
% the Trials table.  Therefore, the same commands can be used.  For example:
CondPlot(MeansTable,'RT','Cond');   % Plot the mean RT in each condition.

%% Make other tables with the N, mean, sd, median, min, & max for each subject in each condition:
NsTable = CondNs(Trials,{'SubNo','Cond'});  % No need to specify a DV since you are just counting trials.
SDsTable = CondSDs(Trials,'RT',{'SubNo','Cond'});
MediansTable = CondMedians(Trials,'RT',{'SubNo','Cond'});

% The next two tables are computed with the more general underlying function "CondFunsOfDVs".
% It illustrates how you can compute -- for each combination -- any function
% that can be computed from a list of numbers (i.e., you can write your own function).
MinsTable = CondFunsOfDVs(Trials,'RT',{'SubNo','Cond'},@min);
MaxsTable = CondFunsOfDVs(Trials,'RT',{'SubNo','Cond'},@max);

% The next one computes a combined table with the N, mean, sd, median, min, & max for each subject in each condition:
DescribeTable = CondDescribe(Trials,'RT',{'SubNo','Cond'});


%% Here is a statistical analysis (ANOVA).
% Run an ANOVA to check for a condition effect; also include the block factor
% The ANOVA results are shown in a separate tab within the MATLAB editor,
% and they are also saved to the indicated file.

DVs = {'RT'};           % name(s) of dependent variable(s)
BetweenFac = {};               % name(s) of variable(s) coding between-Ss factors
WithinFac = {'Blk','Cond'};  % name(s) of variable(s) coding within-Ss factors
SubFac = 'SubNo';              % name of variable coding subjects factor
OutFileName = 'Demo0BlkCondRT';     % name used to write ANOVA output file
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,OutFileName);

% Once again, you can use a summary function other than the mean.
% The following command computes an ANOVA on the median RT for each subject and condition.
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,'Demo0BlkCondRTMdn','function',@median);


%% Often you want to select out certain trials to be considered,
% and the RawRT commands always allow this.

CondPlot(Trials,'RT','Cond','Include',Trials.Cor==1);    % Plot the mean CORRECT RT in each condition.

% Alternatively, you could get the same result with the command:
% CondPlot(Trials,'RT','Cond','Exclude',Trials.Cor==0);    % Plot the mean CORRECT RT in each condition.

% Re-run the previous ANOVA, now including only trials with correct responses.
OutFileName = 'Demo0BlkCondRTCor';     % save to a different output file
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,OutFileName,'Include',Trials.Cor==1);

