function bool = UseParallel(callingFuncName,desiredParallelState)
    % This function is used to control whether parallel processing is used within the function
    % that calls it (i.e., the 'callingFunction'--whatever that function might be doing in parallel).
    %
    % By default, parallel processing is NOT used.
    % 
    % If you want parallel processing within a function, then you must call UseParallel
    % _before_ calling that function to indicate that parallel processing is desired.
    % For example, the following command initializes UseParallel to return true
    % whenever it is called from the function 'RawCDFs'
    %   UseParallel('RawCDFs',true);   % Now UseParallel tell the function RawCDFs to use parallel processing
    %   UseParallel('RawCDFs',false);  % Now UseParallel tell the function RawCDFs NOT to use parallel processing
    % Of course RawCDFs has to call 'UseParallel' and behave appropriately depending on whether
    %   UseParallel returns true or false
    %
    % More formally:
    % If UseParallel has not previously been called by the callingFunction or was most
    % recently called by that function with the parameter false, then UseParallel
    % returns false and the calling function does NOT run itself in parallel.
    % 
    % If UseParallel was last called by the callingFunction with the parameter true,
    % then it returns true and the callingFunction runs itself in parallel. 
    
    persistent desiredParallelStates
    persistent callingFuncNames
    
    if isempty(callingFuncNames)
        callingFuncNames = cell(0,1);
        desiredParallelStates = false(0,1);
    end
    
    if nargin==0
        % Find the callingFunction and return its associated desiredParallelState.
        % If the callingFunction has not previously been called, add it to
        % the list of callingFuncNames and initialize its state to false.
        st = dbstack;
        callingFuncName = st(2).name;
        idx = find(strcmp([callingFuncNames(:)],callingFuncName),1);
        if numel(idx) == 0
            callingFuncNames{end+1} = callingFuncName;
            desiredParallelStates(end+1) = false;
            bool = false;
        else
            bool = desiredParallelStates(idx);
        end
        return
    end

    if nargin==2
        % Store the indicated desiredParallelState for the named calling function.
        % If the callingFunction has not previously been called, add it to
        % the list of callingFuncNames and initialize its state to false.
        idx = find(strcmpi([callingFuncNames{:}],callingFuncName));
        if numel(idx) == 0
            callingFuncNames{end+1} = callingFuncName;
            desiredParallelStates(end+1) = desiredParallelState;
            bool = desiredParallelState;
        else
            desiredParallelStates(idx) = desiredParallelState;
            bool = desiredParallelStates(idx);
        end
        return
    end

end

%{
function bool = UseParallel(desiredState)
    % This function is called to set & check whether parallel processing is desired.
    % If it has never been called or was last called with the parameter false,
    % then it returns false and the calling routine will NOT run itself in parallel.
    % If it was last called with the parameter true, then it returns true
    % and the calling routine runs itself in parallel
    % (whatever that means to the calling routine).
    persistent state
    if nargin>0
        state = desiredState;
    end
    state = (~isempty(state) && state) || (nargin>0 && desiredState);
    bool = state;
end
%}
