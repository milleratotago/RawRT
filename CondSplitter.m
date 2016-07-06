function outIndicators = CondSplitter(inTrials,CondSpecs,NinCycle,Randomize,varargin)
% Produce a list of 1/2/3/... output indicators for all trials in inTrials, where the output value i
%  assigns the trial to the i'th condition from within the original set.

% Inputs:
%
%   inTrials  : Table holding the trial-by-trial data for all subjects and conditions
%   CondSpecs : Conditions to be kept separate when doing the splitting (e.g., subject, task, etc)
%   NinCycle: the number of output condition numbers that the routine should cycle through.
%   Randomize: true or false to indicate that the cycle numbers should be randomized on each cycle
%
% varargin options:
%   Include/Exclude options passed through.
%
% Outputs:
%
%   outIndicators : List of 1/2/3/... new condition assignments (or 0 if excluded).

% Examples:
%   Split-half trials in each condition for reliability analysis
%   Randomly divide trials into conditions for simulations

NinTrials = height(inTrials);
outIndicators = NaN(NinTrials,1);

[mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});

NConds = height(CondLabels);
Cycle = 1:NinCycle;
MaxNNeeded = max(cellfun(@numel,mySubTableIndices));
MaxNCyclesNeeded = MaxNNeeded / NinCycle + 1;  % This may be 1 too many, but that does no harm.
AssignVals = zeros(MaxNCyclesNeeded*NinCycle,1);

for iCond = 1:NConds
    Indices = mySubTableIndices{iCond};
    NNeeded = numel(Indices);  % Need one condition number for each indexed trial.
    Used = 0;
    while Used < NNeeded
        if Randomize
            Cycle = Shuffle(Cycle);
        end
        AssignVals(Used+1:Used+NinCycle) = Cycle;
        Used = Used + NinCycle;
    end
    outIndicators(Indices) = AssignVals(1:NNeeded);
end

end
