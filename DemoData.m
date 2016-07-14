function Trials=DemoData(sName,varargin)
% This calls a special-purpose routine to generate a data set for each demos.
% In each case the data are generated according to a really crude little model,
% just for use in illustrating the routines.

% Optional parameters that can be used with any demo:
[Replicate,  varargin] = ExtractNamei('Replicate',varargin);  % Use default rng seed to get the same result every time.
[sSubNo,    varargin] = ExtractNameVali('SubNo','SubNo',varargin);
%[sRTname,    varargin] = ExtractNameVali('RT','RT',varargin); % These are hard-wired below.
%[sPCname,    varargin] = ExtractNameVali({'PC','Cor'},'Cor',varargin);
[PctFastOut, varargin] = ExtractNameVali('PctFast',0,varargin);
[MnFastOut,  varargin] = ExtractNameVali({'MnFast','MeanFast'},200,varargin);
[SDFastOut,  varargin] = ExtractNameVali({'SDFast','StdDevFast'},20,varargin);
[PctSlowOut, varargin] = ExtractNameVali('PctSlow',0,varargin);
[MnSlowOut,  varargin] = ExtractNameVali({'MnSlow','MeanSlow'},3000,varargin);
[SDSlowOut,  varargin] = ExtractNameVali({'SDSlow','StdDevSlow'},300,varargin);
[BadSs,      varargin] = ExtractNameVali({'BadSs','BadSubs'},zeros(0),varargin);
[BadSPC,     varargin] = ExtractNameVali({'BadSPC','BadSsPC','BadSubPC','BadSubsPC'},0.650,varargin);
[RoundRT,    varargin] = ExtractNamei('RoundRT',varargin);

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

if BadSPC>1
    BadSPC = BadSPC/100;  % Correct values of 0-100 into the desired range of 0-1.
end

if Replicate
    % The next statement always resets the random number generator to the same state,
    % so that the same random numbers are produced every time DemoTrials is called.
    % This is an option in case you want to generate the same data set repeatedly
    % (e.g., in testing new routines).
    rng('default');  % Parameter can be any positive integer
end

if strcmpi(sName,'Demo0')
    Trials = Demo0Data;
elseif strcmpi(sName,'Demo1')
    Trials = Demo1Data;
elseif strcmpi(sName,'DemoGroups')
    Trials = DemoGroupsData;
elseif strcmpi(sName,'DemoBin')
    Trials = DemoBinData;
elseif strcmpi(sName,'DemoSeq')
    Trials = DemoSeqData;
elseif strcmpi(sName,'DemoRMI')
    Trials = DemoRMIData;
elseif strcmpi(sName,'DemoTSD_YN')
    Trials = DemoTSD_YNData;
else
    abort(['Unrecognized demo data set name: ' sName]);
end

NTrials = height(Trials);

% Change the accuracy scores for bad Ss
if numel(BadSs) > 0
    WantTrials = ismember(Trials.(sSubNo),BadSs);
    Rand01 = rand(NTrials,1);
    Trials.Cor(WantTrials) = Rand01(WantTrials) <= BadSPC;
end

% Introduce fast and outliers
if (PctFastOut+PctSlowOut) > 0
    Rand01 = rand(NTrials,1);
    WantFast = Rand01 < PctFastOut;
    WantSlow = Rand01 > 1 - PctSlowOut;
    Z = randn(NTrials,1);
    FastRT = Z*SDFastOut + MnFastOut;
    SlowRT = Z*SDSlowOut + MnSlowOut;
    Trials.RT(WantFast) = FastRT(WantFast);
    Trials.RT(WantSlow) = SlowRT(WantSlow);
end

if RoundRT
    Trials.RT = floor(Trials.RT+0.5);
end

end


function Trials = Demo0Data
% Generate a Trials dataset to be used for demonstration purposes.
% The generated data set will have:
%   Poorer performance in block 1 to simulate a practice effect.
%   Occasional fast and slow outliers
%   3 conditions, with increasing RTs across conditions.
% Here are some parameters describing the data that will be simulated.
FNames  = {'SubNo', 'Blk', 'Cond', 'Replic'};
FLevels = [   20      4       3        15  ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'SubNo','Blk'});
NTrials = height(Trials);

% Some arbitrary RT means and standard deviations for the randomly generated results:
RTmn = 400;
RTsd = 40;
OverallPC = 0.95;  % An overall accuracy rate for each response
RTIncreasePerCondition = 20;

% To simulate a practice effect, make responses slower and less accurate in block 1
Block1RTIncrease = 80;
Block1PCIncrease = -0.10;

CondIncrement = (Trials.Cond-1) * RTIncreasePerCondition;
BlockRTIncrement = zeros(NTrials,1);
BlockRTIncrement(Trials.Blk==1) = Block1RTIncrease;
Trials.RT = randn(NTrials,1)*RTsd + RTmn + BlockRTIncrement + CondIncrement;

BlockPCIncrement = zeros(NTrials,1);
BlockPCIncrement(Trials.Blk==1) = Block1PCIncrease;
Trials.Cor = rand(NTrials,1) < (OverallPC + BlockPCIncrement);

end


function Trials = DemoGroupsData

% Generate a demo data set with 3 groups of Ss and 4 Blocks x 2 conditions per subject.

NGroups = 3;
NSubsPerGroup = 10;

FNames  = {'SubNo',        'Group',  'Blk', 'Cond', 'Replic'};
FLevels = [NSubsPerGroup    NGroups        4       2      40    ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'Group','SubNo','Blk'});
NTrials = height(Trials);

% At this point there are subjects 1-10 in each group, but the analysis routines
% assume that each different subject has a unique number.  Fix that:
Trials.SubNo = Trials.SubNo + NSubsPerGroup*(Trials.Group-1);

% Generate RTs:
RTmn = 500;
RTsd =  50;
PctCor = 0.90;

SubjEffect = randn(NGroups*NSubsPerGroup,1)*50;  % Random subject main effect with mu=0 & sigma=50.
GroupEff = 50;        % Increase to make a bigger difference between groups.
CondEff = 20;         % Increase to make a bigger difference between conditions.

Trials.RT = randn(NTrials,1)*RTsd + RTmn + GroupEff*(Trials.Group-1)  + CondEff*(Trials.Cond-1) + SubjEffect(Trials.SubNo);
Trials.Cor = rand(NTrials,1) <= PctCor;

end


function Trials = DemoBinData

% Cond refers to the condition whose effect we will look at.
% DummyBin is a pretend factor that will be used to introduce SATs
% into the data for the CAF analysis to find and to introduce
% a change in effect size with RT for the delta plot analysis to find.
FNames  = {'SubNo', 'Blk', 'Cond', 'DummyBin', 'Replic'};
FLevels = [   15      4       2         5         6    ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'SubNo','Blk'});
NTrials = height(Trials);

% Generate RTs:
RTmn = 500;
RTsd =  50;

RTCondEff = 100;        % Increase to make a bigger RT difference between conditions (Cond 2 slower).
MsecPerDummyBin = 40;  % Increase RTs in trials with higher DummyBin numbers.

Trials.RT = randn(NTrials,1)*RTsd + RTmn ... % sort of an RT baseline
    + RTCondEff*(Trials.Cond-1) ...  % Add in an effect for condition 2
    + MsecPerDummyBin*Trials.DummyBin./Trials.Cond;  % Increase RTs in higher bins but only half as much for condition 2 (to make a decreasing delta plot)

% Generate each trial's accuracy.

% First define some target PC values for the different condition/bin combinations
PC = [0.75 0.55;  ... % PC for Conds 1 & 2 for DummyBin == 1
      0.80 0.65;  ... % PC for Conds 1 & 2 for DummyBin == 2
      0.85 0.75;  ... % PC for Conds 1 & 2 for DummyBin == 3
      0.90 0.85;  ... % PC for Conds 1 & 2 for DummyBin == 4
      0.95 0.95];     % PC for Conds 1 & 2 for DummyBin == 5
   
Trials.PC = PC(sub2ind(size(PC),Trials.DummyBin,Trials.Cond));   % assign each trial its defined PC
Trials.Cor = rand(NTrials,1) < Trials.PC;  % assign each trials its 0/1 Cor value with desired PC
Trials.PC = [];  % No longer needed

Trials.DummyBin = [];  % No longer needed

end


function Trials = DemoSeqData

% This data set has a compatibility factor with 2 levels.
% The compatibility effect will be larger when the previous trial was compatible (1)
% than when it was incompatible (2).
FNames  = {'SubNo', 'Blk', 'Compat', 'Replic'};
FLevels = [   15      4       2         40    ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'SubNo','Blk'});
NTrials = height(Trials);

% Create a new variable called Trials.Seq with codes 0,1,2:
% 0 : other (e.g., first trial in block)
% 1 : previous trial compatible
% 2 : previous trial incompatible

Trials.Seq = nan(height(Trials),1);  % Make a new variable for the labels.

% The next command returns a list of boolean, one per trial, indicating whether each trial meets the criteria
% for having Seq code 1.  Note we are checking not only the Compat value of the previous trial but also checking
% to make sure that the trial came from the same subject & block.
PrevCompat = SeqFinder(Trials,-1,'Trials.Compat(CheckTrial)==1&Trials.SubNo(CheckTrial)==Trials.SubNo(CurrentTrial)&Trials.Blk(CheckTrial)==Trials.Blk(CurrentTrial)');
Trials.Seq( PrevCompat  ) = 1;

PrevIncompat = SeqFinder(Trials,-1,'Trials.Compat(CheckTrial)==2&Trials.SubNo(CheckTrial)==Trials.SubNo(CurrentTrial)&Trials.Blk(CheckTrial)==Trials.Blk(CurrentTrial)');
Trials.Seq( PrevIncompat  ) = 2;

% Generate RTs:
RTmn = 500;
RTsd =  50;
Trials.RT = randn(NTrials,1)*RTsd + RTmn; % sort of an RT baseline
% Now put in the +/- compatibility effect depending on each trial's Compat & Seq.
Trials.RT(Trials.Compat==1&Trials.Seq==1) = Trials.RT(Trials.Compat==1&Trials.Seq==1) - 50;
Trials.RT(Trials.Compat==2&Trials.Seq==1) = Trials.RT(Trials.Compat==2&Trials.Seq==1) + 50;
Trials.RT(Trials.Compat==1&Trials.Seq==2) = Trials.RT(Trials.Compat==1&Trials.Seq==2) - 10;
Trials.RT(Trials.Compat==2&Trials.Seq==2) = Trials.RT(Trials.Compat==2&Trials.Seq==2) + 10;

% Generate each trial's accuracy.
Trials.PC = ones(NTrials,1);   % Create the variable.
Trials.PC(Trials.Compat==1&Trials.Seq==1) = 0.99;
Trials.PC(Trials.Compat==2&Trials.Seq==1) = 0.90;
Trials.PC(Trials.Compat==1&Trials.Seq==2) = 0.96;
Trials.PC(Trials.Compat==2&Trials.Seq==2) = 0.94;
Trials.Cor = rand(NTrials,1) < Trials.PC;  % assign each trials its 0/1 Cor value with desired PC
Trials.PC = [];  % No longer needed

Trials.Seq = [];  % Kill this variable that was used in construction.
                  % It will be created again in DemoSeq, because that is where it would
                  % normally be generated in analyzing an experiment.
end


function Trials = DemoRMIData

% Red refers to the redundancy condition whose effect we will look at.
%  Red=1 & Red=2 are the single-stimulus conditions, and Red=3 is redundant.
FNames  = {'SubNo', 'Blk', 'Red', 'Replic'};
FLevels = [   15      4       3     40    ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'SubNo','Blk'});
NTrials = height(Trials);

% Generate RTs:
RTmn = 500;
RTsd =  50;

RTRedEff = 100;        % Increase to make a bigger RT difference between redundant and single.

Trials.RT = randn(NTrials,1)*RTsd + RTmn;
Trials.RT(Trials.Red==3) = Trials.RT(Trials.Red==3) - RTRedEff;
Trials.Cor = ones(NTrials,1);

end


function Trials = DemoTSD_YNData

% Stim = 2 refers to signal trials, stim = 1 refers to noise trials.
% Resp = 2 refers to "yes/signal" response, Resp = 1 refers to "no/noise" response.

% Use a lot of short blocks for convenience: Computations for each block separately
% are likely to lead to some Probabilities of 0 and 1, requiring adjustment,
% whereas computations pooling blocks are not.

NSubs = 15;
FNames  = {'SubNo', 'Blk', 'Cond', 'Stim', 'Replic'};
FLevels = [ NSubs     40       2       2     10    ];
Trials = TrialFrame(FNames,FLevels,'Shuffle','Drop','Replic','SortBy',{'SubNo','Blk'});
NTrials = height(Trials);

dPrime = 0.5;
Criterion = linspace(-1.5,1.5,NSubs) + dPrime/2;  % Unbiased criterion for middle SubNo gives Beta=1

Trials.Resp = ones(NTrials,1);   % Initialize all to "no/noise" responses.

Evoked = randn(NTrials,1) + (Trials.Stim - 1.5) * dPrime .* Trials.Cond;

Trials.Resp(Evoked>Criterion(Trials.SubNo)') = 2;  % Set to "yes/signal" response if the evoked signal strength was larger than criterion.

end
