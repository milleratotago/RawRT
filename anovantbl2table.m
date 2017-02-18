function [ outtbl, oldcolnames, oldrownames ] = anovantbl2table( tbl, BetweenNames, WithinNames, SubName, varargin )
% Convert a table from the "anovan" output format to a MATLAB table data type,
% possibly with some alterations.

% This routine computes a new ANOVA table based on the output from anovan.
% As I see it, anovan produces the correct df, SS, & MS for each source line,
% but its dfDenom and MSDenom are not what I think they should be.
% Consequently, its F's and ProbF's are not correct either.
%
    

% NEWJEFF IN PROGRESS

% Extract the optional argument requesting changes in the regular fixed-effects F's
% & ProbFs to compensate for anovan's nonstandard error terms.
[FsForFixed,  varargin] = ExtractNamei({'FsForFixed'},varargin);

% Extract the optional argument requesting that F's be computed to test whether
% random components are large relative to the pure "Error" term. 
% Note that MATLAB uses AS as the error term for S, etc,
% when there are within-Ss factors & replications.
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
%newrownames = matlab.lang.makeValidName(tbl(:,1),'ReplacementStyle','delete');
newrownames = tbl(:,1);

outtbl = cell2table(tbl(2:end,2:end));

% [a, MSGID] = lastwarn()

warning('on', MSGID)

outtbl.Properties.VariableNames = newcolnames(2:end);

outtbl.Properties.RowNames = newrownames(2:end);

% Just want the sources and error terms
srctbl = AnovaStructure(BetweenNames, 2*ones(1,numel(BetweenNames)), WithinNames, 2*ones(1,numel(WithinNames)), SubName, 2)
newjeff = outtbl

if FsForFixed
    for iSource=1:height(outtbl)-2  % Skip error and total
        if strcmp(outtbl.Type{iSource},'fixed')
            myErrTerm = srctbl.ErrorTerms(outtbl.Properties.RowNames{iSource});
            outtbl.DenomDefn{iSource} = myErrTerm;
            dfErr = outtbl.df(myErrTerm);
            MSerr = outtbl.MeanSq{myErrTerm};
            outtbl.dfDenom{iSource} = dfErr;
            outtbl.F{iSource} = outtbl.MeanSq{iSource} / MSerr;
            outtbl.ProbF{iSource} = 1 - fcdf(outtbl.F{iSource},outtbl.df(iSource),dfErr);
        end
    end
end


if FsForRandom
    dfErr = outtbl.df('Error');
    MSerr = outtbl.MeanSq{'Error'};
    for iSource=1:height(outtbl)-2  % Skip error and total
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

