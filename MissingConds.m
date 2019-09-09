function MissingIDs = MissingConds(inTbl,sIDcol,varargin)
    % Find the ID values of inTbl.(sIDcol) with less than a target number of rows.
    % The target number is given in varargin; if it is omitted, the maximum is used.
    IDsCountsPcts = tabulate(inTbl.(sIDcol));  % Rows correspond to distinct values of sIDcol; Cols 1,2,3 are values, counts, pcts.
    if numel(varargin) == 0
       TargetCount = max(IDsCountsPcts(:,2));
    else
       TargetCount = varargin{1};
    end
    MissingSome = IDsCountsPcts(:,2) < TargetCount;
    MissingIDs = IDsCountsPcts(MissingSome,1);
end
