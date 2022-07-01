function Trials = CondSimRTsFromFitDist(Trials,CondSpecs,FitDist,parmNames,CondParmsTbl,varargin)  % NEWJEFF: No Demo
    % For each combination of CondSpecs, generate random simulated RTs from the Cupid FitDist
    % using the parameter values for that CondSpec condition indicated in CondParmsTbl.
    %
    % varargin options:
    %
    %   SkipCDFs: By default, CDFs of generated RTs are also computed/saved.
    %   OutDVNames: Default = SimRT/SimCDF
    %   Include/Exclude options passed through.
    %
    % For example:
    %  CondSimRTsFromFitDist(Trials,{'SubNo','Cond'},ExGauMn(400,20,200),CondParmsTbl)
    %  The rows of CondParmsTbl NEED NOT hold the estimated FitDist parameters for the
    %  different combinations of SubNo & Cond _in the same order produced by SubTableIndices_.
    
    [SkipCDFs, varargin] = ExtractNamei({'NoCDFs','SkipCDFs'},varargin);
    WantCDFs = ~SkipCDFs;
    [OutDVNames, varargin] = ExtractNameVali('OutDVNames',{'SimRT','SimCDF'},varargin);
    sSimRT = OutDVNames{1};
    sSimCDF = OutDVNames{2};
    % assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.

    NTrials = height(Trials);
    NConds = height(CondParmsTbl);
    
    [mySubTableIndices, outCondTbl] = SubTableIndices(Trials,CondSpecs,varargin{:});
    assert(NConds==height(outCondTbl),'Number of conditions in CondParmsTbl does not match N of conditions defined by CondSpecs');
    
    SimRTs = single(zeros(NTrials,1));
    if WantCDFs
        SimCDFs = single(zeros(NTrials,1));
    end
    
    for iCond = 1:NConds
        jCond = FindMatchingTableRow2(outCondTbl,iCond,CondSpecs,CondParmsTbl,true);
        CondParms = CondParmsTbl{jCond,parmNames};
        FitDist.ResetParms(CondParms);
        Indices = mySubTableIndices{iCond};
        NSelectedTrials = numel(Indices);
        SimRTs(Indices) = FitDist.Random(NSelectedTrials,1);
        if WantCDFs
            SimCDFs(Indices) = FitDist.CDF(SimRTs(Indices));
        end
    end
    Trials.(sSimRT) = SimRTs;
    if WantCDFs
        Trials.(sSimCDF) = SimCDFs;
    end
    
end  % CondSimRTsFromFitDist
