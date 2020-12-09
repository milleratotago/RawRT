function [outResultTable, outDVNames] = CondFitDistcensored(inTable,sDVs,CondSpecs,DistObj,Bounds,varargin)
    % For each combination of CondSpecs, adjust the parameters of the DistObj to provide
    % the best fit to the observed values of sDVs, censoring the observed values to be
    % between the two bounds (inclusive of bound end points).
    % RESTRICTED TO MLE FITTING.
    %
    % varargin options:
    %
    %   'StartParms',Fn
    %      If this parameter is specified, the function Fn(X) should accept a vector
    %      of observed values as input, and it should return a vector of the parameter values
    %      at which to start the search.  OUT-OF-BOUNDS OBSERVATIONS ARE REMOVED BEFORE
    %      THE INPUT DATA VECTOR IS PASSED TO THIS FUNCTION.
    %
    %   Include/Exclude options passed through.
    %
    % If the DistObj.DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
    %   should be set to the desired values before calling this function.
    
    [sFitType, varargin] = ExtractNameVali({'Method','FitType'},'MLE',varargin);
    [StartParmFn, varargin] = ExtractNameVali('StartParms','-10',varargin);
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.
    
    FitOptions = {'MLE'};
    FitPos = find(strcmpi(sFitType,FitOptions));
    if numel(FitPos)>0
        switch FitPos(1)
            case 1
                NPassThru = 3; % DistObj, StartParmFn, Bounds
                [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistMLEcensored,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn,Bounds);
        end
    else
        warning('Unrecognized fitting sFitType.  Options are:');
        FitOptions %#ok<NOPRT>
        outResultTable = [];
        outDVNames = [];
        return
    end
    
    
    % Break up and relabel the parameter estimates and maximized fit value in the output table.
    NDVsOut = DistObj.NDistParms + 2;  % Parameters + maximized fit score + exitflag
    outDVNames = cell(NDVsOut,1);
    % NEWJEFF: The outDVNames are not correct for derived distributions, eg convolutions.
    %E.g., the initial fields of the Convolution object are 'BasisRV1', 'BasisRV2', 'CDFRelTol', etc.
    for iParm=1:DistObj.NDistParms
        outDVNames{iParm} = UniqueVarname(outResultTable,DistObj.ParmNames{iParm});
        outResultTable.(outDVNames{iParm}) = outResultTable.(outDVNames1{1})(:,iParm);
    end
    outDVNames{NDVsOut-1} = UniqueVarname(outResultTable,'Best');
    outDVNames{NDVsOut} = UniqueVarname(outResultTable,'ExitFlag');
    outResultTable.(outDVNames{NDVsOut-1}) = outResultTable.(outDVNames1{1})(:,NDVsOut-1);
    outResultTable.(outDVNames{NDVsOut}) = outResultTable.(outDVNames1{1})(:,NDVsOut);
    
    % Remove the variable that held all of the output components.
    outResultTable.(outDVNames1{1}) = [];
    
end


function out = FitDistMLEcensored(inDVs,DistObj,StartParmFn,Bounds)
    if numel(inDVs)==0
        warning('No data: Unable to estimate parameters.');
    end
    TooSmall = inDVs < Bounds(1);
    TooLarge = inDVs > Bounds(2);
    nsTooExtreme = [sum(TooSmall), sum(TooLarge)];
    inDVs = inDVs( (~TooSmall) & (~TooLarge) );  % Exclude scores out of bounds.
    UseFn =  isa(StartParmFn, 'function_handle');
    if UseFn
        NewParms = StartParmFn(inDVs);
        DistObj.ResetParms(NewParms);
    else
        HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    end
    [~, ~, Best, exitflag] = DistObj.EstMLcensored(inDVs,Bounds,nsTooExtreme);
    out = [DistObj.ParmValues Best exitflag];
    if ~UseFn
        DistObj.ResetParms(HoldParms);   % Restore original parameter values
    end
end


