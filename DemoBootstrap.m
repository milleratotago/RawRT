% This demo illustrates functions that can be used for bootstrapping, specifically:
%   * CondBootsample: Generate bootstrap samples one by one, which you can then analyze however you want.
%   * CondBootstrap: Generate bootstrap samples and do a specific analysis on each one.

% NEWJEFF: Add CondCIs

%% Generate some simulated data for a demonstration.
Trials = DemoData('DemoPaired');


%%  Demo of function CondBootsample.
% For this example, we will bootstrapp a correlation.
nBootSamples = 10;  % Obviously you would want a lot more for any real analysis.
AllResults = table;  % Make an empty table to accumulate the results in.
for iSample=1:nBootSamples
    % Generate samples one by one.
    OneSample = CondBootsample(Trials,{'SubNo','Trty'});
    % For each sample, compute the desired analysis.
    OneResult = CondCorrs(OneSample,'RT1','RT3',{'SubNo','Trty'});
    OneResult.iSample = iSample*ones(height(OneResult),1);  % Save the sample number in case you want it.
    AllResults = [AllResults; OneResult];  % Accumulate the results across samples.
end
% AllResults now has the correlations for all bootstrap samples,
% and we might for example average those:
CondMeans(AllResults,'r',{'SubNo','Trty'})
% or see how many were significant:
CondNs(AllResults,{'SubNo','Trty'},'Include',AllResults.p<.05)

%%  Demo of function CondBootstrap, I.
% Here again we will bootstrap the correlation, but we will do it without the for loop.
nBootSamples = 100;  % Probably you would want a lot more for any real analysis.
% The following string shows the MATLAB command that we would like to evaluate on
% each of the bootstrap samples.  Note the double quotes to get a single quote inside a string.
% CondBootstrap will bootstrap any MATLAB command that produces a table as output.
sEval = 'CondCorrs(OneSample,''RT1'',''RT3'',{''SubNo'',''Trty''});';
AllResults2 = CondBootstrap(Trials,{'SubNo','Trty'},sEval,nBootSamples);
% AllResults2 now has the correlations for all bootstrap samples,
% and we might for example average those:
CondMeans(AllResults2,'r',{'SubNo','Trty'})
% or see how many were significant:
CondNs(AllResults2,{'SubNo','Trty'},'Include',AllResults2.p<.05)
% or compute bootstrap confidence intervals around each one,
% taking advantage of the fact that MATLAB's ttest routine produces
% confidence intervals.
Condttest(AllResults2,'r','',{'SubNo','Trty'})

%%  Demo of function CondBootstrap, II.
% Once again we will bootstrap the correlation.
% This time, though, the output table will only contain
% one line per Trty per simulation, with that line containing
% the average correlation across Ss.  This analysis is equivalent to
% the previous one, except that the output table is more compact.
nBootSamples = 100;  % Probably you would want a lot more for any real analysis.
% Note that CondCorrs produces an output table with separate lines for each subject,
% and then CondMeans takes that table as its input & averages the correlations across Ss.
% The overall table output for each simulation is thus a set of averages across Ss.
sEval = 'CondMeans(CondCorrs(OneSample,''RT1'',''RT3'',{''SubNo'',''Trty''}),''r'',''Trty'')';
AllResults2 = CondBootstrap(Trials,{'SubNo','Trty'},sEval,nBootSamples);
% AllResults2 now has the average correlations for all bootstrap samples.
% In contrast to the previous demo, each bootstrap sample is summarized
% by the average correlation across Ss.
% Now we might for example average these average correlations across bootstrap samples,
CondMeans(AllResults2,'r','Trty')
% or compute bootstrap confidence intervals around each one,
% taking advantage of the fact that MATLAB's ttest routine produces
% confidence intervals.
Condttest(AllResults2,'r','','Trty')


%% Demo of function CondBootstrap, III.
% Bootstrap maximum-likelihood parameter estimation
% This demo also shows how to call an external function
% to compute the starting parameter values for each maximum likelihood fit fit.
nBootSamples = 10;  % Probably you would want a lot more for any real analysis.
sEval = 'CondFitDist(OneSample,''RT1'',{''SubNo'' ''Trty''},ExGauMn(200,20,100),''StartParms'',@LC2008EGStartParms)';
AllResults2 = CondBootstrap(Trials,{'SubNo','Trty'},sEval,nBootSamples);
