% The goals of this demo are to illustrate how to:
%   * compute Vincentized RT distributions
%   * test the race model inequality with a series of t-tests


%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data
Trials = DemoData('DemoRMI');

Trials.RT = floor(Trials.RT+0.5);   % RTs must be whole numbers for RMITable

Trials.IncludeForRT = Trials.Cor==1;  % Maybe also check RT outlier cutoffs, etc, as you wish.

%% Compute & plot percentiles of the RT distributions, separately for each subject and redundancy condition:

Prctiles = 2.5:5:97.5;

% The next command computes the percentiles for each subject and condition separately.
PrctilesTable = CondPrctiles(Trials,'RT',{'SubNo','Red'},Prctiles,'Include',Trials.IncludeForRT);

% Now make a table with the averages across subjects.
Vincentized = CondMeans(PrctilesTable,'RTprctiles','Red');

% Plot the Vincentized CDF functions of the different Red conditions.
plot(Vincentized.RTprctiles(Vincentized.Red==1,:),Prctiles)
hold on
plot(Vincentized.RTprctiles(Vincentized.Red==2,:),Prctiles)
plot(Vincentized.RTprctiles(Vincentized.Red==3,:),Prctiles)


%% Analysis of Race Model Inequality (RMI) with t-tests
% This section does a simple test of the RMI at each percentile point
% using t-tests.
SOA = 50;
[RMITable, DVList] = CondRMItable(Trials,'RT','Red','SubNo',Prctiles,SOA);
ttestTable = RMIttests(RMITable, DVList,'Red',Prctiles)



%% ANOVA Analysis of Race Model Inequality (RMI)
% This section also tests the RMI at each percentile point, but now using ANOVA
% instead of t-tests.  It gives the same results as the t-test (i.e., same p values)
% if there is only the redundant/sum-single factor. But the ANOVA could also be used
% with an additional factor (e.g., practice level, subject group, etc).

SOA = 50;

[RMITable, DVList] = CondRMItable(Trials,'RT','Red','SubNo',Prctiles,SOA);

CallMrf(RMITable,DVList,{},{'Red'},'SubNo','RMITest1','Include',RMITable.Red>2);  % Include only condition numbers 3 & 4 (Redundant and SumSingle)

RMIMeans = CondMeans(RMITable,DVList,'Red');
NPcts = numel(Prctiles);
Single1Mns=table2array(RMIMeans(RMIMeans.Red==1,end-NPcts+1:end))';
Single2Mns=table2array(RMIMeans(RMIMeans.Red==2,end-NPcts+1:end))';
RedMns=table2array(RMIMeans(RMIMeans.Red==3,end-NPcts+1:end))';
SumSingleMns=table2array(RMIMeans(RMIMeans.Red==4,end-NPcts+1:end))';
figure
plot(Single1Mns,Prctiles,Single2Mns,Prctiles,RedMns,Prctiles,SumSingleMns,Prctiles);

%% Compare the Vincentized Prctiles with those from RMItable. They should be identical.
% These are not quite the same as the percentiles returned by MATLAB's prctile function,
% because that function handles ties differently.
Err1 = Vincentized.RTprctiles(Vincentized.Red==1,1:end) - table2array(RMIMeans(RMIMeans.Red==1,2:end));
Err2 = Vincentized.RTprctiles(Vincentized.Red==2,1:end) - table2array(RMIMeans(RMIMeans.Red==2,2:end));
Err3 = Vincentized.RTprctiles(Vincentized.Red==3,1:end) - table2array(RMIMeans(RMIMeans.Red==3,2:end));
disp('The root mean square difference between the estimates is:');
sqrt((sum(Err1.^2)+sum(Err2.^2)+sum(Err3.^2))/3/numel(Prctiles))


