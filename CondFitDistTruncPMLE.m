function [outResultTable, outDVNames] = CondFitDistTruncPMLE(inTrials,sDV,CondSpecs,DistObj,TruncP,varargin)
    % For each combination of CondSpecs, adjust the parameters of a _truncated_ version of the DistObj
    %  to provide the best ML fit to the censored, observed values of sDV.
    %
    %  TruncP is a 2-element vector [LowerP, UpperP]  :
    %     Truncation should exclude the indicated lower and upper proportions of the values of sDV,
    %     rounding down to the next whole number of scores.
    %
    % Optional varargin parameters:
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
    
    [StartParmFn, varargin] = ExtractNameVali('StartParms','-10',varargin);
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.
    UseFn =  isa(StartParmFn, 'function_handle');

    HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
    NParmsToFit = DistObj.NDistParms;

    % Code from CondFunsOfDVs to find the list of conditions to be processed and the
    % corresponding sets of trials:
    [CondSpecs, ~] = EnsureCell(CondSpecs);
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    ParmValues = zeros(NConds,DistObj.NDistParms);
    Best = zeros(NConds,1);
    ExitFlag = zeros(NConds,1);
    funcCount = zeros(NConds,1);

    ppm = ParforProgressbar(NConds);
    parfor iCond=1:NConds

        % Extract the DVs to be fit in this condition:
        OneSetOfDVs = inTrials.(sDV)(mySubTableIndices{iCond});

        % Find the lower and upper truncation points:
        NScores = numel(OneSetOfDVs);
        NDropLow = floor(NScores*TruncP(1));
        NDropHi = floor(NScores*TruncP(2));
        OneSetOfDVs = sort(OneSetOfDVs);
        LowerKeep = NDropLow + 1;
        UpperKeep = NScores - NDropHi;
        TruncatedDVs = OneSetOfDVs(LowerKeep:UpperKeep);

        % Set the starting parameters for the to-be-truncated distribution.
        if UseFn
            NewParms = StartParmFn(TruncatedDVs);
        else
            NewParms = HoldParms;
        end
        DistObj.ResetParms(NewParms);

        % Define the TruncatedP Cupid distribution to be fit.
        % Use -0.5 corrections for continuity.
        if NDropLow > 0
            LowerTruncP = (NDropLow - 0.5) / NScores;
        else
            LowerTruncP = 0;
        end
        if NDropHi > 0
            UpperTruncP = 1 - (NDropHi - 0.5) / NScores;
        else
            UpperTruncP = 1;
        end
        DistObj.StartParmsMLE(TruncatedDVs);
        DistToFit = TruncatedP(DistObj,LowerTruncP,UpperTruncP,'FixedCutoffLow','FixedCutoffHi');

        try
            [~, ~, Best(iCond), ExitFlag(iCond), outstruc] = DistToFit.EstML(TruncatedDVs);
            funcCount(iCond) = outstruc.funcCount;
            parmests = DistToFit.ParmValues;
            ParmValues(iCond,:) = parmests(1:NParmsToFit);
        catch
            % NEWJEFF: Print warning here, maybe diary
            Best(iCond) = nan;
            ExitFlag(iCond) = -1;
            funcCount(iCond) = -1;
            ParmValues(iCond,:) = nan(1,NParmsToFit);
        end
        ppm.increment();

    end
    delete(ppm);

    for iParm=1:NParmsToFit
        outResultTable.(DistObj.ParmNames{iParm}) = ParmValues(:,iParm);
    end
    outResultTable.Best = Best;
    outResultTable.ExitFlag = ExitFlag;
    outResultTable.funcCount = funcCount;
    
    outDVNames = outResultTable.Properties.VariableNames;

end


