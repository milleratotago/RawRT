function limitsOut = UseLoopLimits(desiredLimits)
    % This function is called to set & check limits to be used in loops.
    % If it has never been called or was last called with the parameter [],
    % then it returns an empty array and the loop limits will not be limited
    % If it was last called with the parameter set to some limits (e.g., [1, 10}),
    % then it returns these limits and they are used for the loop.
    persistent limits
    if nargin  > 0
        limits = desiredLimits;
    elseif isempty(limits)
        limits = [];
    end
   limitsOut = limits;
end

