function outstrs = RowLabels(InTbl,varargin)
% Generate a cell array of strings describing each row in the table.
% Strings are of the form:
%  VariableName Value '-' VariableName Value '-' VariableName Value ...
%  where '-' is the default separator.  (Change using varargin)

NRows = height(InTbl);
NCols = width(InTbl);
outstrs = cell(NRows,1);

if numel(varargin)==0
    Separator = '-';
else
    Separator = varargin{1};
end

for iRow=1:NRows
    s = '';
    for iCol=1:NCols
        if isreal(InTbl{iRow,iCol})
            thiss = num2str(InTbl{iRow,iCol});
        elseif ischar(InTbl{iRow,iCol})
            thiss = InTbl{iRow,iCol};
        else
            thiss = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(InTbl{iRow,iCol});
        end
        s = [s InTbl.Properties.VariableNames{iCol} thiss Separator];
    end;
    outstrs{iRow} = s(1:end-1); % Drop the final separator
end

end
