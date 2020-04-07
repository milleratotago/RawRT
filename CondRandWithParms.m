function outRands = CondRandWithParms(inTrials,CondSpecs,Dist,CondParms,varargin)   % NEWJEFF: No demo
% Produce a list of random scores, one for each included trial in inTrials.
% Return NaN for any excluded trials.
%
% Inputs:
%
%   inTrials  : table holding the trial-by-trial data for all subjects and conditions
%   CondSpecs : Other conditions to be kept separate when generating random scores (e.g., subject, task, etc)
%   Dist      : a Cupid random variable indicating the distribution used to generate the random scores.
%               Dist has a particular combination of parameters for each combination of CondSpecs.
%               These parameter values are held in the table CondParms.
%   CondParms : Table holding the Dist parameter values to be used for generating random scores.
%               The first k columns of CondParms hold the combinations of CondSpecs, where k is the number of CondSpecs.
%               The next Dist.NDistParms columns hold (for each CondSpec row) the desired parameters of Dist.
%
% varargin options:
%   Include/Exclude options passed through to indicate which trials should be included in
%      computation of mean & sd for Z.  Trials that are _not_ included get Z scores of NaN.
%
% Outputs:
%
%   outRands : List of random values from the indicated Dist with the indicated parameter values.


NinTrials = height(inTrials);
outRands = NaN(NinTrials,1);

k = numel(CondSpecs);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);

FirstParm = numel(CondSpecs)+1;
LastParm = FirstParm + Dist.NDistParms - 1;
ParmList = FirstParm:LastParm;

for iCond = 1:NConds
   Indices = mySubTableIndices{iCond};
   thisCondSpecVals = CondLabels{iCond,:};
   parmsRow = FindMatchingTableRows(CondParms,CondSpecs,thisCondSpecVals,true);
   theseParms = CondParms{parmsRow,ParmList};
   Dist.ResetParms(theseParms);
   outRands(Indices) = Dist.Random(numel(Indices),1);
end

end
