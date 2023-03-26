function [outResultTable, outDVNames] = CondFitDistMLE(inTrials,sDV,CondSpecs,DistToFit,varargin)
    % For each combination of CondSpecs, adjust the parameters of the DistToFit
    %  to provide the best ML fit to the observed values of sDV.
    % This version was derived from CondFitDistTruncPMLE to support parallel processing.
    %
    % Optional varargin parameters:
    %
    %   'StartParms',Fn
    %      If this parameter is specified, the function Fn(X) should accept a vector
    %      of observed values as input, and it should return a vector of the
    %      parameter values at which to start the search.
    %
    %   Include/Exclude options passed through.
    %
    % If the DistToFit.DefaultParmCodes are not to be used (see Cupid), then DistToFit.ParmCodes
    %   should be set to the desired values before calling this function.
    
    [StartParmFn, varargin] = ExtractNameVali('StartParms','-10',varargin);
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.
    UseFn =  isa(StartParmFn, 'function_handle');

    HoldParms = DistToFit.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    NParmsToFit = DistToFit.NDistParms;

    % Code from CondFunsOfDVs to find the list of conditions to be processed and the
    % corresponding sets of trials:
    [CondSpecs, ~] = EnsureCell(CondSpecs);
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    ParmValues = zeros(NConds,DistToFit.NDistParms);
    Best = zeros(NConds,1);
    ExitFlag = zeros(NConds,1);
    funcCount = zeros(NConds,1);

    % ppm = ParforProgressbar(NConds);
    parfor iCond=1:NConds % parfor

        % Extract the DVs to be fit in this condition:
        DVsToFit = inTrials.(sDV)(mySubTableIndices{iCond});

        % Set the starting parameters for the to-be-truncated distribution.
        if UseFn
            NewParms = StartParmFn(DVsToFit);
        else
            NewParms = HoldParms;
        end
        DistToFit.ResetParms(NewParms);

        try
            DistToFit.StartParmsMLE(DVsToFit);
            [~, ~, Best(iCond), ExitFlag(iCond), outstruc] = DistToFit.EstML(DVsToFit);
            funcCount(iCond) = outstruc.funcCount;
            parmests = DistToFit.ParmValues;
            ParmValues(iCond,:) = parmests(1:NParmsToFit);
        catch
            fprintf('Parameter estimation failed for iCond %d of %d.\n',iCond,NConds);
            Best(iCond) = nan;
            ExitFlag(iCond) = -1;
            funcCount(iCond) = -1;
            ParmValues(iCond,:) = nan(1,NParmsToFit);
        end
        % ppm.increment();

    end
    % delete(ppm);

    for iParm=1:NParmsToFit
        outResultTable.(DistToFit.ParmNames{iParm}) = ParmValues(:,iParm);
    end
    outResultTable.Best = Best;
    outResultTable.ExitFlag = ExitFlag;
    outResultTable.funcCount = funcCount;
    
    outDVNames = outResultTable.Properties.VariableNames;

end


