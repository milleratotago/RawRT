function [outResultTable, outDVNames] = CondFitDist(inTable,sDVs,CondSpecs,DistObj,varargin)
    % For each combination of CondSpecs, adjust the parameters of the DistObj to provide
    % the best fit to the observed values of sDVs.
    %
    % varargin options:
    %
    %   'StartParms',Fn
    %      If this parameter is specified, the function Fn(X) should accept a vector
    %      of observed values as input, and it should return a vector of the parameter values
    %      at which to start the search.
    %
    %   Include/Exclude options passed through.
    %
    % If the DistObj.DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
    %   should be set to the desired values before calling this function.
    
    [sFitType, varargin] = ExtractNameVali({'Method','FitType'},'MLE',varargin);
    [NChiSqBins, varargin] = ExtractNameVali('NChiSqBins',-1,varargin);   % Required for ChiSquare fitting
    [Pctiles, varargin] = ExtractNameVali({'Percentiles', 'Pctiles', 'TargetCDFs'}',-1,varargin);   % Required for Percentile fitting
    [StartParmFn, varargin] = ExtractNameVali('StartParms','-10',varargin);
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.
    
    FitOptions = {'MLE' 'Moments' 'ChiSquareBins' 'Percentiles'};
    FitPos = find(strcmpi(sFitType,FitOptions));
    if numel(FitPos)>0
        switch FitPos(1)
            case 1
                NPassThru = 2; % DistObj, StartParmFn
                [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistMLE,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn);
            case 2
                NPassThru = 2; % DistObj, StartParmFn
                [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistMoments,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn);
            case 3
                assert(NChiSqBins>2,'Must specify NChiSqBins>2 to compute ChiSquareBins fits.');
                BinMax = DistObj.MakeBinSet(NChiSqBins);
                NPassThru = 3; % DistObj, StartParmFn, BinMax
                [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistChiSquareBins,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn,BinMax);
            case 4
                assert((min(Pctiles)>0)&&(max(Pctiles)<1),'Must specify percentiles 0-1 to compute percentile fits.');
                NPassThru = 3; % DistObj, StartParmFn, Pctiles
                [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistPercentiles,varargin{:},'NPassThru',NPassThru,DistObj,StartParmFn,Pctiles);
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
    [~, ~, Best, exitflag] = DistObj.EstML(inDVs);
    out = [DistObj.ParmValues Best exitflag];
    if ~UseFn
        DistObj.ResetParms(HoldParms);   % Restore original parameter values
    end
end


function out = FitDistMoments(inDVs,DistObj,StartParmFn)
    UseFn =  isa(StartParmFn, 'function_handle');
    if UseFn
        NewParms = StartParmFn(inDVs);
        DistObj.ResetParms(NewParms);
    else
        HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    end
    ObsMoments = DistObj.MomentsFromScores(inDVs);
    [~, ~, Best, exitflag] = DistObj.EstMom(ObsMoments);
    out = [DistObj.ParmValues Best exitflag];
    if ~UseFn
        DistObj.ResetParms(HoldParms);   % Restore original parameter values
    end
end


function out = FitDistChiSquareBins(inDVs,DistObj,StartParmFn,BinMax)
    UseFn =  isa(StartParmFn, 'function_handle');
    if UseFn
        NewParms = StartParmFn(inDVs);
        DistObj.ResetParms(NewParms);
    else
        HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    end
    BrainDeadHistc=histc(inDVs,BinMax);
    BinProbs = BrainDeadHistc(1:numel(BinMax))/numel(inDVs);
    [~, ~, Best, exitflag] = DistObj.EstChiSq(BinMax,BinProbs);
    out = [DistObj.ParmValues Best exitflag];
    if ~UseFn
        DistObj.ResetParms(HoldParms);   % Restore original parameter values
    end
end


function out = FitDistPercentiles(inDVs,DistObj,StartParmFn,TargetCDFs)
    UseFn =  isa(StartParmFn, 'function_handle');
    if UseFn
        NewParms = StartParmFn(inDVs);
        DistObj.ResetParms(NewParms);
    else
        HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    end
    ObsPctiles = prctileTies(inDVs,TargetCDFs*100);
    if sum(isnan(ObsPctiles)) == 0  % Check whether all percentiles exist
        [~, ~, Best, exitflag] = DistObj.EstPctile(ObsPctiles,TargetCDFs);
        out = [DistObj.ParmValues Best exitflag];
        if ~UseFn
            DistObj.ResetParms(HoldParms);   % Restore original parameter values
        end
    else  % Some percentiles are missing, so skip estimation & return nans.
        out = [nan(size(DistObj.ParmValues)) nan nan];
    end
end

