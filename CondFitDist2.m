function [outResultTable, outDVNames] = CondFitDist2(inTrials,sDV,CondSpecs,DistObj,varargin)
    % For each combination of CondSpecs, adjust the parameters of the DistObj to provide
    % the best fit to the observed values of sDV.
    % You can choose among different fitting methods (e.g., EstML, EstMom, etc).
    % You can choose different starting values (possibly a grid) for each combination of CondSpecs.
    %
    % Required inputs:
    %
    %   inTrials  : table holding the trial-by-trial data for all subjects and conditions
    %   sDV       : name of the variable for which Z scores are to be computed
    %   CondSpecs : Conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
    %   FitDist   : A Cupid distribution, eg. ExGauMn
    %
    %   Additional inputs are required for some methods, as described next.
    %
    % varargin optional inputs:
    %
    %   'Method',option  Default is MLE; options are 'MLE' 'Moments' 'ChiSquareBins' 'Percentiles'  'MLEcensored'
    %
    %      Additional parameters are REQUIRED for these methods:
    %        ChiSquareBins: You must specify '',
    %           where
    %        Percentiles: You must specify 'TargetCDFs',CDFlist
    %           where CDFlist is a vector of CDF values at which you want to try to match the predicted & observed, e.g. [0.1:0.2:0.9].
    %        MLEcensored: You must specify 'Bounds',[lower, upper]
    %           where [lower, upper] specifies the lower and upper bounds of the acceptable observations.
    %
    %   'StartParms',startParmsTbl
    %      If this parameter is specified, startParmsTbl must be a table with starting values for the parameter searches.
    %      This table must have all of the columns specified by CondSpecs, plus an additional column called 'Parms'.
    %      Also, it must have at least one row for each combination of CondSpecs in inTrials.
    %      In each row of the table, the value of Parms is a vector giving the starting parameter values for one search.
    %
    %   Include/Exclude options passed through to indicate which trials should be included in
    %      estimation of distribution parameters.
    %
    % Outputs:
    %
    %   outCDFs : List of CDF values or NaN's.
    %   CondParmTbl: The fitted distribution values
    %
    % What happens during fitting:
    %   1. For each new combination of CondSpecs values in inTrials, we find all rows of startParmsTbl
    %      with matching values on the CondSpecs columns.  Say there are kRows such rows; that means there
    %      are kRows sets of parameter values at which to start the search (in the Parms column).
    %      These are the rows of the 2D matrix starting_parms (which may only have 1 row).
    %   2. The distribution is fit kRows times, once starting at each of the different parameter combinations
    %      specified in the kRows sets of starting parameter values of the Parms column.
    %   3. Across the kRows fitting attempts for each combination of CondSpecs, this function saves the
    %      best (i.e., the one that gave the smallest fminsearch error score).
    %
    % NOTES:
    %   If the DistObj.DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
    %     should be set to the desired values before calling this function.
    %   When fitting with EstMLcensored, _include_ the out-of-bounds trials so that they can be counted.
    %     They will be removed when fitting.
    
    [sFitType, varargin] = ExtractNameVali({'Method','FitType'},'MLE',varargin);
    [BinMaxes, varargin] = ExtractNameVali('BinMaxes',-1,varargin);   % Required for ChiSquare fitting
    [Pctiles, varargin] = ExtractNameVali({'Percentiles', 'Pctiles', 'TargetCDFs'}',-1,varargin);   % Required for Percentile fitting
    [Bounds, varargin] = ExtractNameVali({'Bounds', 'Cutoffs'}',nan,varargin);   % Required for EstMLEcensored
    
    [StartParmsTbl, varargin] = ExtractNameVali({'StartParms', 'StartingParms', 'StartingValues'},'-10',varargin);
    
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow Include/Exclude arguments to pass through.
    
    CondSpecs = EnsureCell(CondSpecs);
    
    FitOptions = {'MLE' 'Moments' 'ChiSquareBins' 'Percentiles'  'MLEcensored'};  % This order is assumed in later switch statements.
    FitType = find(strcmpi(sFitType,FitOptions));
    if ~(numel(FitType)==1)
        warning('Unrecognized fitting sFitType.  Options are:');
        FitOptions %#ok<NOPRT>
        outResultTable = [];
        outDVNames = [];
        return
    end
    switch FitType  % Check that required optional parameter has been specified for the chosen FitType.
        case 1
            EstFn = @DistObj.EstML;
        case 2
            EstFn = @DistObj.EstMom;
        case 3
            assert(BinMaxes>2,'Must specify BinMaxes>2 to compute ChiSquareBins fits.');
            EstFn = @DistObj.EstChiSq;
        case 4
            assert((min(Pctiles)>0)&&(max(Pctiles)<1),'Must specify percentiles 0-1 to compute percentile fits.');
            EstFn = @DistObj.EstPctile;
        case 5
            assert(numel(Bounds)==2,'Must specify bounds for censored fits.');
            EstFn = @DistObj.EstMLcensored;
    end
    
    UseParmsTbl =  isa(StartParmsTbl, 'table');
    if ~UseParmsTbl                % If there is no table of starting parameters, save the current
        starting_parms = DistObj.Parms;  % parameters as a row vector to restart with these each time.
    end
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    % Create names of the new outResultTable variables that will hold the estimates (plus 2 extras)
    NDVsOut = DistObj.NDistParms + 2;  % Parameters + maximized fit score + exitflag
    outDVNames = cell(NDVsOut,1);
    % NEWJEFF: The outDVNames are not correct for derived distributions, eg convolutions.
    % E.g., the initial fields of the Convolution object are 'BasisRV1', 'BasisRV2', 'CDFRelTol', etc.
    for iParm=1:DistObj.NDistParms
        outDVNames{iParm} = UniqueVarname(outResultTable,DistObj.ParmNames{iParm});
    end
    outDVNames{NDVsOut-1} = UniqueVarname(outResultTable,'Best');
    outDVNames{NDVsOut} = UniqueVarname(outResultTable,'ExitFlag');
    
    % Create new outResultTable variables to hold the estimates
    for iVar=1:NDVsOut
        outResultTable.(outDVNames{iVar}) = nan(NConds,1);
    end
    
    % Now go through the different combinations of CondSpecs and do the
    % required computations for each one:
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        if UseParmsTbl
            thisCondSpecVals = outResultTable{iCond,CondSpecs};
            parmsRows = FindMatchingTableRows(StartParmsTbl,CondSpecs,thisCondSpecVals,false);
            assert(numel(parmsRows)>0,'No starting parameters specified.');
            starting_parms = StartParmsTbl.Parms(parmsRows,:);
        end
        allDvVals = inTrials.(sDV)(Indices);  % Here are the data to be fit
        switch FitType  % Compute parameters needed by fitting routine
            case 1  %  EstFn = @DistObj.EstML;
                fnParms = {allDvVals};
            case 2  %  EstFn = @DistObj.EstMom;
                ObsMoments = DistObj.MomentsFromScores(allDvVals);
                fnParms = {ObsMoments};
            case 3  %  EstFn = @DistObj.EstChiSq;
                BrainDeadHistc = histcounts(allDvVals,BinMaxes);  % NEWJEFF: Was histc
                BinProbs = BrainDeadHistc(1:numel(BinMaxes))/numel(allDvVals);
                fnParms = {BinMax,BinProbs};
            case 4  %  EstFn = @DistObj.EstPctile;
                ObsPctiles = prctileTies(allDvVals,TargetCDFs*100);
                fnParms = {ObsPctiles, TargetCDFs};
            case 5  %  EstFn = @DistObj.EstMLcensored;
                censoredVals = allDvVals( allDvVals>=Bounds(1) & allDvVals<=Bounds(2) );
                nsTooExtreme = [sum(allDvVals<Bounds(1)), sum(allDvVals>Bounds(2))];
                fnParms = {censoredVals, Bounds, nsTooExtreme};
        end
        
        % call Cupid to actually do the fitting:
        [~,EndingVals,fval,exitflag] = DistObj.EstManyStarts(EstFn,fnParms,starting_parms);
        
        % save the parameter estimates, fval, and exit flag for this condition
        for iParm=1:NDVsOut-2
            outResultTable.(outDVNames{iParm})(iCond) = EndingVals(iParm);
        end
        outResultTable.(outDVNames{NDVsOut-1})(iCond) = fval;
        outResultTable.(outDVNames{NDVsOut})(iCond) = exitflag;
    end  % for iCond
    
end

