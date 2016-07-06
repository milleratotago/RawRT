function ttestTable = RMIttests(RMIPrctileVals,RMIPrctileValNames,sStim,Prctiles,varargin)
% Evaluate the race model inequality using separate t-tests at each percentile.
% Significant positive t values indicate race model violations.

% Inputs:
%
%   RMIPrctileVals : A table produced as the output of CondRMItable, holding percentiles for each subject and combination of conditions.
%   RMIPrctileValNames : The names of the Pct variables, also produced as the output of CondRMItable.
%   sStim     : Name of variable in RMIPrctileVals holding the 1/2/3/4 condition code for Single1, Single2, Redundant, SumSngl
%   Prctiles  : Vector of numbers 0-100 indicating the percentiles at which to check the RMI
% Optional inputs:
%   Include/Exclude selection criteria.
%
% Outputs:
%
%   ttestTable: Results table with Cols for Pct, X, Y, Z, Bound, t, p

% Select out a specific condition for testing, if necessary.
[RMIPrctileVals, varargin] = MaybeSelect(RMIPrctileVals,varargin{:});

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

% Do RMI t-tests:
RedundPcts = RMIPrctileVals.Pct(RMIPrctileVals.(sStim)==3,:);
SumSglPcts = RMIPrctileVals.Pct(RMIPrctileVals.(sStim)==4,:);
[h, p, ci, stats] = ttest(SumSglPcts,RedundPcts);

%% Now make a table summarizing the t-test results, e.g. for printing:

% Compute the means of the CDFs (i.e., Vincentize), with conditions as rows and Prctiles as cols:
tmpttestTable = CondMeans(RMIPrctileVals,RMIPrctileValNames,sStim);

% Transpose to get the desired table format with conditions as columns and Prctiles as rows, adding Prctiles as Column 1:
ttestTable = array2table([Prctiles' table2array(tmpttestTable(:,RMIPrctileValNames))'],'VariableNames',{'Pcts' 'Single1' 'Single2' 'Redundant' 'SumSgl'});

% Add the t and p values
ttestTable.t = stats.tstat';
ttestTable.p = p';
ttestTable.df = stats.df';

end
