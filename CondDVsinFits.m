function outDVs = CondDVsinFits(inTrials,sCDF,CondSpecs,FitDist,CondParmTbl,varargin)  % NEWJEFF: No demo
    % Produce a list of DV values for all trials in inTrials, where the DVs are computed
    %  from the sCDF values (i.e., via InverseCDF) relative to the FitDist distribution
    %  with parms in CondParmTbl (for each CondSpec combo).
    %  Return NaN for any excluded trials.
    
    % Inputs:
    %
    %   inTrials  : table holding the trial-by-trial data for all subjects and conditions
    %   sCDF      : name of the variable holding the CDF values that are to be converted back to DV values
    %   CondSpecs : Conditions to be kept separate when computing Z scores (e.g., subject, task, etc)
    %   FitDist   : A Cupid distribution, eg. ExGauMn
    %   CondParmTbl: A table of distribution parameters with one row per combination of CondSpecs.
    %               For each combination of CondSpecs conditions, the FitDist parameters are set
    %               to the values in this table and then FitDist.InverseCDF(sCDF) is computed
    %
    % varargin options:
    %   Include/Exclude options passed through to indicate which trials should be included in
    %      the computation of DV values from CDFs.
    %
    % Outputs:
    %
    %   outDVs : List of DV = InverseCDF(sCDF) values or NaN's.
    
    CondSpecs = EnsureCell(CondSpecs);
    
    NinTrials = height(inTrials);
    outDVs = NaN(NinTrials,1);
    
    FirstParm = numel(CondSpecs)+1;
    LastParm = FirstParm + FitDist.NDistParms - 1;
    ParmList = FirstParm:LastParm;
    [ScoreSubTableIndices, ScoreCondLabels] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(ScoreCondLabels);
    for iCond = 1:NConds
        Indices = ScoreSubTableIndices{iCond};
        thisCondSpecVals = ScoreCondLabels{iCond,:};
        parmsRow = FindMatchingTableRows(CondParmTbl,CondSpecs,thisCondSpecVals,true);
        CondParms = CondParmTbl{parmsRow,ParmList};
        FitDist.ResetParms(CondParms);
        outDVs(Indices) = FitDist.InverseCDF(inTrials.(sCDF)(Indices));
    end
    
end
