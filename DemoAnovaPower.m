%% This file demonstrates how to compute power for ANOVA designs.
%
% To compute power, you need to know all of the following (hypothetical values
% of these quantities were simply invented for the examples in this file):
%
%  o The factors in the experiment, the number of levels of each factor,
%    and a specification of whether each factor is between-subjects or within-subjects.
%
%  o The number of subjects per group.  If your goal is to find out how many
%    subjects you need to achieve certain desired power levels, use trial and error.
%    That is, make a guess, check the power, and adjust as needed.
%
%  o Hypothesized cell means -- a tricky part:
%    Power depends on the true effect sizes, so you must specify those.
%    When using this software, you specify the (hypothesized) true mean
%    in each cell of the factorial design, and the program will compute
%    the "effect sizes" needed for power computations from those.  Note that when
%    you are computing power for a main effect or interaction, the absolute
%    numbers don't matter--only the differences in scores between different
%    factor levels are important. (You can easily verify this by computing power
%    with one set of cell means, then add 100 to all cell means and recompute
%    power--the power won't change.)
%
%  o Error term(s) -- an even trickier part:
%    Power also depends on error, so you have to specify this too.
%    In between-subjects designs, this is the within-group standard deviation of the scores,
%    which you must estimate from previous studies or pilot data.
%    It is more complicated in within-subjects designs, because there are several different
%    error terms, as shown in the ANOVA table (e.g., S, AS, BS, ABS, ...),
%    each of which has its own standard deviation.
%    In the future I hope to be provide more information about how to estimate
%    these values; for now, I can only recommend trying various values and checking the
%    Avg[MS] columns that you get in the simulations.  The idea is to pick sigmas
%    for the S, AS, BS, etc that give you Avg[MS] comparable to those you have
%    found in previous experiments with the same design & number of subjects.
%
%    There is one further complication to consider with respect to error terms,
%    namely, what is here called "TrialError".  There are two cases:
%
%      NTrials = 1: This indicates that your ANOVA will include one score per subject
%      in each condition.  That score might be a mean across many trials, but the
%      ANOVA will only process one score per subject per condition.  In this case, use
%      TrialError=0.
%
%      NTrials > 1: This indicates that your ANOVA will include 2 or more scores per subject
%      in each condition.  These scores will differ due to some kind(s) of random error (e.g.,
%      measurement error, random moment-to-moment fluctuations in the subject's state, etc).
%      In this case, TrialError is the estimate of the standard deviation associated
%      with this source of random error.  You can estimate it from pilot data by
%      computing a pooled within-subject, within-condition standard deviation, pooling
%      across all of the different subject/condition combinations.
%
%      In summary of NTrials:
%        For a situation with only 1 measurement per subject per condition,
%        use these two lines:
%          NTrials = 1;
%          TrialError = 0;
%        For a situation with multiple measurements per subject per condition,
%        use these two lines:
%          NTrials = ???;    % The number of trials per subject/condition that you have.
%          TrialError = ???; % Your best guess as to the random error standard deviation
%                            % causing differences among trials within the same subject/condition.
%      For the examples in this file, I used NTrials=1, which I think is more common.
%
% In addition to the output "Power" value, this program prints out values of ThetaSqr, Noncentrality, and OmegaSqr.
%   Be warned, however, that different textbooks use many different definitions of ThetaSqr and OmegaSqr,
%   so the values computed here may differ from those found in textbooks--just because a different quantity
%   is being computed.
%
% Further notes concerning simulations:
%
%   You can use these routines without any simulations at all, in which case use
%     NSims = 0;
%   as in the current examples.
%
%   There would be several possible reasons for doing simulations, in which case
%   you would change to something like NSims = 500 (or more):
%      * to check Avg[MS] values to see whether the sigmas give plausible values.
%      * to check the programs, by seeing whether the probability of significant
%        results in the simulations actually matches the computed power values.
%        (Let me know if you find an error.)
%      * To check other aspects of the simulation results besides those tabulated
%        automatically by these programs.  Note that you could write any function
%        you wanted to follow anvpwr.SimulateOne, so you could check and tabulate
%        anything that is computed for each simulation.


%% 1-Within Factor Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A'};
WithinLevels = [5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x5
    310 320 330 340 350 ...  % A1-5
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [...  % Specify these in the same order in which the random sources appear in the ANOVA table
    14.0 ... % S
    6.0 ...  % AS
    TrialError ...
    ];

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end

%% 2-Within Factor Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A', 'B'};
WithinLevels = [2 5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x5
    % B1  B2  B3  B4  B5
    380 370 360 370 380 ...  % A1
    370 370 345 360 390 ...  % A2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [...  % Specify these in the same order in which the random sources appear in the ANOVA table
    8.0 ... % S
    6.0 ... % AS
    12.5 ... % BS
    6.0 ... % ABS
    TrialError ... % Error
    ];

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 3-Within Factors Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A', 'B', 'C'};
WithinLevels = [2 2 5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x2x5
    % C1  C2  C3  C4  C5
    330 330 340 330 330 ...  % A1B1
    320 320 335 320 315 ...  % A1B2
    328 320 318 322 315 ...  % A2B1
    350 345 335 350 345 ...  % A2B2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [...  % Specify in the same order in which the random sources appear in the ANOVA table
    8.0 ... % S
    6.0 ... % AS
    6.5 ... % BS
    16.0 ... % ABS
    5.5 ... % CS
    15.4 ... % ACS
    2.3 ... % BCS
    15.2 ... % ABCS
    TrialError ... % Error
    ];

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 1-Between Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'A'};
BetweenLevels = [5];
WithinFacs = {};
WithinLevels = [];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x2x5 with bigger AB:
    % A1  A2  A3  A4  A5
    310 320 330 340 350 ...
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [32 TrialError];  % SABC, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 2-Between Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'A', 'B'};
BetweenLevels = [2 5];
WithinFacs = {};
WithinLevels = [];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x5
    % B1  B2  B3  B4  B5
    310 320 310 310 310 ...  % A1
    268 320 338 342 375 ...  % A2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [32 TrialError];  % SABC, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 3-Between Example from G*Power documentation section 11.3, pages 27 ff

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'A', 'B', 'C'};
BetweenLevels = [3 3 4];
WithinFacs = {};
WithinLevels = [];
SubName = 'S';
NSubsPerGroup = 3;

TrueMeans = [ ...  % Means in Fig 13
    3.0000   4.6667   2.0000   2.0000 ... % A1B1
    3.0000   2.0000   2.0000   2.0000 ... % A1B2
    2.3333   2.0000   2.0000   2.0000 ... % A1B3
    3.3333   3.3333   4.6667   4.6667 ... % A2B1
    6.3333   4.6667   4.6667   4.6667 ... % A2B2
    3.0000   4.6667   4.6667   4.6667 ... % A2B3
    2.6667   2.6667   2.0000   2.0000 ... % A3B1
    4.6667   2.0000   2.0000   2.0000 ... % A3B2
    4.6667   2.0000   2.0000   2.0000 ... % A3B3
    ];
sigmaSABC =  sqrt(1.71296);  % top right of page 27

NTrials = 1;
TrialError = 0;
TrueSigmas = [sigmaSABC TrialError];  % SABC, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end



%% 2-Mixed Example

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'A'};
BetweenLevels = [2];
WithinFacs = {'B'};
WithinLevels = [5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x5
    % B1  B2  B3  B4  B5
    310 320 310 310 310 ...  % A1
    368 320 338 342 375 ...  % A2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [54 24 TrialError];  % SA, BSA, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 3-Mixed Example, 2 Within

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'Aa'};
BetweenLevels = [2];
WithinFacs = {'Bb', 'Cc'};
WithinLevels = [2, 5];
SubName = 'Ss';
NSubsPerGroup = 6;

TrueMeans = [ ...   % AxBxC = 2x5x2
    % Note the ordering of means: Within-Ss factors must cycle fastest.
    % C1  C2  C3  C4  C5
    310 320 310 310 310 ...  % A1B1
    368 320 338 342 375 ...  % A1B2
    330 340 350 310 310 ...  % A2B1
    368 320 338 342 375 ...  % A2B2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [54 24 22 12 TrialError];  % SA, BSA, CSA, BCSA, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


%% 3-Mixed Example, 2 Between

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

alpha = .05;
BetweenFacs = {'A','C'};
BetweenLevels = [2 2];
WithinFacs = {'B'};
WithinLevels = [5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % AxCxB = 2x2x5
    % Note the ordering of means: Within-Ss factors must cycle fastest.
    % B1  B2  B3  B4  B5
    310 320 310 310 310 ...  % A1C1
    368 320 338 342 375 ...  % A1C2
    330 340 350 310 310 ...  % A2C1
    368 320 338 342 375 ...  % A2C2
    ];

NTrials = 1;
TrialError = 0;
TrueSigmas = [54 24 TrialError];  % SAC, BSAC, Error

NSims = 0;

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPower(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

if NSims>0
    anvpwr.InitSims;
    for iSim=1:NSims
        anvpwr.SimulateOne;
    end
    anvpwr.Report;
end


