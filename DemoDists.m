% function DemoDists(varargin)
% The goals of this demo are to illustrate how different functions can be used
% to examine the full distribution of scores within each condition.

Trials = DemoData('Demo0');
Trials.RTOK = true(height(Trials),1);  % Mark the trials as all OK for the analysis (this demo ignores the possibility of outliers).


% Frequency distribution plots
CondFreqDist(Trials,'RT',{},'Include',Trials.RTOK);  % Overall frequency distribution pooled across all conditions.
CondFreqDist(Trials,'RT',{'Cond'},'Include',Trials.RTOK);  % Separate frequency distribution for each condition.


%% Get percentiles & Vincentized averages, then plot averages:
WantPrctiles = 10:10:90;
[PrctTest, PrctNames] = CondPrctiles(Trials,'RT',{'SubNo','Cond'},WantPrctiles,'Include',Trials.RTOK);
Vincentized = CondMeans(PrctTest, PrctNames,'Cond');
figure('Name','Vincentized %iles of RT');
hold on;
plot(WantPrctiles,Vincentized.RTprctiles(Vincentized.Cond==3,:));
plot(WantPrctiles,Vincentized.RTprctiles(Vincentized.Cond==2,:));
plot(WantPrctiles,Vincentized.RTprctiles(Vincentized.Cond==1,:));
xlabel('Percentile');
ylabel('RT at percentile');
legend('Cond 3','Cond 2','Cond 1');
legend('Location','SouthEast');


%% Get percentages in various bins and average those.:
% Note that BinTops(1) is really the bin bottom.

BinTops = 280:20:420;
[CountTest, CountNames] = CondHistcounts(Trials,'RT',{'SubNo','Cond'},BinTops,'Include',Trials.RTOK);
MeanCounts = CondMeans(CountTest, CountNames,'Cond');
figure;
plot(BinTops(2:end),MeanCounts.RThistcounts(MeanCounts.Cond==1,:));

% end
