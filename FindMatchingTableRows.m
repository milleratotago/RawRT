function Rows = FindMatchingTableRows(Tbl,VarNames,VarVals)
    % Find the numbers of the rows in Tbl with the values
    % given in VarVals on the variables given in VarNames.
    %
    % Tbl is a table with m variables.
    % VarNames is a cell array of strings naming k variables in Tbl.
    % VarVals is an array of k numeric values specifying the desired
    %   values of the VarNames variables.
    % Rows is a vector with the numbers of the Tbl rows having the desired
    %   values on the indicated variables.
    
    Tol = .001;
    
    % k = numel(VarVals);
    % matching = true(height(Tbl),1);
    % for kidx=1:k
    %     matching = matching & (abs(Tbl.(VarNames{kidx})-VarVals(kidx))<=Tol);
    % end
    
    % Rows = find(matching);
    
    % Alternate method from Matlab Answers: https://au.mathworks.com/matlabcentral/answers/397162
    % 'byrows',1 makes sure that all variables match correspondingly.
    match=ismembertol(Tbl{:,VarNames},VarVals,Tol,'byrows',1);
    Rows = find(match);
    % assert(all(Rows==Rows2),'Row mismatch');
    
end

