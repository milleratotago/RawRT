function outRowNums = TableFindNaNRows(inTbl,ColsToCheck)
    % Make a like of the row numbers for row with all NaNs
    % in the columns listed in ColsToCheck.
    RowIsNaN = false(height(inTbl),1);
    for iRow =1:height(inTbl)
        RowIsNaN(iRow) = all(isnan(inTbl{iRow,ColsToCheck}));
    end
    outRowNums = find(RowIsNaN);
end
