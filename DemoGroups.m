% The goals of this demo are to illustrate how to:
%   * organize the data within MATLAB
%   * plot means for a set of conditions
%   * plot frequency distributions of scores, possibly in each of a set of conditions
%   * compute a table of means
%   * carry out an ANOVA

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.

Trials = DemoData('DemoGroups','Replicate');

NGroups = numel(unique(Trials.Group));

%% Plot means:
CondPlot(Trials,'RT',{'Group','Cond'});    % Plot the group mean RT for each condition...
CondPlot(Trials,'RT',{'Cond','Group'});    % ...and vice versa.


%% Run an ANOVA to check for group and condition effects; also include the block factor

DVs = {'RT'};           % name(s) of dependent variable(s)
BetweenFac = {'Group'};      % name(s) of variable(s) coding between-Ss factors
WithinFac = {'Blk','Cond'};  % name(s) of variable(s) coding within-Ss factors
SubFac = 'SubNo';              % name of variable coding subjects factor
OutFileName = 'DemoGroupBlkCondRT';     % name used to write ANOVA output file
CallMrf(Trials,DVs,BetweenFac,WithinFac,SubFac,OutFileName);


%% Correlate the effect size with the mean RT, correlating across Ss.
CondMeansTable = CondMeans(Trials,'RT',{'SubNo','Group','Cond'});
SubMeans =  CondMeans(CondMeansTable,'RT',{'SubNo','Group'});
EffSize = CondDiff(CondMeansTable,'RT',{'SubNo','Group'},'Cond',2,1);

disp('Overall correlation based on all Ss:');
[rho, pval] = corr(SubMeans.RT,EffSize.RTDiffCond2vs1)
disp('Separate correlation for each group individually:');
for iGrp=1:NGroups
    [rho, pval] = corr(SubMeans.RT(SubMeans.Group==iGrp),EffSize.RTDiffCond2vs1(EffSize.Group==iGrp));
    fprintf('Group %d: rho = %5.3f, p = %4.3f\n',iGrp,rho,pval);
end

% Display scattergrams.
figure('Name','Effect size versus mean RT');
hold on;
plot(SubMeans.RT(SubMeans.Group==1),EffSize.RTDiffCond2vs1(EffSize.Group==1),' bo')
plot(SubMeans.RT(SubMeans.Group==2),EffSize.RTDiffCond2vs1(EffSize.Group==2),' go')
plot(SubMeans.RT(SubMeans.Group==3),EffSize.RTDiffCond2vs1(EffSize.Group==3),' ro')
legend('Group 1','Group 2','Group 3')

