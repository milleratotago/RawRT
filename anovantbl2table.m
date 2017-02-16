function [ outtbl, oldcolnames, oldrownames ] = anovantbl2table( tbl, varargin )
% Convert a table from the "anovan" output format to a MATLAB table data type.

% Extract the optional argument requesting that F's be computed to test whether
% random components are large relative to the pure "Error" term. 
[FsForRandom,  varargin] = ExtractNamei({'FsForRandom'},varargin);

% Halt if there are any unprocessed input arguments:
assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);


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

if FsForRandom
    dfErr = outtbl.df('Error');
    MSerr = outtbl.MeanSq{'Error'};
    for iSource=1:height(outtbl)-2  % Skip total and error
        if strcmp(outtbl.Type{iSource},'random')
            outtbl.dfDenom{iSource} = dfErr;
%            outtbl.ET = height(outtbl) - 2;
%            outtbl.Fcrit
            outtbl.F{iSource} = outtbl.MeanSq{iSource} / MSerr;
            outtbl.ProbF{iSource} = 1 - fcdf(outtbl.F{iSource},outtbl.df(iSource),dfErr);
        end
    end
end

end

