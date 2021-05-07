function Rows = FindMatchingTableRows(Tbl,VarNames,VarVals,varargin)
    % Find the numbers of the rows in Tbl with the values
    % given in the number vector VarVals on the variables given in VarNames.
    %
    % Tbl is a table with m variables.
    % VarNames is a cell array of strings naming k variables in Tbl.
    % VarVals is an array of k numeric values specifying the desired
    %   values of the VarNames variables.
    % Rows is a vector with the numbers of the Tbl rows having the desired
    %   values on the indicated variables.
    %
    % varargin should be a boolean; if true, check to make sure exactly one row matches.

    switch numel(varargin)
        case 0
            InsistOn1Match = false;
        case 1
            a = varargin{1};
            if islogical(a)
                InsistOn1Match = a;
            else
                BadArgs;
            end
        otherwise
            BadArgs;
    end
    
    % k = numel(VarVals);
    % matching = true(height(Tbl),1);
    % for kidx=1:k
    %     matching = matching & (abs(Tbl.(VarNames{kidx})-VarVals(kidx))<=Tol);
    % end
    
    % Rows = find(matching);
    
    % Alternate method from Matlab Answers: https://au.mathworks.com/matlabcentral/answers/397162
    % 'byrows',1 makes sure that all variables match correspondingly.
    match=ismembertol(Tbl{:,VarNames},VarVals,'ByRows',true);
    Rows = find(match);
    % assert(all(Rows==Rows2),'Row mismatch');

    if InsistOn1Match
        switch numel(Rows)
            case 0
                error('No matching table row.');
            case 1
                % OK to proceed
            otherwise
                disp('Found rows:');
                Rows
                error('Multiple matching table rows.');
        end
    end

    function BadArgs
            error('Unrecognized argument(s)');
    end
    
end

