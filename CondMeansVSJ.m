function [outResultTable, outDVNames] = CondMeansVSJ(inTrials,sDVs,CondSpecs,Method,varargin)
% Compute means using one of the outlier-exclusion methods considered by Van Selst & Jolicoeur (1994).
% Method is an integer 1-6 indicating which of their methods to use, as defined in the class VSJmnRTs.
%
% varargin options:
%  initial 0-2: none, 'SD', or 'SD' and 'SD2', as needed by the specific method called (see class VSJmnRTs)
%    remainder: Include/Exclude options passed through.

% DropOutputs = [false false false true];

nVSJargs = VSJmnRTs.Props(Method).NParms;
VSJargs = varargin(1:nVSJargs);
OtherArgs = varargin(nVSJargs+1:end);

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,...
    VSJmnRTs.Props(Method).Func,OtherArgs{:},'NPassThru',VSJmnRTs.Props(Method).NParms,VSJargs{:});

end

