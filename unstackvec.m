function outtbl = unstackvec(intbl,sDVs,CondCol)
% Unstack intbl putting each variable into a single column as a vector.
% Whereas unstack produces a table with columns like this:
%  sDV1_Cond1  sDV1_Cond2  sDV1_Cond3 ...   sDV2_Cond1  sDV2_Cond2  sDV2_Cond3 ...
%       0           3          5 ...
%  unstackvec produces a table with columns that are vectors, like this:
%   sDV1    ...   sDV2
%  0  3  5  ...

[sDV, NDVs] = EnsureCell(sDVs);

outtbl = unstack(intbl,sDVs,CondCol);
% WARNING HERE: unstack warns about modifying variable names because CondCol labels are integers rather than strings.

BeforeCols = width(intbl);
IndicatorCols = BeforeCols - NDVs - 1;  %  minus 1 refers to RemoveCall
AfterCols = width(outtbl);
NDistinct = (AfterCols - IndicatorCols) / NDVs;

% Create one output DV vector for each input DV.
for iDV=1:NDVs
    outtbl.(sDVs{iDV}) = NaN(height(outtbl),NDistinct);
end

% Copy each individual column into its position within its vector.
iCol = IndicatorCols;
for iDV=1:NDVs
    for iDistinct=1:NDistinct
        iCol = iCol + 1;
        outtbl.(sDVs{iDV})(:,iDistinct) = outtbl.(outtbl.Properties.VariableNames{iCol})(:);
    end
end

% Remove the individual columns that have been copied into the vectors.
iCol = IndicatorCols+1;  % Doesn't change as columns are removed.
for iDV=1:NDVs
    for iDistinct=1:NDistinct
        outtbl.(outtbl.Properties.VariableNames{iCol}) = [];
    end
end

end
