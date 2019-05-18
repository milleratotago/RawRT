function [outResultTable, outDVNames] = CondFitEGorEWML(inTrials,sRT,CondSpecs,Dist,SigmaProportionInEx,varargin)
    % For each combination of CondSpecs, fit the ex-Gaussian or ex-Wald distribution using EGorEWMLSearch.

    % Inputs:
    %   inTrials, sRT CondSpecs: as usual
    %   Dist: the Cupid ExGauMn or ExWaldMSM distribution to be fit (see EGorEWMLSearch).
    %   SigmaProportionInEx: the starting proportions of RT variance assigned to the exponential (see EGorEWMLSearch).
    %
    % Optional inputs:
    %   Include/Exclude options passed through to SubTableIndices.
    %   NDecPlaces: The number of decimal places to which the parameter estimates must be the same
    %      in order to be considered as not in disagreement (see EGorEWMLSearch). Default = 2.

    % outResultTable has columns for:
    %   mu: estimated mu of ExGauMn or ExWaldMSM
    %   sigma: estimated sigma of ExGauMn or ExWaldMSM
    %   exmean: estimated mean of exponential in ExGauMn or ExWaldMSM
    %   Best:
    %   Disagreement:
    %   LocalBestParms
    %   LocalBestScore

    
    NDecPlaces = ExtractNameVali({'NDecPlaces','NDP'},2,varargin);

    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    outDVNames = cell(7,1);
    outDVNames{1} = UniqueVarname(outResultTable,'mu');
    outDVNames{2} = UniqueVarname(outResultTable,'sigma');
    outDVNames{3} = UniqueVarname(outResultTable,'exmean');
    outDVNames{4} = UniqueVarname(outResultTable,'Best');
    outDVNames{5} = UniqueVarname(outResultTable,'Disagreement');
    outDVNames{6} = UniqueVarname(outResultTable,'LocalParms');
    outDVNames{7} = UniqueVarname(outResultTable,'LocalBest');

    outResultTable.(outDVNames{1}) = zeros(NConds,1);
    outResultTable.(outDVNames{2}) = zeros(NConds,1);
    outResultTable.(outDVNames{3}) = zeros(NConds,1);
    outResultTable.(outDVNames{4}) = zeros(NConds,1);
    outResultTable.(outDVNames{5}) = zeros(NConds,1);
    outResultTable.(outDVNames{6}) = cell(NConds,1);
    outResultTable.(outDVNames{7}) = cell(NConds,1);
    
    for iCond = 1:NConds
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        [GlobalBestParms, GlobalBestScore, Disagreement, LocalBestParms, LocalBestScore] = ...
           EGorEWMLSearch(OneSubTable.(sRT), Dist, SigmaProportionInEx, 'NDecPlaces',NDecPlaces);
        outResultTable.(outDVNames{1})(iCond) = GlobalBestParms(1);
        outResultTable.(outDVNames{2})(iCond) = GlobalBestParms(2);
        outResultTable.(outDVNames{3})(iCond) = GlobalBestParms(3);
        outResultTable.(outDVNames{4})(iCond) = GlobalBestScore;
        outResultTable.(outDVNames{5})(iCond) = Disagreement;
        outResultTable.(outDVNames{6})(iCond) = {LocalBestParms};
        outResultTable.(outDVNames{7})(iCond) = {LocalBestScore};
    end
    
end


