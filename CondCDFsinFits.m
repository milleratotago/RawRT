function [outCDFs, CondParmTbl] = CondCDFsinFits(inTrials,sDV,CondSpecs,FitDist,varargin)  % NEWJEFF: No demo
    % Produce a list of CDF values for all trials in inTrials, where the CDFs are computed
    %  relative FitDist distribution with parms in CondParmTbl (for each CondSpec combo).
    %  Return NaN for any excluded trials.
    
    % Inputs:
    %
    %   inTrials  : table holding the trial-by-trial data for all subjects and conditions
    %   sDV       : name of the variable for which Z scores are to be computed
    %   CondSpecs : Conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
    %   FitDist   : A Cupid distribution, eg. ExGauMn
    %
    % varargin options:
    %   ScoreInclude: This is a special option allowing CDFs to be computed also for some trials that
    %      were NOT included in parameter estimation.  To use it, include the optional parameters:
    %          'ScoreInclude',TrialsToScore
    %          TrialsToScore is a list of booleans, one per trial, exactly as would normally be passed with 'Include'
    %   Include/Exclude options passed through to indicate which trials should be included in
    %      estimation of distribution parameters.
    %   'ParmTbl',CondParmsTbll   : A table of distribution parameters with one row per combination of CondSpecs,
    %               to avoid re-fitting these if they have already been fit.
    %               This table may NOT have extra, ignored CondSpecs parameters.
    %
    % Outputs:
    %
    %   outCDFs : List of CDF values or NaN's.
    %   CondParmTbl: The fitted distribution values
    
    [TrialsToScore, varargin] = ExtractNameVali('ScoreInclude',[],varargin);
    [CondParmTbl, varargin] = ExtractNameVali('ParmTbl',[],varargin);

    CondSpecs = EnsureCell(CondSpecs);
    
    NinTrials = height(inTrials);
    outCDFs = NaN(NinTrials,1);
    
    if ~istable(CondParmTbl)
        CondParmTbl = CondFitDist(inTrials,sDV,CondSpecs,FitDist,varargin);
    end
    FirstParm = numel(CondSpecs)+1;
    LastParm = FirstParm + FitDist.NDistParms - 1;
    ParmList = FirstParm:LastParm;
    [ScoreSubTableIndices, ScoreCondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    if numel(TrialsToScore) == NinTrials
        [ScoreSubTableIndices, ScoreCondLabels] = SubTableIndices(inTrials,CondSpecs,'Include',TrialsToScore);
    end
    
    NConds = height(ScoreCondLabels);
    for iCond = 1:NConds
        Indices = ScoreSubTableIndices{iCond};
        thisCondSpecVals = ScoreCondLabels{iCond,:};
        parmsRow = FindMatchingTableRows(CondParmTbl,CondSpecs,thisCondSpecVals,true);
        CondParms = CondParmTbl{parmsRow,ParmList};
        FitDist.ResetParms(CondParms);
        outCDFs(Indices) = FitDist.CDF(inTrials.(sDV)(Indices));
    end
    
end
