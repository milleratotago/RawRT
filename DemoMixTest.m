%% ********* Demo of CondMixTest: mixture effect test analysis
% The goal of this demo is to illustrate how to carry out a test for a mixture effect as described in
% Miller, J. O. (2006). A likelihood ratio test for mixture effects. Behavior Research Methods, 38, 92–106.
% The available probability distributions are defined in the separate software package Cupid
% available at https://github.com/milleratotago/Cupid
% and you must have the Cupid *.m files on your MATLAB path for this demo to work.


%% Generate some example data for the analysis.
% Presumably you would not need to do this because you already have your own data.

NSubs = 5;
NConds = 2;  % The two conditions compared to assess the effect that may be a mixture.
NTrialsPerCond = 500;
% rng('default');  % Parameter can be any positive integer
Trials = TrialFrame({'SubNo' 'Cond' 'Replic'},[NSubs NConds NTrialsPerCond],'Shuffle','Drop','Replic','SortBy',{'SubNo'});
Trials.RT = nan(height(Trials),1);

% Define the true RT distributions for the two conditions, and then generate simulated RTs for all trials.
% For this example, the Mixture model is correct, and the effect is present on 65% of trials.
ControlDist = ExGauMn(200,20,200);
EffectPresentDist = ExGauMn(300,20,200);
PrEffectPresent = 0.65;
ExperimentalDist = Mixture(1-PrEffectPresent,ControlDist,PrEffectPresent,EffectPresentDist);
Trials.RT(Trials.Cond==1) = ControlDist.Random(NSubs*NTrialsPerCond,1);
Trials.RT(Trials.Cond==2) = ExperimentalDist.Random(NSubs*NTrialsPerCond,1);

% End of generating example data


%% Illustrate the MixTest analysis.

ControlDist  = [ {ExGauMn(200,20,200)} {ExGauMn(300,30,100)} ];  % Search starting points for this distribution
ExptlUniDist = [ {ExGauMn(250,25,100)} {ExGauMn(350,35,100)} {ExGauMn(200,20,150)} {ExGauMn(300,30,150)}  ];  % Search starting points for this distribution
ExptlMixDist = [ {ExGauMn(300,30,100)} {ExGauMn(400,40,100)} {ExGauMn(200,20,200)} {ExGauMn(300,30,200)}  ];  % Search starting points for this distribution
StartingEffectPs = [.4 .6 .8];  % Probability of effect
SearchOptions = optimset('MaxFunEvals',10^7,'MaxIter',10^6);  % By the way, SearchOptions can be used

[outResultTable, outDVNames, SearchResultsCntrlUni, SearchResultsExptlUni, SearchResultsMix] = ...
   CondMixTest(Trials,'RT','SubNo','Cond',[1 2],ControlDist,ExptlUniDist,ExptlMixDist,StartingEffectPs,'SearchOptions',SearchOptions,'Verbosity',2);

SigMix = outResultTable(outResultTable.p<.05,:);
if height(SigMix)>0
    disp('Mixture analyses yielded significant results in these cases:');
    SigMix
else
    disp('No mixture analyses yielded significant results.');
end
