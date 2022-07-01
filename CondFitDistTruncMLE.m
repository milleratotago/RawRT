function [outResultTable, outDVNames] = CondFitDistTruncMLE(inTable,sDV,CondSpecs,DistObj,varargin)
    % For each combination of CondSpecs, adjust the parameters of a _truncated_ version of the DistObj
    %  to provide the best fit to the censored, observed values of sDV.
    %
    % Required varargin parameters:  varargin must include exactly one of the following two parameter pairs:
    %
    %    'TruncX',[LowerX, UpperX]  :  Truncation should exclude values of sDV below/above the specified X bounds
    %
    %    'TruncP',[LowerP, UpperP]  :  Truncation should exclude the indicated lower and upper proportions of the values of sDV,
    %                                  rounding down to the next whole number of scores.
    %
    % additional optional varargin parameters:
    %
    %   'StartParms',Fn
    %      If this parameter is specified, the function Fn(X) should accept a vector
    %      of _censored_ observed values as input, and it should return a vector of the
    %      parameter values at which to start the search.
    %
    %   Include/Exclude options passed through.
    %
    % If the DistObj.DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
    %   should be set to the desired values before calling this function.
    
    [TruncX, varargin] = ExtractNameVali('TruncX',[],varargin);
    [TruncP, varargin] = ExtractNameVali('TruncP',[],varargin);
    assert( ...
      (numel(TruncX)==2 && numel(TruncP)==0) || ...
      (numel(TruncX)==0 && numel(TruncP)==2), ...
      'Must specify a 2-element vector for exactly one of TruncX or TruncP');
    [StartParmFn, varargin] = ExtractNameVali('StartParms','-10',varargin);
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.

% NEWJEFF: NOT DONE FROM HERE--DECIDED TO USE SEPARATE FUNCTIONS FOR TRUNCP VS TRUNCX.
% ANYWAY, MAYBE I SHOULD USE WEIGHTING INSTEAD?

    UseTruncP = numel(TruncP)==2;
    NPassThru = 2; % DistObj, StartParmFn
    [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDV,CondSpecs,@FitDistMLE,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn);
    
    % Break up and relabel the parameter estimates and maximized fit value in the output table.
    NDVsOut = DistObj.NDistParms + 3;  % Parameters + maximized fit score + exitflag + funcCount
    outDVNames = cell(NDVsOut,1);
    % NEWJEFF: The outDVNames are not correct for derived distributions, eg convolutions.
    %E.g., the initial fields of the Convolution object are 'BasisRV1', 'BasisRV2', 'CDFRelTol', etc.
    for iParm=1:DistObj.NDistParms
        outDVNames{iParm} = UniqueVarname(outResultTable,DistObj.ParmNames{iParm});
        outResultTable.(outDVNames{iParm}) = outResultTable.(outDVNames1{1})(:,iParm);
    end
    outDVNames{NDVsOut-2} = UniqueVarname(outResultTable,'Best');
    outDVNames{NDVsOut-1} = UniqueVarname(outResultTable,'ExitFlag');
    outDVNames{NDVsOut} = UniqueVarname(outResultTable,'funcCount');
    outResultTable.(outDVNames{NDVsOut-2}) = outResultTable.(outDVNames1{1})(:,NDVsOut-2);
    outResultTable.(outDVNames{NDVsOut-1}) = outResultTable.(outDVNames1{1})(:,NDVsOut-1);
    outResultTable.(outDVNames{NDVsOut}) = outResultTable.(outDVNames1{1})(:,NDVsOut);
    
    % Remove the variable that held all of the output components.
    outResultTable.(outDVNames1{1}) = [];
    
end


function out = FitDistMLE(inDVs,DistObj,StartParmFn)
    if numel(inDVs)==0
        warning('No data: Unable to estimate parameters.');
    end
    UseFn =  isa(StartParmFn, 'function_handle');
    if UseFn
        NewParms = StartParmFn(inDVs);
        DistObj.ResetParms(NewParms);
    else
        HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    end
    [~, ~, Best, exitflag, outstruc] = DistObj.EstML(inDVs);
    out = [DistObj.ParmValues Best exitflag outstruc.funcCount];
    if ~UseFn
        DistObj.ResetParms(HoldParms);   % Restore original parameter values
    end
end


