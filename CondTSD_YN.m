function [TSDResultTable, TSDDVName] = CondTSD_YN(Trials,CondSpecs,sStimVar,sRespVar,varargin)
% Summarize accuracy and bias measures for a Yes/No detection task, for each combination of CondSpecs.
% By default, this function computes the values d', Beta, & Criterion (from the theory of signal detection).
% For a good general reference on these measures, see the book: Detection theory: A user's guide, by Macmillan & Creelman.
%
% Input parameters:
%    Trials: The data table.
%    sStimVar: The name of the variable holding the stimulus for the trial.
%              The variable can be coded with any two integers; the smaller denotes signal absent, & the larger signal-present.
%              e.g. 0 (absent) vs 1 (present).
%              e.g. 1 (absent) vs 2 (present).
%              e.g. -22 (absent) vs 48 (present).
%    sRespVar: The name of the variable holding the response for the trial, also coded with any two integers.
%              e.g., 0 ("no/absent") vs 1 ("yes/present").
%
% Optional input parameters:
%
%    Include/Exclude options passed through to SubTableIndices.
%
%    Options to indicate parametric adjustments for PrHit or PrFA equal to 0 or 1 (for details, see
%       Hautus & Lee, 2006, British Journal of Mathematical & Statistical Psychology, vol 59, pp 257-273.
%    '1/2N'
%    'LogLinear'
%
%    'Nonparametric': Option to compute non-parametric measures instead of parametric ones.
%    'Both': Option to compute both parametric & non-parametric measures.

[Both, varargin] = ExtractNamei('Both',varargin);
[Nonparametric, varargin] = ExtractNamei({'Nonparametric','Nonpar','Nonparam'},varargin);
[CorrectLogLinear, varargin] = ExtractNamei({'LogLinear','Log-linear'},varargin);
[Correct1Over2N, varargin] = ExtractNamei({'1/2n','1Over2N'},varargin);

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

assert(~(CorrectLogLinear&&Correct1Over2N),'ERROR: At most one type of adjustment for 0/1 probabilities is allowed');

Parametric = ~Nonparametric;

if Both && Nonparametric
   warning('Nonparametric option ignored because "Both" outputs have been requested.');
end

if Both
   Parametric = true;
   Nonparametric = true;
end

if Nonparametric && (CorrectLogLinear || Correct1Over2N)
   warning('Nonparametric computations are being carried out using LogLinear or 1Over2N correction with nonparametric measures, even though this is nonstandard.');
end

if Correct1Over2N
   AdjustType = 1;
elseif CorrectLogLinear
   AdjustType = 2;
else
   AdjustType = 0;
end

% Check to make sure that there are 2 stimuli and 2 responses.
AllIndices = SubTableIndices(Trials,{},varargin{:});  % A cell array containing a master list of all trials that will be included in this analysis.
AllIndices = AllIndices{1};  % The master list (as a vector rather than a cell).
AllStims = unique(Trials.(sStimVar)(AllIndices))';  % A list of all the different stimuli in these trials.
assert(numel(AllStims)==2,['ERROR: There should be exactly 2 stimuli in the Yes/No task, but the stimuli are these: ' num2str(AllStims) ]);
AllResps = unique(Trials.(sRespVar)(AllIndices))';  % A list of all the different responses in these trials.
assert(numel(AllResps)==2,['ERROR: There should be exactly 2 responses in the Yes/No task, but the responses are these: ' num2str(AllResps)]);

% Construct 4 extra "fake" trials, one with each combination of 2 stimuli x 2 responses.
% These are used to ensure that the crosstab command always produces a 2 x 2 output table, even if some cells are empty.
FakeStims = [AllStims(1) AllStims AllStims(2)]';   %  Essentially  1 1 2 2
FakeResps = [AllResps AllResps]';    %  Essentially  1 2 1 2

[mySubTableIndices, TSDResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});
NConds = height(TSDResultTable);

NHits = zeros(NConds,1);
NFalseAlarms = zeros(NConds,1);
NMisses = zeros(NConds,1);
NCorrectRejections = zeros(NConds,1);

for i = 1:NConds
    Indices = mySubTableIndices{i};
    Counts = crosstab([Trials.(sStimVar)(Indices); FakeStims],[Trials.(sRespVar)(Indices); FakeResps]);
    NHits(i) = Counts(2,2) - 1;   % -1's in next 4 lines remove counts from FakeStim/FakeResp trials that were added.
    NFalseAlarms(i) = Counts(1,2) - 1;
    NMisses(i) = Counts(2,1) - 1;
    NCorrectRejections(i) = Counts(1,1) - 1;
end

NSignal = NHits + NMisses;
NNoise = NFalseAlarms + NCorrectRejections;
Zeros = find(NNoise.*NSignal==0);

if numel(Zeros)
    warning('ERROR: Cannot compute sensitivity and bias measures because there are no signal and/or noise trials in at least one condition.');
    warning('Check the output NSignal and NNoise variables to find out which combinations have this problem.');
end

[PrHit, PrFA] = TSD.PrsFromNsYN(NHits,NFalseAlarms,NSignal,NNoise,AdjustType);

sNHits = UniqueVarname(TSDResultTable,'NHits');
sNMisses = UniqueVarname(TSDResultTable,'NMisses');
sNFalseAlarms = UniqueVarname(TSDResultTable,'NFalseAlarms');
sNCorrectRejections = UniqueVarname(TSDResultTable,'NCorrectRejections');
sNSignal = UniqueVarname(TSDResultTable,'NSignal');
sNNoise = UniqueVarname(TSDResultTable,'NNoise');
sPrHit = UniqueVarname(TSDResultTable,'PrHit');
sPrFA = UniqueVarname(TSDResultTable,'PrFA');

if Parametric
    % Measures based on Gaussian equal-variance TSD model:
    [dPrime, Beta, Criterion] = TSD.dPrimeYN(PrHit, PrFA);
    sdPrime = UniqueVarname(TSDResultTable,'dPrime');
    sBeta = UniqueVarname(TSDResultTable,'Beta');
    sCriterion = UniqueVarname(TSDResultTable,'Criterion');
    TSDResultTable.(sdPrime) = dPrime';
    TSDResultTable.(sBeta) = Beta';
    TSDResultTable.(sCriterion) = Criterion';
    ParamMeasures = [{sdPrime} {sBeta} {sCriterion}];
else
    ParamMeasures = [];
end

if Nonparametric
    % Nonparametric measures:
    [APrime, BDblPrime, BDonaldson] = TSD.NonparamYN(PrHit, PrFA);
    sAPrime = UniqueVarname(TSDResultTable,'APrime');
    sBDblPrime = UniqueVarname(TSDResultTable,'BDblPrime');
    sBDonaldson = UniqueVarname(TSDResultTable,'BDonaldson');
    TSDResultTable.(sAPrime) = APrime;
    TSDResultTable.(sBDblPrime) = BDblPrime;
    TSDResultTable.(sBDonaldson) = BDonaldson;
    NonparamMeasures = [{sAPrime} {sBDblPrime} {sBDonaldson}];
else
    NonparamMeasures = [];
end

TSDResultTable.(sNHits) = NHits;
TSDResultTable.(sNMisses) = NMisses;
TSDResultTable.(sNFalseAlarms) = NFalseAlarms;
TSDResultTable.(sNCorrectRejections) = NCorrectRejections;
TSDResultTable.(sNSignal) = NSignal;
TSDResultTable.(sNNoise) = NNoise;
TSDResultTable.(sPrHit) = PrHit;
TSDResultTable.(sPrFA) = PrFA;
TSDDVName = [ ParamMeasures NonparamMeasures {sNHits} {sNMisses} {sNFalseAlarms} {sNCorrectRejections} {sNSignal} {sNNoise} {sPrHit} {sPrFA}];

end

