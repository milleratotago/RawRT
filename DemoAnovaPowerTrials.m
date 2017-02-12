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

% 1-Within Factor Example.

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
    ];

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
   114.0 ... % S
    26.0 ... % AS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

% Newjeff: Need this section for all cases.
if NTrials==1
    ReplicParms = cell(0,0);
    ReplicLevels = [];
    ReplicName = [];
else
    ReplicParms = [{'NReplications'} {NTrials}];
    ReplicLevels = NTrials;
    Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
    ReplicName = UniqueVarname(Trials,'replic');
end
Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs ReplicName] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels ReplicLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc

%% 2-Within Factor Example.

% NEWJEFF: REPEATED FOR SECTION:
alpha = .05;
NSims = 200;
NTrials = 10;     % N of measurements per subject per condition
TrialError = 50;  % Standard deviation associated with random error from one measurement to the next.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A', 'B'};
WithinLevels = [2 5];
SubName = 'S';
NSubsPerGroup = 2;

TrueMeans = [ ...   % 2x5
   % B1  B2  B3  B4  B5
    340 350 360 470 480 ...  % A1
    300 300 305 300 390 ...  % A2
    ];

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
    14.0 ... % S
     6.0 ... % AS
    32.5 ... % BS
     6.0 ... % ABS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

if NTrials==1
    ReplicParms = cell(0,0);
    ReplicLevels = [];
    ReplicName = [];
else
    ReplicParms = [{'NReplications'} {NTrials}];
    ReplicLevels = NTrials;
    Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
    ReplicName = UniqueVarname(Trials,'replic');
end
Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs ReplicName] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels ReplicLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc


%% 3-Within Factors Example.

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

BetweenFacs = {};
BetweenLevels = [];
WithinFacs = {'A', 'B', 'C'};
WithinLevels = [2 2 5];
SubName = 'S';
NSubsPerGroup = 6;

TrueMeans = [ ...   % 2x2x5
   % C1  C2  C3  C4  C5
    310 320 330 340 350 ...  % A1B1
    300 310 325 330 335 ...  % A1B2
    318 320 338 342 345 ...  % A2B1
    330 335 345 360 365 ...  % A2B2
    ];

TrueSigmas = [...  % MUST MATCH ORDER OF RANDOM SOURCES IN TABLE PRODUCED BY ANOVAN
    14.0 ... % NSubsPerGroup
     6.0 ... % AS
     6.5 ... % BS
     5.5 ... % CS
     6.0 ... % ABS
     5.4 ... % ACS
     5.3 ... % BCS
     5.2 ... % ABCS
    TrialError ... % Error
    ];

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc


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

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc


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

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc

%% 3-Between Example from G*Power documentation section 11.3, pages 27 ff
% NEWJEFF: Recheck this

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

TrueSigmas = [sigmaSABC TrialError];  % SABC, Error

%  ************************************
%  *** END OF PARAMETERS TO BE SET ****
%  ************************************

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc



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

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc

%% 3-Mixed Example, 2 Within

%  ************************************
%  *** PARAMETERS TO BE SET START HERE
%  ************************************

BetweenFacs = {'A'};
BetweenLevels = [2];
WithinFacs = {'B', 'C'};
WithinLevels = [2, 5];
SubName = 'S';
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

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc


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

Trials = TrialFrame([BetweenFacs cellstr(SubName) WithinFacs] ...
           ,[BetweenLevels NSubsPerGroup WithinLevels],'Between',{BetweenFacs,SubName});
anvpwr = AnovaPower(Trials,BetweenFacs,WithinFacs,SubName,ReplicParms{:});

anvpwr.setPowers(TrueMeans,TrueSigmas,alpha)
anvpwr.Report;

anvpwr.InitSims;

tic
for iSim=1:NSims
    anvpwr.SimulateOne;
end
anvpwr.Report;
toc


