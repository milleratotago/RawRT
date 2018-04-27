function [ outtbl, oldcolnames, oldrownames ] = anovantbl2table( tbl )
% Convert an output table from "anovan" to a MATLAB table data type.

% newnames = matlab.lang.makeValidName(tbl(1,:),'ReplacementStyle','delete');
% tbl(1,:) = newnames;
% newnames = matlab.lang.makeValidName(tbl(:,1),'ReplacementStyle','delete');
% tbl(1,:) = newnames;
MSGID = 'MATLAB:nonIntegerTruncatedInConversionToChar';

warning('off', MSGID);

oldcolnames = tbl(1,1:end);
oldrownames = tbl(1:end,1);
newcolnames = matlab.lang.makeValidName(tbl(1,:),'ReplacementStyle','delete');
newrownames = matlab.lang.makeValidName(tbl(:,1),'ReplacementStyle','delete');

outtbl = cell2table(tbl(2:end,2:end));

% [a, MSGID] = lastwarn()

warning('on', MSGID)

outtbl.Properties.VariableNames = newcolnames(2:end);

outtbl.Properties.RowNames = newrownames(2:end);

end

