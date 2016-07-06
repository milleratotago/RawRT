function PermutedValues = CondPermute(inTrials,sDV,CondSpecs,varargin)
% Produce a list of output values that are randomly permuted versions of the input values,
% permuting only within the combinations of conditions indicated by CondSpecs.
%
% Inputs:
%
%   inTrials  : Table holding the trial-by-trial data for all subjects and conditions
%   sDV : the name of the variable in inTrials that holds the to-be-permuted scores
%   CondSpecs : Conditions to be kept separate when doing the permutations (e.g., subject, task, etc)
%
% varargin options:
%   Include/Exclude options passed through.
%
% Outputs:
%
%   PermutedValues : List of randomly permuted values on inTrials.(sDV).
%     Excluded trials retain their original values;

PermutedValues = inTrials.(sDV);  % Initialize to the original values.

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);
MaxNNeeded = max(cellfun(@numel,mySubTableIndices));
AssignVals = zeros(MaxNNeeded,1);

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    ThisSet = inTrials.(sDV)(Indices);
    ThisSet = Shuffle(ThisSet);
    PermutedValues(Indices) = ThisSet;
end

end
