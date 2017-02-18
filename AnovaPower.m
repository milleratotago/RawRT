classdef AnovaPower < handle  % New version using anovan only for SS
    % Class to perform power-related computations with Anova tables
    % Can also be used to generate & tabulate simulation results.
    
    properties
        
        alpha
        tbl              % The ANOVA table, augmented with extra computations, simulation results, etc, as needed.
        
        BetweenNames      % Cell array of names of between-Ss factors
        WithinNames       % Cell array of names of within-Ss factors
        ExptlNames        % Combined cell array of names of both between & within-Ss factors
        
        NBetween
        NWithin
        NExptl
        
        NGroups
        NSubsPerGroup    % Number of subjects per group
        NSubsTotal
        UniqueSubs       % A list of the subject numbers.
        NReplications    % Number of trials per subject per condition
        
        SubName          % String name of the subjects factor
        FullSubName      % With grouping factors, e.g., S(AB)
        
        BetweenLevels    % List of the number of levels of each experimental factor
        WithinLevels
        ExptlLevels
        
        TrueMeans        % A vector of the true means at each combination of fixed factor levels
        
        FixedSources     % List of row numbers of the fixed sources in tbl.
        RandomSources    % List of row numbers of the random sources in tbl.
        NSources         % Total number of source lines in the ANOVA table (including Error).
        NWithinSources   % Number of fully within-Ss sources in the ANOVA table.
        SrcWithSub       % Array of boolean indicating whether each source includes subject factor
        SourcesWithFs    % A list of the row numbers of the sources for which F's are computed.
        
        NSims            % Number of simulations carried out.
        SimTrials        % A trials table to hold simulated data.
        ErrConstraints   % A cell array, one per source.  Each entry is a cell array
                         % containing a list of error constraints for the source
                         % (empty for all non-error sources).
                         % The entry cell array has a list of the factors across
                         % which the error term must sum to 0; e.g. 'A' and 'B' for ABS.
        RVerr            % A cell array, one per source, of the random variables used for the different error terms.
        ErrSrcName       % A cell array, one per source, of the _variable names_ used for the error sources when generating simulated data.
        TrialVariance    % Error variance divided by NReplications.
        simtbl           % Holds ANOVA from one simulation (the last).
        simtbl1          % Holds plain anovan output from last simulation
        anovanSScol
        anovandfcol
        
    end  % properties
    
    methods (Static)
        
        function thisList = MissingFacs(sSource,CandidateFacs)
            % Get a list of the numbers of the Candidate factors
            % that are NOT part of this source.
            thisList = [];
            for iFac = 1:numel(CandidateFacs)
                PartOfThisSource = numel(strfind(sSource,CandidateFacs{iFac})>0);
                if ~PartOfThisSource
                    thisList = [thisList iFac];%#ok<AGROW>
                end
            end
        end
        
        function irow = FindAnovanRow(anovantbl,sLabel)
            irow = find(strcmp(anovantbl(:,1),sLabel));
        end
        
    end % static methods
    
    methods
        
        function obj = AnovaPower(passBetweenNames,passBetweenLevels,passWithinNames,passWithinLevels,passSubName,passNSubsPerGroup,passNReplications)
            % Define the object & perform some initialization.
            
            %            [obj.NReplications, varargin] = ExtractNameVali({'NReplications','Replications','Replication','NTrials'},1,varargin);
            %            assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);
            
            obj.BetweenNames = passBetweenNames;
            obj.BetweenLevels = passBetweenLevels;
            obj.WithinNames  = passWithinNames;
            obj.WithinLevels  = passWithinLevels;
            obj.SubName = passSubName;
            obj.NSubsPerGroup = passNSubsPerGroup;
            obj.NReplications = passNReplications;
            
            obj.NBetween = numel(obj.BetweenNames);
            obj.NWithin  = numel(obj.WithinNames);
            
            obj.ExptlLevels = [obj.BetweenLevels obj.WithinLevels];
            obj.ExptlNames  = [obj.BetweenNames obj.WithinNames];
            obj.NExptl      = numel(obj.ExptlNames);
            
            obj.NGroups = prod(obj.ExptlLevels(1:obj.NBetween));
            obj.NSubsTotal = obj.NGroups*obj.NSubsPerGroup;
            
            if obj.NReplications==1
                ReplicLevels = [];
                ReplicName = [];
            else
                ReplicLevels = obj.NReplications;
                ReplicName = UniqueVarname([obj.BetweenNames cellstr(obj.SubName) obj.WithinNames],'replic');
            end
            dummyTrials = TrialFrame([obj.BetweenNames cellstr(obj.SubName) obj.WithinNames ReplicName], ...
                          [obj.BetweenLevels obj.NSubsPerGroup obj.WithinLevels ReplicLevels], ...
                          'Between',{obj.BetweenNames,obj.SubName});
            obj.UniqueSubs = unique(dummyTrials.(obj.SubName));  % Make a list of the unique subject numbers
            
            % Determine the ANOVA table structure.
            obj.tbl = AnovaStructure(obj.BetweenNames, obj.BetweenLevels, obj.WithinNames, obj.WithinLevels, obj.SubName, obj.NSubsPerGroup, obj.NReplications);
            obj.SourcesWithFs = find(obj.tbl.ETnum>0);
            obj.NSources = height(obj.tbl);
            obj.NWithinSources = 2^obj.NWithin - 1;
            obj.FixedSources = find(obj.tbl.SourceIsFixed);
            obj.RandomSources = find(~obj.tbl.SourceIsFixed);
            obj.anovanSScol = 2;  % the column number in which anovan output tables store the SS
            obj.anovandfcol = 3;  %  and df values
            iSubTerm = find(~obj.tbl.SourceIsFixed);
            obj.FullSubName = obj.tbl.Properties.RowNames{iSubTerm};
        end
        
        function iRow = RowNameToNum(obj,sName)
            iRow = find(strcmp(sName,obj.tbl.RowNames));
        end
        
        function setFcrits(obj,passalpha)
            obj.alpha = passalpha;
            obj.tbl.Fcrit = nan(obj.NSources,1);
            for iSource = 1:obj.NSources
                thisET = obj.tbl.ETnum(iSource);
                if thisET>0
                    obj.tbl.Fcrit(iSource) = finv(1-obj.alpha,obj.tbl.df(iSource),obj.tbl.df(thisET));
                end
            end
        end
        
        function setSigmas(obj,SigmaList)
            % This routine just stores the designated error terms (specified in SigmaList)
            % in the corresponding rows of tbl.Sigma.
            % Note that the order in SigmaList MUST MATCH the row order in tbl.  NEWJEFF: WHICH IS NOT THE SAME AS anovan
            obj.tbl.Sigma = nan(obj.NSources,1);
            nUsed = 0;
            for iSource = 1:obj.NSources
                thisSource = obj.tbl.Properties.RowNames(iSource);
                loc = strfind(thisSource,obj.SubName);
                loc = loc{1};
                if (numel(loc)>0) || (strcmp(thisSource,'Error'))
                    nUsed = nUsed + 1;
                    obj.tbl.Sigma(iSource) = SigmaList(nUsed);
                end
            end
            if nUsed < numel(SigmaList)
                warning(['Ignored last ' num2str(numel(SigmaList)-nUsed) ' values in SigmaList.']);
            end
        end
        
        function setThetaSqrs(obj,passTrueMeans)
            % For each experimental source, compute ThetaSqr, which is
            % defined here as the sum of the squared model terms for that source
            % in a decomposition of the true means.  This measure depends only
            % on the effect size for that source--not on the presence of additional
            % factors in the design.
            % Note that many books define ThetaSqr differently, dividing the value
            % obtained here by the number of df's or conditions in the source.
            obj.TrueMeans = passTrueMeans;
            dummytbl = Decompose(obj.ExptlLevels, obj.TrueMeans, obj.ExptlNames);
%             dummytbl = anovantbl2table(dummytbl1, obj.BetweenNames, obj.WithinNames, obj.SubName);
            % Note that the SumSq terms in this table do increase when there are additional
            % factors in the design, since the SumSq is totalled across rows of the decomp
            % matrix (and there are more rows when there are more factors).
            % To obtain the desired ThetaSqr, each SumSq must be divided by the number
            % of levels of each of the factors _not_ involved in this source.
            % obj.tbl = obj.AddAnovanCols(obj.tbl,dummytbl);  % Just want to add experimental SS's here, not dfs & not error terms
            obj.tbl.SS = zeros(obj.NSources,1);
            for iSource=1:obj.NSources
                myRowInAnovan = obj.FindAnovanRow(dummytbl,obj.tbl.Properties.RowNames{iSource});
                if numel(myRowInAnovan)>0
                    obj.tbl.SS(iSource) = dummytbl{myRowInAnovan,obj.anovanSScol};
                end
            end
            obj.tbl.ThetaSqr = nan(obj.NSources,1);
            for iSource = 1:obj.NSources
                if numel(obj.tbl.ET{iSource})>0
                    sSource = obj.tbl.Properties.RowNames{iSource};
                    UninvolvedFacs = obj.MissingFacs(sSource,obj.ExptlNames);
                    NUninvolvedConditions = prod(obj.ExptlLevels(UninvolvedFacs));
                    obj.tbl.ThetaSqr(iSource) = obj.tbl.SS(iSource) / NUninvolvedConditions;
                end
            end
        end
        
        function setNoncentralities(obj)
            % ThetaSqr & Sigma terms must already exist.
            obj.tbl.Noncentrality = NaN(obj.NSources,1);
            obj.TrialVariance = obj.tbl.Sigma('Error')^2/obj.NReplications;
            newjefftblhere = obj.tbl
            for jSource = 1:numel(obj.FixedSources)
                iSource = obj.FixedSources(jSource);
                % In general, noncen = N * thetasqr / sigma^2 where N is the number of Ss at
                % each combination of factor levels defining the means used to compute the source
                % and sigma^2 is the error variance associated with the source.
                sSource = obj.tbl.Properties.RowNames{iSource};
                UninvolvedBetFacs = obj.MissingFacs(sSource,obj.BetweenNames);
                NUninvolvedBet = prod(obj.BetweenLevels(UninvolvedBetFacs));
                UninvolvedWitFacs = obj.MissingFacs(sSource,obj.WithinNames);
                NUninvolvedWit = prod(obj.WithinLevels(UninvolvedWitFacs));
                thisN = obj.NSubsPerGroup * NUninvolvedBet;
                ErrVar = obj.tbl.Sigma(obj.tbl.ETnum(iSource))^2 + obj.TrialVariance / NUninvolvedWit;
                obj.tbl.Noncentrality(iSource) = thisN * obj.tbl.ThetaSqr(iSource) / ErrVar ;
            end
        end
        
        function setOmegaSqrs(obj)
            % omega^2 = sigma^2(AB)/(sigma^2(AB)+sigma^2(ABS)+sigma^2(error)/NReplications)
            % tbl.ThetaSqr & tbl.Sigma must already exist
            % NEWJEFF: NOT SURE HOW OmegaSqr is defined when TrialVariance>0.  See DoddSchultz1973, OlejnikAlgina2003
            obj.tbl.OmegaSqr = NaN(obj.NSources,1);
            obj.tbl.OmegaSqr(obj.FixedSources) = obj.tbl.ThetaSqr(obj.FixedSources) ./ ...
                ( obj.tbl.ThetaSqr(obj.FixedSources) ...
                + obj.tbl.Sigma(obj.tbl.ET(obj.FixedSources)).^2 ...
                + obj.TrialVariance );
        end
        
        function setCohenfSqrs(obj)
            % f^2=omega^2/(1-omega^2), where f^2 ia Cohen's definition of effect size.
            % tbl.OmegaSqr must already exist
            obj.tbl.CohenfSqr = NaN(obj.NSources,1);
            obj.tbl.CohenfSqr(obj.FixedSources) = obj.tbl.OmegaSqr(obj.FixedSources) ./ (1 - obj.tbl.OmegaSqr(obj.FixedSources));
        end
        
        function setPowers(obj,TrueMeans,TrueSigmas,alpha)
            obj.setFcrits(alpha);  % NEWJEFF: Move these calls to main routine where setPowers is called.
            obj.setSigmas(TrueSigmas);
            obj.setThetaSqrs(TrueMeans);
            obj.setNoncentralities;
            obj.tbl.Power = NaN(obj.NSources,1);
            for jSource = 1:numel(obj.FixedSources)
                iSource = obj.FixedSources(jSource);
                obj.tbl.Power(iSource) = 1 - ncfcdf(obj.tbl.Fcrit(iSource),obj.tbl.df(iSource),obj.tbl.df(obj.tbl.ET(iSource)),obj.tbl.Noncentrality(iSource));
            end
            obj.setOmegaSqrs;
            obj.setCohenfSqrs;
            % Set power for tests of subjects effects from here
            if obj.NReplications > 1
                dfError = obj.tbl.df('Error');
                for jSource = 1:numel(obj.RandomSources)-1  % Skip Error source at the end
                    iSource = obj.RandomSources(jSource);
                    sSource = obj.tbl.Properties.RowNames{iSource};
                    UninvolvedWitFacs = obj.MissingFacs(sSource,obj.WithinNames);
                    NUninvolvedWit = prod(obj.WithinLevels(UninvolvedWitFacs));
                    Kappa = 1 + obj.tbl.Sigma(iSource)^2 * obj.NReplications * NUninvolvedWit / obj.tbl.Sigma('Error')^2;
                    thisFcrit = finv(1-alpha,obj.tbl.df(iSource),dfError);
                    obj.tbl.Power(iSource) = 1 - fcdf(thisFcrit/Kappa,obj.tbl.df(iSource),dfError);
                end
            end
        end
        
        function InitSims(obj)
            obj.NSims = 0;
            obj.tbl.obsSigp = zeros(obj.NSources,1);
            obj.tbl.obsTtlMS = zeros(obj.NSources,1);
            obj.NSims = 0;
            tempRepname = 'tempRepnameHGHK';
            if obj.NBetween>0
                obj.SimTrials = TrialFrame([obj.ExptlNames {obj.SubName} {tempRepname}],[obj.ExptlLevels obj.NSubsPerGroup obj.NReplications], ...
                    'Between',{obj.BetweenNames,obj.SubName},'DropVar',tempRepname);
            else
                obj.SimTrials = TrialFrame([obj.ExptlNames {obj.SubName} {tempRepname}],[obj.ExptlLevels obj.NSubsPerGroup obj.NReplications],'DropVar',tempRepname);
            end
            obj.SimTrials.True = CondAssign(obj.SimTrials,obj.ExptlNames,obj.TrueMeans);
            % obj.SimTrials.pSig = nan(height(obj.SimTrials),1);
            % Make the error term RVs & a list of the constraints for each error term:
            % Also determine whether each source contains the subject term:
            obj.RVerr = cell(obj.NSources,1);
            obj.ErrSrcName = cell(obj.NSources,1);
            obj.ErrConstraints = cell(obj.NSources,1);
            obj.SrcWithSub = false(obj.NSources,1);
            for jSource = 1:numel(obj.RandomSources)
                iSource = obj.RandomSources(jSource);
                if obj.tbl.Sigma(iSource)>0
                    obj.RVerr{iSource} = Normal(0,obj.tbl.Sigma(iSource));
                else
                    obj.RVerr{iSource} = ConstantC(0);
                end
                obj.ErrConstraints{iSource} = obj.FindWithinComponents(iSource);
                obj.ErrSrcName{iSource} = UniqueVarname(obj.SimTrials,obj.tbl.Properties.RowNames{iSource});
                obj.SrcWithSub(iSource) = numel(strfind(obj.tbl.Properties.RowNames{iSource},obj.SubName))>0;
            end % for jSource
            obj.simtbl = obj.tbl;
        end
        
        function theseSources = FindWithinComponents(obj,thisSource)
            % Return a cell array with the names of the within-subject components in thisSourceName.
            theseSources = {};
            thisSourceName = obj.tbl.Properties.RowNames{thisSource};  % Get the source name, e.g. AS(B)
            % Delete everything from the subject spec onward
            iPos = strfind(thisSourceName,obj.SubName);
            if (numel(iPos)==0) || (iPos(1)<numel(obj.FullSubName))
                WithinComponents = thisSourceName;
            else
                WithinComponents = thisSourceName(1:iPos-1);  % Whatever precedes the S, e.g. A
            end
            for iFac=1:obj.NWithin
                iPos = strfind(WithinComponents,obj.WithinNames{iFac});
                if numel(iPos)>0
                    theseSources = [theseSources cellstr(obj.WithinNames{iFac})];%#okAGROW
                end
            end
        end
        
        function TtlErr = SimTtlErr(obj)
            % Generate & total the random error terms for one simulated sample.
            NTrials = numel(obj.SimTrials.True);
            TtlErr = zeros(NTrials,1);
            for jSource = 1:numel(obj.RandomSources)-1  % skip the total
                iSource = obj.RandomSources(jSource);
                thisErrName = matlab.lang.makeValidName(obj.ErrSrcName{iSource},'ReplacementStyle','delete');
                if obj.SrcWithSub(iSource)
                    obj.SimTrials.(thisErrName) = CondRand(obj.SimTrials,[obj.ErrConstraints{iSource}{:} cellstr(obj.SubName)],obj.RVerr{iSource});
                else
                    obj.SimTrials.(thisErrName) = randn(NTrials,1)*obj.tbl.Sigma(iSource);
                end
                if obj.SrcWithSub(iSource) && (numel(obj.ErrConstraints{iSource})>0)
                    % Center the error terms for each subject across the relevant within-Ss factors
                    for iSub=1:obj.NSubsTotal
                        obj.SimTrials.(thisErrName) = CondCenter(obj.SimTrials,thisErrName,obj.ErrConstraints{iSource}, ...
                            'Include',obj.SimTrials.(obj.SubName)==obj.UniqueSubs(iSub));
                    end
                end
                TtlErr = TtlErr + obj.SimTrials.(thisErrName);
            end % for jSource
        end
        
        function SimulateOne(obj)
            obj.NSims = obj.NSims + 1;
            obj.SimTrials.Y = obj.SimTrials.True + obj.SimTtlErr;
            [~, obj.simtbl1] = CallAnovan(obj.SimTrials,'Y',obj.BetweenNames,obj.WithinNames,obj.SubName,'WantMu','NoDisplay');  % optionally pass a summary function here ???
            % obj.simtbl = obj.AddAnovanCols(obj.simtbl,obj.simtbl1);
            % anovantbl2table(obj.simtbl1, obj.BetweenNames, obj.WithinNames, obj.SubName,'FsForFixed','FsForRandom');
            % NEWJEFF: Store the row numbers so I don't have to retrieve them each simulation
            for iSource=1:obj.NSources
                myRowInAnovan = obj.FindAnovanRow(obj.simtbl1,obj.tbl.Properties.RowNames{iSource});
                if numel(myRowInAnovan)>0
                    obj.simtbl.SS(iSource) = obj.simtbl1{myRowInAnovan,obj.anovanSScol};
                    obj.simtbl.df(iSource) = obj.simtbl1{myRowInAnovan,obj.anovandfcol};
                end
            end
            obj.simtbl.MeanSq = obj.simtbl.SS ./ obj.simtbl.df;
            obj.simtbl.F = zeros(obj.NSources,1);  % NEWJEFF: InitSims next 2
            obj.simtbl.ProbF = zeros(obj.NSources,1);
            obj.simtbl.F(obj.SourcesWithFs) = obj.simtbl.MeanSq(obj.SourcesWithFs) ./ obj.simtbl.MeanSq(obj.simtbl.ETnum(obj.SourcesWithFs));
            obj.simtbl.ProbF(obj.SourcesWithFs) = 1 - fcdf(obj.simtbl.F(obj.SourcesWithFs),obj.simtbl.df(obj.SourcesWithFs),obj.simtbl.df(obj.simtbl.ETnum(obj.SourcesWithFs)));
            for iSource=1:height(obj.simtbl)
                % if obj.simtbl.df(iSource)>0
                    obj.tbl.obsTtlMS(iSource) = obj.tbl.obsTtlMS(iSource) + obj.simtbl.MeanSq(iSource);
                % end
                try
                    if obj.simtbl.ProbF(iSource)<obj.alpha
                        obj.tbl.obsSigp(iSource) = obj.tbl.obsSigp(iSource) + 1;
                    end
                catch
                    % Ignore nan, inf, empty, etc
                end  % try
            end % for iSource
        end
        
        function Report(obj)
            % NewJeff: add an option to print to a file
            % NewJeff: add an option to report only fixed lines
            Conf = .99;  % Confidence intervals for p use this confidence level
            ColHdr = {'Source', 'df', 'Fcrit', 'ThetaSqr', 'Noncen', 'OmegaSqr', 'CohenfSqr', 'Power' , 'ObsPrSig', '99%LoBnd', '99%UpBnd', 'obsEMS'};
            ColWid = {    '12',  '5',     '7',       '14',     '14',       '10',        '11',     '8' ,       '10',     '10',     '10',     '15'};
            ReportSims = obj.NSims > 0;
            if ReportSims
                sSimTxt = [' with ' num2str(obj.NSims) ' simulations'];
                NColsToUse = numel(ColHdr);
            else
                sSimTxt = '';
                NColsToUse = 8;
            end
            fprintf('Power report%s:\n',sSimTxt);
            LevelsList('Between',obj.BetweenNames,obj.BetweenLevels);
            LevelsList('Within',obj.WithinNames,obj.WithinLevels);
            for iCol = 1:NColsToUse
                fprintf(['%' ColWid{iCol} 's'],ColHdr{iCol});
            end
            fprintf('\n');
            % padSrc = obj.tbl.Properties.RowNames; % pad(obj.tbl.Properties.RowNames);  NEWJEFF: Coming in R2016b
            for iSource = 1:height(obj.tbl)
                iCol = 0;
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} 's'  ],obj.tbl.Properties.RowNames{iSource});
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} 'd'  ],obj.tbl.df(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.Fcrit(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.ThetaSqr(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.Noncentrality(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.OmegaSqr(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.CohenfSqr(iSource));
                iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.Power(iSource));
                if ReportSims
                    pPred = obj.tbl.Power(iSource);
                    pObs = obj.tbl.obsSigp(iSource)/obj.NSims;
                    LBnd = binoinv((1-Conf)/2,obj.NSims,pPred)/obj.NSims;
                    UBnd = binoinv(Conf+(1-Conf)/2,obj.NSims,pPred)/obj.NSims;
                    if (pObs<LBnd) || (pObs>UBnd)
                        Flag = '*';
                    else
                        Flag = ' ';
                    end
                    iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f%c'],pObs,Flag);
                    iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],LBnd);
                    iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],UBnd);
                    iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.obsTtlMS(iSource)/obj.NSims);
                end
                fprintf('\n');
            end
            
            function LevelsList(sName,Facs,Levels)
                NFacs = numel(Levels);
                if NFacs==0
                    return
                end
                fprintf('%s levels/factors:',sName);
                for iFac=1:NFacs
                    fprintf(' %d%s',Levels(iFac),Facs{iFac});
                    if iFac<NFacs
                        fprintf(' x');
                    end
                end
                fprintf('\n');
            end
            
        end
        
    end  % methods
    
end  % class AnovaPower
