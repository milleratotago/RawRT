function outtbl = stackvec(intbl,sDV)
    % Split up table variables that are N-element arrays into N rows each.
    %
    % sDV is a string name or cell array indicating the column(s) of intbl
    %  that contain vectors of N elements for each row
    %  (all vectors must contain the same number of elements).
    % outtbl has N times as many rows.
    % in outtbl, each sDV column has a single number.
    % outtbl also has an additional column called [sDV{1} '_N'] with values of
    % 1, 2, 3, .. N indicating each outtbl row's position within the intbl vector.
    
    [sDV, NDVs] = EnsureCell(sDV);
    
    % Store the vectors that are to be stacked and remove them from the input table.
    % Will put them back later as stacked scalers.
    tmp = cell(NDVs,1);
    for iDV=1:NDVs
        tmp{iDV} = intbl.(sDV{iDV});  % hold the value of vec
        intbl.(sDV{iDV}) = [];
    end
    
    VecLen = size(tmp{1},2);  % How many elements in each vector.
    
    % Start the output table by making VecLen copies of each
    % row to replicate the _other_ table variables.
    outtbl = table;
    for iRow=1:height(intbl)
        for j=1:VecLen
            outtbl = [outtbl; intbl(iRow,:)]; %#ok<AGROW>
        end
    end
    
    % Make a variable to label the output rows with the vector positions.
    sDVlbl = [sDV{1} '_N'];
    labels = (1:VecLen);
    labels = repmat(labels,1,height(intbl));
    outtbl.(sDVlbl) = labels';
    
    % Copy the stored vector values into the table
    for iDV = 1:NDVs
        tmp2 = tmp{iDV}';  % reorder so that vector element changes faster than row.
        outtbl.(sDV{iDV}) = tmp2(:);
    end
    
end
