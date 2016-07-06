function outBools = SeqFinder(Trials,TrialOffset,sCondition,varargin)
% Return a list of booleans indicating whether each trial meets a certain condition.
%
% Required Arguments:
%
%   Trials is the table holding the trials information, as usual.
%
%   TrialOffset is an integer indicating the position of the to-be-checked trial relative to the current trial.
%     For example:
%     TrialOffset -1 says to classify the current trial based on the immediately preceding trial
%     TrialOffset -2 says to classify the current trial based on the 2-back preceding trial
%     TrialOffset -3 says to classify the current trial based on the 3-back preceding trial
%     TrialOffset +1 says to classify the current trial based on the immediately following trial
%  
%   sCondition: a STRING specifying the condition to be checked.
%     This string can have any form that MATLAB's eval function can handle and that will return a boolean.
%     At the point when sCondition is eval'ed, the function will have defined the indices CurrentTrial and CheckTrial,
%       where CheckTrial = CurrentTrial+TrialOffset.
%     Typically, sCondition will look something like one of these:
%       'Trials.Trty(CheckTrial)==1'              % Check whether the trial at TrialOffset has Trty==1
%       'Trials.Trty(CheckTrial)==Trials.Trty(CurrentTrial)'   % Checks whether the trial at TrialOffset has the same Trty as the current trial
%
% Optional Arguments:
%
%   'MustMatch',{sVariableNames}: A cell array of variable names.  These variables are checked to make sure they are equal
%      in CurrentTrial and CheckTrial. This can be used, for example, to make sure that only trials from within 
%      the _same subject_ or _same block_ are accepted as meeting the condition defining the sequence.
%     
%
% Output:
%
%   outBools is a vector of booleans, one for each trial in Trials, indicating whether that trial satisfies sCondition.

[MustMatch, varargin] = ExtractNameVali('MustMatch',0,varargin);

if ~isnumeric(MustMatch)
    [MustMatch, NVariables] = EnsureCell(MustMatch);
    for iMatch = 1:NVariables
        VarName = MustMatch{iMatch};
        % Add & only if something is already present.
        if numel(sCondition) > 0
            sCondition = [sCondition '&'];
        end
        sCondition = [sCondition 'Trials.' VarName '(CheckTrial)==Trials.' VarName '(CurrentTrial)'];
    end  % for
end  % if

NTotalTrials = height(Trials);

outBools = false(NTotalTrials,1);

for CurrentTrial=1:NTotalTrials
    CheckTrial = CurrentTrial + TrialOffset;
    if CheckTrial>=1 && CheckTrial<=NTotalTrials
        outBools(CurrentTrial) = eval(sCondition);
    end
end

end % SeqFinder
