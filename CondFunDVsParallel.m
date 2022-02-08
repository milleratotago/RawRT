function bool = CondFunDVsParallel(desiredState)
    % This function is called to set & check whether CondFunDVs should run in
    % parallel across conditions.
    % If it has never been called or was last called with the parameter false,
    % then it returns false and CondFunDVs is NOT run in parallel across conditions.
    % If it was last called with the parameter true, then it returns true
    % and CondFunDVs is run in parallel across conditions.
    persistent state
    if nargin>0
        state = desiredState;
    end
    state = (~isempty(state) && state) || (nargin>0 && desiredState);
    bool = state;
end

