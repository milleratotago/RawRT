function outResultTable = CondSpearKar(Trials,sStimVar,sRespVar,CondSpecs,varargin)
% For each combination of CondSpecs, compute the Spearman-Kaerber estimates of PSE, DL, etc.
%
% Optional arguments:
%
%   'Include' or 'Exclude' with a list of trial selection indicators, as usual.
%
%   'Bootstrap',nSamples : Pass through to SpearKar so that it does bootstrapping.
%   'Plot': Pass through to SpearKar so that it makes a plot for each combination of CondSpecs.

% Get the optional arguments:
[nSamples, varargin] = ExtractNameVali({'Bootstrap','nSamples'},0,varargin);
[WantPlot, varargin] = ExtractNamei('Plot',varargin);

% Cannot check for empty varargin here: May still be varargin's for passing through to CondSRCrossTab & SubTableIndices (WHY BOTH?)
%assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

% Assemble arguments that are to be passed through to SpearKar function:
PassThruArgs = {};
if nSamples>0
   PassThruArgs = [PassThruArgs(:) {'Bootstrap'} {nSamples}];
end
if WantPlot
   PassThruArgs = [PassThruArgs(:); {'Plot'}];
end

[~, outResultTable, outDVName, AllStims, AllResps] = CondSRCrosstab(Trials,sStimVar,sRespVar,CondSpecs,varargin{:},'NoTall');
assert(numel(AllResps)==2,['There should only be two response options, but the variable ' sRespVar ' has more than 2 values.']);

NConds = height(outResultTable);

outResultTable.PSE_SK = zeros(NConds,1);
outResultTable.Sigma_SK = zeros(NConds,1);
outResultTable.DL_SK = zeros(NConds,1);

for iCond = 1:NConds
    Counts = outResultTable.(outDVName{1})(iCond,:);
    n1 = Counts(1:2:end-1);
    n2 = Counts(2:2:end);
    [PSE_SK, Sigma_SK, DL_SK, BootstrapMeans, BootstrapSEMs, BootstrapCIs, ~]  = SpearKar(AllStims,n1,n2,PassThruArgs{:});
    %    OneSubTable = Trials(mySubTableIndices{iCond},:);
    outResultTable.PSE_SK(iCond) = PSE_SK;
    outResultTable.Sigma_SK(iCond) = Sigma_SK;
    outResultTable.DL_SK(iCond) = DL_SK;
    if (iCond==1) && (~isnan(BootstrapMeans(1)))
        % These variables are only needed if there is bootstrapping.
        outResultTable.BootstrapMeans = nan(NConds,3);
        outResultTable.BootstrapSEMs = nan(NConds,3);
        outResultTable.BootstrapLowerCIs = nan(NConds,3);
        outResultTable.BootstrapUpperCIs = nan(NConds,3);
    end
    if ~isnan(BootstrapMeans)
        outResultTable.BootstrapMeans(iCond,:) = BootstrapMeans;
        outResultTable.BootstrapSEMs(iCond,:) = BootstrapSEMs;
        outResultTable.BootstrapLowerCIs(iCond,:) = BootstrapCIs(1,:);
        outResultTable.BootstrapUpperCIs(iCond,:) = BootstrapCIs(2,:);
    end
end

end

