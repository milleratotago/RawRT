%% ********* Demo of Probit analysis: YN or mAFC task

%% Preliminary reminder of how Cupid works:

C = 5:5:25;        % Constant stimulus values
N=Normal(15,5);
PrYes = N.CDF(C);  % Yes means the stimulus value is larger than the value in the distribution, so it increases with C.
NTrials = 100;
NYes = NTrials*PrYes;
NNo = NTrials - NYes;
a = N.YNProbitLnLikelihood(C,NYes+NNo,NYes);

N.PerturbParms('rr');  % Perturb the parameters and make sure we can recover them.
N.EstProbitYNML(C,NYes+NNo,NYes,'rr')

%% Generate some fake data for the analysis:

% Choose the  number of the task that you would like to simulate
% (do not change the order of the strings in TaskChoices):
TaskChoices = {'YN' '2AFC' '3AFC' '4AFC' '5AFC' '6AFC' '7AFC' '8AFC' '9AFC'};
ThisTaskNo = 2;
ThisTask = TaskChoices{ThisTaskNo};
disp(['Simulating ' ThisTask ' task.']);

if ThisTaskNo==1
   pGuess = 0;
else
   mAFC = ThisTaskNo;
   pGuess = 1 / mAFC;
end

NSubs = 5;
NBlks = 2;
NStims = 5;
NTrialsPerBlkStim = 200;  % Don't go too small or you may get empty cells in some analyses.

% Generate example data:
rng('default');  % Parameter can be any positive integer
Trials = TrialFrame({'SubNo' 'BlkNo' 'Stim' 'Replic'},[NSubs NBlks NStims NTrialsPerBlkStim],'Shuffle','Drop','Replic','SortBy',{'SubNo','BlkNo'});
Trials.Resp = zeros(height(Trials),1);
for iTrial=1:height(Trials)
    % for these arbitrary sample data, Pr(response=1) is a simple function of the stimulus value.
    % this actually corresponds to a uniform distribution of X's from 0 to NStims.
    Trials.Resp(iTrial) = rand < (pGuess + (1-pGuess)*(Trials.Stim(iTrial)-0.5)/NStims);
end

[Counts5x2, Stims5x2, Resps5x2] = CondSRCrosstab(Trials,'Stim','Resp',{});

%% Illustrate probit analyses.  There are here called "Pmetric" analyses
%  because I use them for analysis of psychometric functions.

Dist1 = Normal(2.5,1);   % A hypothetical underlying distribution to be fit--not actually the correct one.
% Dist1 = RNGamma(2.5,1);   % Any Cupid distribution could be used.

% Using the data in Trials, create a table with the estimated normal mean and SD
% for each combination of SubNo and BlkNo.
% 'Stim' and 'Resp' are the names of the variables in Trials that hold the codes
% for the stimulus values (called Cs in the Cupid documentation) and the
% responses (called Y in the Cupid documentation).
% Dist1 determines the shape of the underlying distribution; its parameters are
% the ones being estimated (fit, adjusted).
% ThisTask is a string indicating which task was used (set above).
% By default, maximum likelihood fitting is used.
MLEEsts = CondFitPmetric(Trials,'Stim','Resp',{'SubNo' 'BlkNo'},Dist1,'Task',ThisTask)
% The output table MLEEsts has the estimated parameter values and the subject and condition codes.
% It also has the estimated point of subjective equality (PSE) and difference limen (DL)
% which are two commonly-used summary measures in psychometric function analysis.
% "Best" is the final value of the function that was minimized--i.e., LnLikelihood or ChiSq.

% This is the same except that ChiSquare fitting is used.
ChiSqEsts = CondFitPmetric(Trials,'Stim','Resp',{'SubNo' 'BlkNo'},Dist1,'Fit','ChiSquare','Task',ThisTask)

% Note that you could now perform ANOVA on the estimated parameter values with a command like this:
% CallMrf(MLEEsts,{'mu','sigma','PSE','DL'},{},{'BlkNo'},'SubNo',['PMetric' ThisTask 'MLE']);

