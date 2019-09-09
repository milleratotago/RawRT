% DemoIndividDiffs
%
% This demo illustrates how to test for greater-than-chance individual
% differences from subject to subject in the size of an effect or interaction.
% The basic idea is to see whether the subject-to-subject differences are
% larger than one would expect based on the random trial-to-trial RT differences
% within each subject/condition combination.
% For further information about the logic of these analyses, see
% Miller & Schwarz (2018) http://dx.doi.org/10.1037/xge0000367

%% Generate an example data set to use for the demo.
% This data set has one between-Ss factor and two within-Ss factors (3 x 4 x 2 design).
% Normally you would have your own data set in Trials.
Trials = DemoData('DemoGroups');

% Look at the Trials table to see the structure of this data set.

%% Here is a traditional ANOVA averaging across trials within each condition (i.e., for each subject):
CallMrf(Trials,'RT','Group',{'Blk','Cond'},'SubNo','DemoIndividDiffs1');

%% Here is the "trials" analysis to see whether the Blk, Cond & Blk*Cond effects vary across Ss.
% (We do not expect that they would for the demo data, because those data were generated from
%  a model where all Ss had the same underlying RT effects. Of course they might, by chance.)

% This analysis uses MATLAB's 'anovan' routine, so we have to set up
% the parameters that it needs.

% Here are the values of the dependent variable to be analyzed.
% Note that there are 9600 RTs in this example.
DV = Trials.RT;

% Here are the names of the "data labels".  Each data point is labelled
% by indicating the factor levels and also the subject number.
VarNameList = {'Group','SubNo','Blk','Cond'};

% Here are the labels for the 9600 data points. Each cell in this
% cell array has a vector of 9600 values.  The first cell indicates
% the group for each of the 9600 RTs, the second cell indicates the
% subject number, and so on.  The order of these cells should match
% up with the order of the variables in VarNameList.
DataLabels = {Trials.Group,Trials.SubNo,Trials.Blk,Trials.Cond};

% The next bit is the trickiest.
% NestingCodes is a k x k array of 0's and 1's, where k equals
% the number of data labels.  The four rows of this array correspond
% to the four data labels (in order), as indicated by the comments at the right.
% Likewise, the four columns also correspond to the four data labels
% (as I tried to indicate in the comments below the matrix). 
NestingCodes = [0 0 0 0;  ... % Nesting codes for 1st label (Group)
                1 0 0 0;  ... % Nesting codes for 2nd label (SubNo)
                0 0 0 0;  ... % Nesting codes for 3rd label (Blk)
                0 0 0 0]; ... % Nesting codes for 4th label (Cond)
              % ^         a 1 in this column indicates "nested in Group"
              %   ^       a 1 in this column indicates "nested in SubNo"
              %     ^     a 1 in this column indicates "nested in Blk"
              %       ^   a 1 in this column indicates "nested in Cond"
% In this matrix, the value of '1' indicates that the variable
% indicated by the matrix row label is nested in the variable
% indicated by the matrix column label.
%
% In this example, subjects are nested in groups, so we only need
% a single 1 in the SubNo row & Group column to indicate nesting.
% If you had more between-Ss factors, you would need 1's in the SubNo
% row for every column corresponding to a between-Ss factor label.
% See below for an example of a fully within-Ss design.
            
[~,anovantable,~] = anovan(DV,DataLabels, ...
    'model','full','nested',NestingCodes, ...
    'varnames',VarNameList,'display','off');
SaveAnovanTable('DemoIndividDiffs2.anovan',anovantable);
edit('DemoIndividDiffs2.anovan');

% A little explanation of the anovan output:
%
% The following 4 lines test whether the Ss differ
% (a) overall, (b) in the effect of block, (c) in the effect of condition, and (d)
% in the block x condition interaction.  Here are the numbers that I got
% with one random data set.  So, the conclusions would be that the Ss
% differed significantly in overall speed but not in any of the block
% or condition effects.  (If you look at the data-generation routine,
% you will see that an overall random effect of subject was added
% to the RTs, and that is why the analysis has indicated that the Ss
% have different overall mean RTs.)
% Sub(Group)           22703956.08    27    840887.262   343.406   0.000  
% Sub(Group)*Blk         200696.86    81      2477.739     1.012   0.450  
% Sub(Group)*Cond         77451.90    27      2868.589     1.171   0.246  
% Sub(Group)*Blk*Cond    251307.66    81      3102.564     1.267   0.054
%
% The other lines in the anovan output concern effects of block, condition,
% etc, on average across _these particular Ss_.  For any of those effects
% that were significant, you would expect them to generalize to other random
% trials with these same subjects _but not necessarily to a new set of Ss_.
% That is, in this analysis the population is all possible trials with these Ss,
% not all trials with all possible Ss (as in the usual ANOVA).

%% Redo the analysis ignoring the Group factor for an example of a fully within-Ss design.
% Note that this is actually much simpler because NestingCodes is not needed (nothing is nested).

WithinDataLabels = {Trials.SubNo,Trials.Blk,Trials.Cond};
WithinVarNameList = {'SubNo','Blk','Cond'};
[~,anovantable,~] = anovan(DV,WithinDataLabels, ...
    'model','full', ...
    'varnames',WithinVarNameList,'display','off');
SaveAnovanTable('DemoIndividDiffs3.anovan',anovantable);
edit('DemoIndividDiffs3.anovan');

% Comment on the output: Now the df & SS due to Group are included as part of
% the df & SS for subjects, because as far as the ANOVA knows these Ss are
% simply not all equivalent.