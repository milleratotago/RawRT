%% Parameters used in all examples.

alpha = .05;
NSims = 100;

% For a situation with only 1 measurement per subject per condition,
% use these three lines:
% NTrials = 1;
% TrialError = 0;

% For a situation with only multiple measurements per subject per condition,
% use these three lines:
NTrials = 20;     % N of measurements per subject per condition
TrialError = 50;  % Standard deviation associated with random error from one measurement to the next.

%% 1-Within Factor Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A'};
WithinLevels = [5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x5
   310 320 330 340 350 ...  % A1-5
%     -20 -10 0 10 20 ...  % A1-5
    ];

TrueMeans = TrueMeans - 310;

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
    14.0 ... % S
     6.0 ... % AS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc

%% 2-Within Factor Example.

% % REPEAT FOR SELF-CONTAINED SECTION:
% alpha = .05;
% NSims = 2;
% NTrials = 10;     % N of measurements per subject per condition
% TrialError = 50;  % Standard deviation associated with random error from one measurement to the next.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueMeans = TrueMeans - 250;

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
     8.0 ... % S
     6.0 ... % AS
    12.5 ... % BS
     6.0 ... % ABS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc


%% 3-Within Factors Example.

% NEWJEFF: This one gives wrong power for A and is not well tested for AS, BS, etc due to too high power.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

% Testing
alpha = .05;
NTrials = 5;
NSims = 100;
TrialError = 22;

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

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
     8.0 ... % S
     6.0 ... % AS
     6.5 ... % BS
     5.5 ... % CS
    16.0 ... % ABS
    15.4 ... % ACS
     2.3 ... % BCS
    15.2 ... % ABCS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);
anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
    if ~(anvpwr.simtbl.dfDenom{2}==5)
        disp('Error found');
        return;
    end
end
anvpwr.Report;
mintoc


%% 1-Between Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [32 TrialError];  % SABC, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc


%% 2-Between Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [32 TrialError];  % SABC, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc

%% 3-Between Example from G*Power documentation section 11.3, pages 27 ff

tempTrialError = TrialError / 10;    % Powers are very low with high trials error.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [sigmaSABC tempTrialError];  % SABC, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc



%% 2-Mixed Example

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [54 24 TrialError];  % SA, BSA, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc

%% 3-Mixed Example, 2 Within

% NEWJEFF: Wrong power for B, 1st of 2 within-Ss factors following a between-Ss factor.
% NEWJEFF: This worked with 2-letter factor names!!!

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [54 24 22 12 TrialError];  % SA, BSA, CSA, BCSA, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc


%% 3-Mixed Example, 2 Between

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

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

TrueSigmas = [54 24 TrialError];  % SAC, BSAC, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
%            ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
% anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr = AnovaPowerSetup(BetweenFacs,BetweenLevels,WithinFacs,WithinLevels,SubName,NSubsPerGroup,NTrials);

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
mintoc


