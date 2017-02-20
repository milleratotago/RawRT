%% This demo illustrates the use of MATLAB's built-in "anovan" function
%  within the context of the RawRT analysis package.


% First and MOST IMPORTANT example: This example illustrates that anovan does NOT
% always produce the standard sort of ANOVA that one normally sees in Psychology.
Trials = DemoData('DemoGroups','Replicate');
% If you look at the Trials data set that was generated, you will see that this example data set has:
BetweenFacs = {'Group'};      % 3 groups of Ss
WithinFacs = {'Blk', 'Cond'}; % 4 Blocks x 2 Conditions per subject
                              % There are 40 Trials per subject in each block/condition combination.
sDVName = 'RT';
SubName = 'SubNo';

[p0, tbl0, stats0] = CallAnovan(Trials,sDVName,BetweenFacs,WithinFacs,SubName);
% Note the anovan output table that is displayed as a MATLAB figure.  It has several
% features that might be unexpected:
%  - It analyzes all of the individual trials separately, as you can see from the total df.
%  - For the Blk factor, anovan shows F = 0.  Normally we would expect
%        F_Blk = MS_Blk / MS_Blk*SubNo(Group) = 1705.4 / 2477.7 = 0.688
%    so where is F = 0 coming from?
%  - Likewise, if you check some of the other F's, you will see that they do not
%    equal the MS_effect / MS_error-term pattern that you would expect for repeated-measures
%    or mixed ANOVAs.
%  - anovan produces F's for the random terms, e.g., SubNo(Group), Blk*SubNo(Group)
%    Normally, no such F's would be computed in an ANOVA for Psychology.
% Technical note: anovan's tbl0 has a column showing the E[MS], and these are based
% on a different model than that normally used in Psychology.  This is what causes
% the difference in analyses.


% Second example: This illustrates how you can use anovan (in a restricted way) to
% produce the standard sort of ANOVA that one normally sees in Psychology.
% The essential restriction is to make sure that anovan only processes one score per subject
% in each condition (e.g., the average across trials).  In that case, it seems to produce
% the expected results.
[p1, tbl1, stats1] = CallAnovan(Trials,sDVName,BetweenFacs,WithinFacs,SubName,'Function',@mean);
%  - This time anovan analyzes only the means in each condition, because of the final two parameters,
%    as you can see from the much smaller total df.
%  - Now the F the Blk factor is correctly shown as
%        F_Blk = MS_Blk / MS_Blk*SubNo(Group) = 1705.4 / 2477.7 = 0.688
%  - Likewise, if you check the other F's for Group, Cond, and the interactions, you will see that they do
%    equal the MS_effect / MS_error-term pattern that you would expect for repeated-measures
%    or mixed ANOVAs.
%  - anovan still produces F's for the random terms, e.g., SubNo(Group), Blk*SubNo(Group),
%    but you can simply ignore these (you weren't expecting to get them anyway).


% For comparison purposes, here is the same anova as the previous one, produced by Mrf.
CallMrf(Trials,sDVName,BetweenFacs,WithinFacs,SubName,'tempfilename');  %  Note that CallMrf's default is: 'Function',@mean);

% Bottom line: I am not entirely sure what anovan does when there are multiple trials per subject per condition.
% It certainly does not compute things in accordance with the model that I think is standard in Psychology,
% so you probably don't want to use it unless you know exactly what you are doing.
