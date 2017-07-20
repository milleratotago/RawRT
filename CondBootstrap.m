function outTable = CondBootstrap(inTrials,CondSpecs,sEval,nSamples,varargin)
% A general-purpose bootstrapping routine.
%
% Inputs:
%   inTrials: A table with the data to be bootstrapped.
%   CondSpecs: Set of conditions to be kept separate when bootstrapping.
%   sEval: A string representing the command to be computed on each bootstrap sample.  Notes (& see examples):
%          o Double-quotes must be used instead of single quotes if you want a quote inside the string.
%          o "OneSample" is the name of the bootstrap sample to be analyzed.
%          o Include/Exclude must normally be specified twice; once within sEval, and once as optional inputs within varargin
%   nSamples: The number of bootstrap samples to be computed.
%
% Optional inputs within varargin:
%   Include, Exclude as usual.
%
% Output:
%   outTable is a concatenation of nSamples different tables.
%   Each one of these tables is produced by executing the sEval command on one bootstrap sample.

% Examples (each produces summaries of 10 bootstrap samples):
%   btsmean = CondBootstrap(inTrials,{'SubNo','Cond'},'CondMeans(OneSample,''RT'',''SubNo'')',10)
%   btsmean = CondBootstrap(inTrials,{'SubNo','Cond'},'CondMeans(OneSample,''RT'',{''SubNo'',''Cond''})',10)
%   btscorr = CondBootstrap(inTrials,{'SubNo','Cond'},'CondCorrs(OneSample,''RT'',''Cor'',{''SubNo'',''Cond''})',10)
%   btsmean = CondBootstrap(inTrials,{'SubNo','Cond'},'CondMeans(OneSample,''RT'',{''SubNo'',''Cond''},''Include'',OneSample.RT>300)',10)
%   btsmean = CondBootstrap(inTrials,{'SubNo','Cond'},'CondMeans(OneSample,''RT'',{''SubNo'',''Cond''},''Include'',OneSample.RT>300)',10,'Include',inTrials.RT>300)

outTable = table;

for iSample=1:nSamples
    OneSample = CondBootsample(inTrials,CondSpecs,varargin{:});
    OneTable = eval(sEval);
    OneTable.Sample = iSample*ones(height(OneTable),1);
    outTable = [outTable; OneTable];
end

end
