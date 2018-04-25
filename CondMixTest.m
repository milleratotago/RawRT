function [outResultTable, outDVNames, SearchResultsCntrlUni, SearchResultsExptlUni, SearchResultsMix] = ...
        CondMixTest(inTrials,sDV,CondSpecs,sDiffSpec,LevelNums,Cntrl,ExptlUni,ExptlMix,StartingEffectPs,varargin)
    % For each combination of CondSpecs, compute a likelihood ratio test (LRT) to test whether a certain effect
    % is significantly better described as a mixture effect than as a uniform effect, using the method of
    % Miller, J. O. (2006). A likelihood ratio test for mixture effects. Behavior Research Methods, 38, 92–106.
    %
    % Required arguments (see DemoMixTest for an example):
    %   inTrials: data table
    %   sDV : name of the dependent variable used to measure the condition effect
    %   CondSpecs: Label(s) defining the conditions to be kept separate during computation.
    %              For example, one CondSpec would be 'SubNo' if the computations were to be done separately for each subject.
    %   sDiffSpec: String defining the condition for which the effect is to be computed
    %              (i.e., this effect might be better described as a mixture effect).
    %   LevelNums: An array of 2 integers indicating the values of sDiffSpec that are to be compared in determining the effect.
    %              The first integer indicates the control condition, and the second indicates the experimental condition.
    %              That is, the effect being examined is the difference: sDiffSpec(LevelNums(2)) - sDiffSpec(LevelNums(1))
    %   Control, ExptlUni,
    %    and ExptlMix: Each of these parameters is a cell array of one or more Cupid distribution object(s),
    %                      and these distributions are used in fitting the uniform and mixture effects as described below.
    %                      (The only purpose of allowing multiple distributions of each type is to allow multiple starting
    %                      parameter values to increase the chances of finding the best overall fit.)
    % Optional arguments:
    %   Include/Exclude: passed through to CondBinLabels and CondMeans
    %   'SearchOptions',SO: SO is a MATLAB optimset structure passed through to fminsearch
    %   'Verbosity',i: i is an integer (0-3) controlling the amount progress reporting done by CondMixTest
    %                  (0 for no reporting, higher numbers for more reporting)
    %
    % Outputs:
    %   outResultTable: A table summarizing the fits and the LRT.
    %   outDVNames: The names of the variables in outResultTable.
    %   SearchResults...: Tables with reports on the ending points of the various searches with different
    %                  starting points. These can be examined to see how consistently the searches converged on the
    %                  same best parameter values from different starting points, which may give some insight
    %                  into the extent of problems with local minima.
    %
    % Model fitting (In these notes, "ML" stands for "maximum likelihood"; for more details, see Miller, 2006):
    %
    %    Uniform model:
    %
    %       Values of the sDV in the control condition are fit to each of the Control distributions,
    %       and the best ML fit is regarded as "the fit of the uniform model to the control condition".
    %
    %       Values of the sDV in the experimental condition are fit to each of the ExptlUni distributions,
    %       and the best ML fit is regarded as "the fit of the uniform model to the experimental condition".
    %
    %       The overall best ML fit of the uniform model is the product these two best ML values.
    %
    %    Mixture model:
    %
    %       It is more complicated to fit this model because both the control and experimental
    %       distributions must be optimized at the same time.
    %
    %       In brief, the search process tries to find the best combination of Control and ExptlMix
    %       parameters, and P value, maximizing the likelihood of
    %          Control.LnLikelihood(ControlObservations) *
    %           Mixture(1-P,Control,P,ExptlMix).LnLikelihood(ExptlObservations)
    
    [Verbosity, varargin] = ExtractNameVali('Verbosity',1,varargin);
    [SearchOptions, varargin] = ExtractNameVali('SearchOptions',{},varargin);
    SearchOptions = EnsureCell(SearchOptions);
    
    CondSpecs = EnsureCell(CondSpecs);
    
    % Make lists of the indices of the trials to process for each CondSpec:
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    % Extract information about each set of distributions.
    % This version only allows one set of starting Cntrl distributions
    % for both Uni and Mix but I may revise that:
    [CntrlUni, NCntrlUni, CntrlUniParmsStart, NParmsCntrlUni] = DistSetup(Cntrl);
    [ExptlUni, NExptlUni, ExptlUniParmsStart, NParmsExptlUni] = DistSetup(ExptlUni);
    [CntrlMix, NCntrlMix, CntrlMixParmsStart, NParmsCntrlMix] = DistSetup(Cntrl);
    [ExptlMix, NExptlMix, ExptlMixParmsStart, NParmsExptlMix] = DistSetup(ExptlMix);
    
    NStartingEffectPs = numel(StartingEffectPs);
    
    % Allocate arrays to hold the ML and parameter values found in the fminsearches for Mix fits
    TotalMixML = zeros(NCntrlMix,NExptlMix,NStartingEffectPs);
    TotalMixParmsEnd = cell(NCntrlMix,NExptlMix,NStartingEffectPs);
    
    sErrorFn = '-LnLikelihood';           % Minimize this to get maximum likelihood fit
    ConstraintFn = @FitMixConstraintFn;   % This user-supplied function converts fminsearch's suggested parameter values
    % into suggested parameter values for the distributions that are being fit.
    
    % Make a table to hold the main results.
    % Note: outResultTable already exists and has codes for CondSpecs
    % CntrlUniNames = NumberedNames('CntrlUni',NParmsCntrlUni);
    % ExptlUniNames = NumberedNames('ExptlUni',NParmsExptlUni);
    % MixNames = ['EffectP' NumberedNames('CntrlMix',NParmsCntrlMix) NumberedNames('ExptlMix',NParmsExptlMix)];
    CntrlUniNames = strcat('CntrlUni_',CntrlUni{1}.ParmNames(1:NParmsCntrlUni)');
    ExptlUniNames = strcat('ExptlUni_',ExptlUni{1}.ParmNames(1:NParmsExptlUni)');
    MixNames = ['EffectP' strcat('CntrlMix_',CntrlMix{1}.ParmNames(1:NParmsCntrlMix)') strcat('ExptlMix_',ExptlMix{1}.ParmNames(1:NParmsExptlMix)')];
    outDVNames = [CntrlUniNames ExptlUniNames 'UniMaxLnLik' MixNames 'MixMaxLnLik' 'ChiSq' 'p'];
    for iDV=1:numel(outDVNames)
        outResultTable.(outDVNames{iDV}) = nan(NConds,1);
    end
    
    % Make tables to hold the results of individual searches from different starting points:
    % These tables have multiple lines for each CondSpecs combo--one line for each starting position.
    [~, CondValues] = GetCondCombos(inTrials,CondSpecs);
    Cntrl_i = 1:NCntrlUni;
    SearchResultsCntrlUni = allcombtable(CondValues{:},Cntrl_i);
    SearchResultsCntrlUni.Properties.VariableNames = [CondSpecs{:} {'Dist_i'}];
    SearchResultsCntrlUni = AddTableVars(SearchResultsCntrlUni,nan,'LnLik',CntrlUniNames{:});
    Exptl_i = 1:NExptlUni;
    SearchResultsExptlUni = allcombtable(CondValues{:},Exptl_i);
    SearchResultsExptlUni.Properties.VariableNames = [CondSpecs{:} {'Dist_i'}];
    SearchResultsExptlUni = AddTableVars(SearchResultsExptlUni,nan,'LnLik',ExptlUniNames{:});
    Exptl_i = 1:NExptlMix;
    SearchResultsMix =  allcombtable(CondValues{:},Cntrl_i,Exptl_i,StartingEffectPs);
    SearchResultsMix.Properties.VariableNames = [CondSpecs{:} {'Cntrl_i'} {'Exptl_i'} {'StartingP'}];
    SearchResultsMix = AddTableVars(SearchResultsMix,nan,'LnLik',MixNames{:});
    SomeSpecs = numel(CondSpecs) > 0;
    
    for iCond = 1:NConds
        if SomeSpecs
            CurrentCondSpecVals = outResultTable.(CondSpecs{:})(iCond);
        else
            CurrentCondSpecVals = [];
        end
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        CntrlObs = OneSubTable.(sDV)(OneSubTable.(sDiffSpec)==LevelNums(1));
        ExptlObs = OneSubTable.(sDV)(OneSubTable.(sDiffSpec)==LevelNums(2));
        Datasets = [{CntrlObs} {ExptlObs}];
        
        [CntrlUniMaxLnLik, LnLik, ParmsEnd] = FitUni(CntrlUni,CntrlUniParmsStart,iCond,CntrlObs,CntrlUniNames);
        if SomeSpecs
            SRrow = FindMatchingTableRows(SearchResultsCntrlUni,CondSpecs,CurrentCondSpecVals);
        else
            SRrow = 1:NCntrlUni;
        end
        SearchResultsCntrlUni.LnLik(SRrow) = LnLik;
        SearchResultsCntrlUni{SRrow,CntrlUniNames} = cell2mat(ParmsEnd);
        
        [ExptlUniMaxLnLik, LnLik, ParmsEnd] = FitUni(ExptlUni,ExptlUniParmsStart,iCond,ExptlObs,ExptlUniNames);
        if SomeSpecs
            SRrow = FindMatchingTableRows(SearchResultsExptlUni,CondSpecs,CurrentCondSpecVals);
        else
            SRrow = 1:NExptlUni;
        end
        SearchResultsExptlUni.LnLik(SRrow) = LnLik;
        SearchResultsExptlUni{SRrow,ExptlUniNames} = cell2mat(ParmsEnd);
        
        outResultTable.UniMaxLnLik(iCond) = CntrlUniMaxLnLik + ExptlUniMaxLnLik;
        
        % Fit Mixture model:
        for i1=1:NCntrlMix
            for i2=1:NExptlMix
                for i3=1:NStartingEffectPs
                    CntrlMix{i1}.ResetParms(CntrlMixParmsStart{i1});
                    ExptlMix{i2}.ResetParms(ExptlMixParmsStart{i2});
                    Dists{1} = CntrlMix{i1};
                    Dists{2} = Mixture(1-StartingEffectPs(i3),Dists{1},StartingEffectPs(i3),ExptlMix{i2});
                    Dists{2}.SetAdjustMixturePs(true);
                    StartingVals = Dists{2}.ParmsToReals(Dists{2}.ParmValues);
                    % Now perform the actual fit:
                    [Dists, LnLikScores, Penalty] = FitConstrained(Dists,Datasets,sErrorFn,ConstraintFn,StartingVals,SearchOptions{:});
                    TotalMixML(i1,i2,i3) = sum(LnLikScores) - Penalty;
                    TotalMixParmsEnd{i1,i2,i3} = Dists{2}.ParmValues;
                    SRrow = FindMatchingTableRows(SearchResultsMix,[CondSpecs {'Cntrl_i'} {'Exptl_i'} {'StartingP'}],[CurrentCondSpecVals i1 i2 StartingEffectPs(i3)]);
                    SearchResultsMix.LnLik(SRrow) = TotalMixML(i1,i2,i3);
                    SearchResultsMix{SRrow,MixNames} = TotalMixParmsEnd{i1,i2,i3};
                    if Verbosity >= 3
                        disp(['For one search, the best fitted mixture model distributions are ' Dists{1}.StringName ' and ' Dists{2}.StringName]);
                    end
                end % i3
            end % i2
        end % i1
        SearchResultsMix.(MixNames{1}) = 1 - SearchResultsMix.(MixNames{1});  % Because the model parameter is the first probability which is PrEffectAbsent.
        %SearchResults.MixLnLik{iCond} = TotalMixML;
        %SearchResults.MixParmsEnd{iCond} = TotalMixParmsEnd;
        
        [BestMixML, I] = max(TotalMixML(:));
        [CntrlMixMaxi, ExptlMixMaxi, MaxpI] = ind2sub(size(TotalMixML),I);
        if Verbosity >= 2
            disp(['Overall, the best fitted mixture model distributions are ' Dists{1}.StringName ' and ' Dists{2}.StringName]);
        end
        if Verbosity >= 1
            fprintf('Best uniform and mixture MLs are %f and %f.\n',outResultTable.UniMaxLnLik(iCond),BestMixML);
        end
        outResultTable.MixMaxLnLik(iCond) = BestMixML;
        for i=1:numel(TotalMixParmsEnd{CntrlMixMaxi, ExptlMixMaxi, MaxpI})
            outResultTable.(MixNames{i})(iCond) = TotalMixParmsEnd{CntrlMixMaxi, ExptlMixMaxi, MaxpI}(i);
        end
    end
    
    outResultTable.EffectP = 1 - outResultTable.EffectP;  % Parameter is control condition probability
    % Compute ChiSquare value and p value for likelihood ratio tests
    outResultTable.ChiSq = 2*(outResultTable.MixMaxLnLik - outResultTable.UniMaxLnLik);
    outResultTable.p = 1 - ChiSq(1).CDF(outResultTable.ChiSq);
    
    % Nested function(s):
    
    function [UniMaxLnLik, SearchResultsLnLik, SearchParmsEnd] = FitUni(Uni,UniParmsStart,iCond,Obs,DVnames)
        % Fit the Cntrl or Exptl distributions from all starting points.
        % Return the max LnLik value, and store the parameter values in the outResultTable.
        % Also return the LnLik and ending parameters for the individual searches in case
        %  the user would like to check them for consistency.
        % This function is nested so that it can access outResultTable.
        % DVnames is a list of the names of this distribution's variables in outResultTable
        %  where the parameter values are stored.  There should be one name for each parameter.
        NUni = numel(Uni);
        SearchResultsLnLik = zeros(NUni,1);
        SearchParmsEnd = cell(NUni,1);
        for ii=1:NUni
            Uni{ii}.ResetParms(UniParmsStart{ii});
            Uni{ii}.EstML(Obs);
            SearchResultsLnLik(ii) = Uni{ii}.LnLikelihood(Obs);
            SearchParmsEnd{ii} = Uni{ii}.ParmValues;
            if Verbosity >= 3
                disp(['For one search, the best fitted uniform model distribution is ' Uni{ii}.StringName]);
            end
        end
        [UniMaxLnLik, UniMaxi] = max(SearchResultsLnLik);
        if Verbosity >= 2
            disp(['Overall, the best fitted uniform model distribution is ' Uni{UniMaxi}.StringName]);
        end
        UniBestParms = SearchParmsEnd{UniMaxi};
        for ii=1:numel(UniBestParms)
            outResultTable.(DVnames{ii})(iCond) = UniBestParms(ii);
        end
%         SearchResultsLnLik(SRrow) = LnLik;
%         SearchParmsEnd() = cell2mat(ParmsEnd);
    end
    
end % CondMixTest


function [Dists, NDists, DistsParmsStart, NParmsDists] = DistSetup(Dists)
    [Dists,  NDists]  = EnsureCell(Dists);
    DistsParmsStart = cell(NDists,1);
    % Save the distribution parameters so that all fminsearches can be started from the same starting points:
    for iDist=1:NDists
        DistsParmsStart{iDist} = Dists{iDist}.ParmValues;
    end
    % Also count the number of parameters in each distribution.
    NParmsDists = numel(DistsParmsStart{1});
end

