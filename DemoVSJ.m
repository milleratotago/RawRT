% DemoVSJ
% This demo illustrates the use of the RT outlier-exclusion methods of Van Selst & Jolicoeur (1994)

Trials = DemoData('Demo0','PctSlow',.05);  % Include 5% slower outliers

CondSpecs = {'SubNo','Blk','Cond'};

% Here are the regular means for correct trials, just for comparison purposes:
RegularMeans = CondMeans(Trials,'RT',CondSpecs,'Exclude',Trials.Cor==0);

% Here are the means for correct trials for the VSJ modified recursion procedure
% with the moving SD criterion:
VSJModRecurMeans = CondMeansVSJ(Trials,'RT',CondSpecs,...
    VSJmnRTs.cModRecur, ...       % This integer value indicates which of the VSJ procedures we want.
                        ...       % Here we are using the modified recursive procedure with moving criterion.
                        ...       % The various options are shown in the file VSJmnRTs.m
    'Exclude',Trials.Cor==0, ...  % Analyze correct only, same as for RegularMeans
    'DropOutputs',[false, false, false, true]);  % See below
% Explanation of DropOutputs:
%  By default, CondMeansVSJ produces at least 4 outputs, depending on which VSJ procedure is used.
%  The last output is a vector indicating, trial by trial, whether each trial was excluded or not.
%  Trying to keep that output will cause CondMeansVSJ to bomb unless there are equal numbers of
%  trials in all conditions, after error exclusion.  Since we don't usually want that output,
%  for simplicity we will just drop it here.

% The automatically generated variable names in the table are not too helpful,
% so this will rename the three outputs that are not dropped to something more intuitive:
NCondSpecs = numel(CondSpecs);
VSJModRecurMeans.Properties.VariableNames{NCondSpecs+1} = 'ModRecurMn';
VSJModRecurMeans.Properties.VariableNames{NCondSpecs+2} = 'PropTooLow';
VSJModRecurMeans.Properties.VariableNames{NCondSpecs+3} = 'PropTooHi';

% Here is a scatter plot of the modRecur means against the regular means,
% pooling across Ss, blocks, and conditions.  Note that the means are
% often equal--on the diagonal--which indicates that no outliers were excluded.
% Where the point lies below the diagonal, you know that some RTs were
% excluded by modRecur for that analysis.  Whether this is a good thing
% or not, we have no way to judge from this plot (or any other, really),
% but you can see that the outlier exclusion did make a big difference.
plot(RegularMeans.RT,VSJModRecurMeans.ModRecurMn,' .')
hold on
plot([300 1200],[300 1200])
xlabel('Regular');
ylabel('ModRecur');

%% Here is the same thing again but with a different exclusion procedure:
VSJModRecurSDMeans = CondMeansVSJ(Trials,'RT',CondSpecs,...
    VSJmnRTs.cModRecurSD, ...     % Use the modified recursion criterion with a fixed SD criterion.
    3.0,                  ...     % This procedure needs an extra parameter--the value of the fixed SD, here 3.0
                          ...     % The various options are shown in the file VSJmnRTs.m
    'Exclude',Trials.Cor==0, ...  % Analyze correct only, same as for RegularMeans
    'DropOutputs',[false, false, false, true]);  % See below

NCondSpecs = numel(CondSpecs);
VSJModRecurSDMeans.Properties.VariableNames{NCondSpecs+1} = 'ModRecurSDMn';
VSJModRecurSDMeans.Properties.VariableNames{NCondSpecs+2} = 'PropTooLow';
VSJModRecurSDMeans.Properties.VariableNames{NCondSpecs+3} = 'PropTooHi';

figure;
plot(RegularMeans.RT,VSJModRecurSDMeans.ModRecurSDMn,' .')
hold on
plot([300 1200],[300 1200])
xlabel('Regular');
ylabel('ModRecurSD');


% Here is a scatter plot of the modRecur means against the ModRecurSD means,
figure;
plot(VSJModRecurMeans.ModRecurMn,VSJModRecurSDMeans.ModRecurSDMn,' .')
hold on
plot([300 1200],[300 1200])
xlabel('ModRecur');
ylabel('ModRecurSD');
