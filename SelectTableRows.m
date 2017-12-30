function [ResultTbl] = SelectTableRows(SourceTbl,TargetTbl)
% Make an output table containing a subset of the rows in the input table SourceTbl.
% TargetTbl is also a table. It contains a subset of the variables in SourceTbl, and the
%  values of these variables are used to identify the to-be-selected rows.
% Specifically, a row of SourceTbl will be included in ResultTbl if that row matches all of the
%  variables within any one row of TargetTbl.

matchVars = TargetTbl.Properties.VariableNames;

SourceRelevantVars = SourceTbl(:,matchVars);

[~, SourceRowsWanted, ~] = intersect(SourceRelevantVars,TargetTbl);

ResultTbl = SourceTbl(SourceRowsWanted,:);

end

% Before I learned about intersect, I used the following double loop, which was much slower.

%    SourceRowsWanted = false(height(SourceTbl),1);
%    NTargetRows = height(TargetTbl);

%    for iSourceRow=1:height(SourceTbl)
%        MatchFound = false;
%        TargRowToTest = 0;
%    %   thisSourceRow = SourceTbl(iSourceRow,matchVars);
%        while ~MatchFound && (TargRowToTest<NTargetRows)
%            TargRowToTest = TargRowToTest + 1;
%            MatchFound = isequal(thisSourceRow,TargetTbl(TargRowToTest,:));
%        end
%        SourceRowsWanted(iSourceRow) = MatchFound;
%    end

