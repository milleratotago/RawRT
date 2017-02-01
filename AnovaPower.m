classdef AnovaPower < handle
    % Class to perform power-related computations with Anova tables
    % Can also be used to generate & accumulate simulation results.
    
    properties
        
        alpha
        tbl              % The ANOVA table, augmented with extra computations, simulation results, etc, as needed.
        
        BetweenFacs      % Cell array of names of between-Ss factors
        WithinFacs       % Cell array of names of within-Ss factors
        ExptlFacs        % Combined cell array of names of both between & within-Ss factors
        
        NBetweenFacs
        NWithinFacs
        NExptlFacs
        
        NGroups
        NSubsPerGrp      % Number of subjects per group
        NSubsTotal
        UniqueSubs       % A list of the subject numbers.
        
        SubjectSpec      % String names of the subjects factor
        
        BetweenFacLevels
        WithinFacLevels
        AllFacLevels     % List of the number of levels of each experimental factor
        
        TrueMeans        % A vector of the true means at each combination of fixed factor levels
        
        FixedSources     % List of row numbers of the fixed sources in tbl.
        RandomSources    % List of row numbers of the random sources in tbl.
        NSources         % Total number of source lines in the ANOVA table (including Error).
        NWithinSources   % Number of fully within-Ss sources in the ANOVA table.
        SrcWithSub       % Array of boolean indicating whether each source includes subject factor
        
        NSims            % Number of simulations carried out.
        SimTrials        % A trials table to hold simulated data.
        ErrConstraints   % A cell array, one per source.  Each entry is a cell array
                         % containing a list of error constraints for the source
                         % (empty for all non-error sources).
                         % The entry cell array has a list of the factors across
                         % which the error term must sum to 0; e.g. 'A' and 'B' for ABS.
        RVerr            % A cell array, one per source, of the random variables used for the different error terms.
        
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
        
    end % static methods
    
    methods
        
        function obj=AnovaPower(dummyTrials,passBetweenFacs,passWithinFacs,passSubjectSpec)
            % Initialize based on the information in Trials.
            
            obj.BetweenFacs = passBetweenFacs;
            obj.WithinFacs  = passWithinFacs;
            obj.SubjectSpec = passSubjectSpec;
            
            obj.ExptlFacs   = [obj.BetweenFacs obj.WithinFacs];
            
            obj.NBetweenFacs = numel(obj.BetweenFacs);
            obj.NWithinFacs  = numel(obj.WithinFacs);
            obj.NExptlFacs   = numel(obj.ExptlFacs);
            
            % Determine the numbers of levels of each factor & Ss
            obj.AllFacLevels = zeros(1,obj.NBetweenFacs+obj.NWithinFacs);
            for iFac = 1:obj.NExptlFacs
                sFac = obj.ExptlFacs{iFac};
                obj.AllFacLevels(iFac) = numel(unique(dummyTrials.(sFac)));
            end
            obj.BetweenFacLevels = obj.AllFacLevels(1:obj.NBetweenFacs);
            obj.WithinFacLevels = obj.AllFacLevels(obj.NBetweenFacs+1:end);
            obj.NGroups = prod(obj.AllFacLevels(1:obj.NBetweenFacs));
            obj.UniqueSubs = unique(dummyTrials.(obj.SubjectSpec));
            obj.NSubsTotal = numel(unique(dummyTrials.(obj.SubjectSpec)));
            obj.NSubsPerGrp = obj.NSubsTotal / obj.NGroups;
            
            % Create a fake DV & analyze it with anovan to determine the ANOVA table structure.
            sDV = UniqueVarname(dummyTrials,'DV');
            dummyTrials.(sDV) = zeros(height(dummyTrials),1);
            [~, tbl1, ~] = CallAnovan(dummyTrials,sDV,obj.BetweenFacs,obj.WithinFacs,obj.SubjectSpec,'Mean','NoDisplay');
            obj.tbl = anovantbl2table(tbl1);
            obj.NSources = height(obj.tbl);
            obj.NWithinSources = 2^obj.NWithinFacs - 1;
            obj.FixedSources = find(strcmp(obj.tbl.Type,'fixed')>0);
            obj.RandomSources = find(strcmp(obj.tbl.Type,'random'));
            
            setETs(obj);
            obj.NSims = 0;
        end
        
        function iRow = RowNameToNum(obj,sName)
            iRow = find(strcmp(sName,obj.tbl.RowNames));
        end
        
        function setETs(obj)
            obj.tbl.ET = NaN(height(obj.tbl),1);
            for iSource = 1:obj.NSources
                sDenomName = obj.tbl.DenomDefn{iSource};
                if numel(sDenomName)>0
                    sDenomName = matlab.lang.makeValidName(sDenomName,'ReplacementStyle','delete');
                    sDenomName = sDenomName(3:end);  % Omit initial MS
                    thisRow = find(strcmp(sDenomName,obj.tbl.Properties.RowNames));
                    if numel(thisRow)==1
                        obj.tbl.ET(iSource) = thisRow;
                    end
                end
            end
        end
        
        function setFcrits(obj,passalpha)
            obj.alpha = passalpha;
            obj.tbl.Fcrit = nan(obj.NSources,1);
            for iSource = 1:obj.NSources
                if ~isnan(obj.tbl.ET(iSource))
                    obj.tbl.Fcrit(iSource) = finv(1-obj.alpha,obj.tbl.df(iSource),obj.tbl.df(obj.tbl.ET(iSource)));
                end
            end
        end
        
        function setSigmas(obj,SigmaList)
            % This routine just stores the designated error terms (specified in SigmaList)
            % in the corresponding rows of tbl.Sigma.
            % Note that the order in SigmaList MUST MATCH the row order in tbl.
            obj.tbl.Sigma = nan(obj.NSources,1);
            nUsed = 0;
            for iSource = 1:obj.NSources
                thisSource = obj.tbl.Properties.RowNames(iSource);
                loc = strfind(thisSource,obj.SubjectSpec);
                loc = loc{1};
                if (numel(loc)>0) || (strcmp(thisSource,'Error'))
                    nUsed = nUsed + 1;
                    obj.tbl.Sigma(iSource) = SigmaList(nUsed);
                end
            end
            if nUsed < numel(SigmaList)
                warning(['Ignored last ' num2str(numel(SigmaList)-nUsed) ' values in SigmaList.']);
            end
%             for iSrc=1:numel(obj.RandomSources)
%                 newjff1 = obj.tbl.Properties.RowNames{obj.RandomSources(iSrc)}
%                 newjff2 = obj.tbl.Sigma(obj.RandomSources(iSrc))
%             end
        end
        
        function setThetaSqrs(obj,passTrueMeans)
            % For each experimental source, compute ThetaSqr, which is
            % defined here as the sum of the squared model terms for that source
            % in a decomposition of the true means.  This measure depends only
            % on the effect size for that source--not on the presence of additional
            % factors in the design.
            obj.TrueMeans = passTrueMeans;
            dummytbl1 = Decompose(obj.AllFacLevels, obj.TrueMeans, obj.ExptlFacs);
            dummytbl = anovantbl2table(dummytbl1);
            % Note that the SumSq terms in this table do increase when there are additional
            % factors in the design, since the SumSq is totalled across rows of the decomp
            % matrix (and there are more rows when there are more factors).
            % To obtain the desired ThetaSqr, each SumSq must be divided by the number
            % of levels of each of the factors _not_ involved in this source.
            obj.tbl.ThetaSqr = nan(obj.NSources,1);
            for iSource = 1:height(dummytbl);
                sSource = dummytbl.Properties.RowNames{iSource};
                UninvolvedFacs = obj.MissingFacs(sSource,obj.ExptlFacs);
                NUninvolvedConditions = prod(obj.AllFacLevels(UninvolvedFacs));
                obj.tbl.ThetaSqr(sSource) = dummytbl.SumSq(iSource) / NUninvolvedConditions;
            end
        end
        
        function setNoncentralities(obj)
            % ThetaSqr & Sigma terms must already exist.
            % NEWJEFF: INCLUDE TRIALS ERROR TERM
            obj.tbl.Noncentrality = NaN(obj.NSources,1);
            for jSource = 1:numel(obj.FixedSources)
                iSource = obj.FixedSources(jSource);
                % In general, noncen = N * thetasqr / sigma^2 where N is the number of Ss at
                % each combination of factor levels defining the means used to compute the source.
                sSource = obj.tbl.Properties.RowNames{iSource};
                UninvolvedFacs = obj.MissingFacs(sSource,obj.BetweenFacs);
                NUninvolved = prod(obj.BetweenFacLevels(UninvolvedFacs));
                thisN = obj.NSubsPerGrp * NUninvolved;
                obj.tbl.Noncentrality(iSource) = thisN * obj.tbl.ThetaSqr(iSource) / obj.tbl.Sigma(obj.tbl.ET(iSource))^2 ;
            end
        end
        
        function setOmegaSqrs(obj)
            % omega^2 = sigma^2(AB)/(sigma^2(AB)+sigma^2(ABS)+sigma^2(error))
            % tbl.ThetaSqr & tbl.Sigma must already exist
            % NEWJEFF: INCLUDE TRIALS ERROR TERM
            obj.tbl.OmegaSqr = NaN(obj.NSources,1);
            obj.tbl.OmegaSqr(obj.FixedSources) = obj.tbl.ThetaSqr(obj.FixedSources) ./ ...
                ( obj.tbl.ThetaSqr(obj.FixedSources) ...
                + obj.tbl.Sigma(obj.tbl.ET(obj.FixedSources)).^2 ...
                + obj.tbl.Sigma('Error') );
        end
        
        function setCohenfSqrs(obj)
            % f^2=omega^2/(1-omega^2), where f^2 ia Cohen's definition of effect size.
            % tbl.OmegaSqr must already exist
            obj.tbl.CohenfSqr = NaN(obj.NSources,1);
            obj.tbl.CohenfSqr(obj.FixedSources) = obj.tbl.OmegaSqr(obj.FixedSources) ./ (1 - obj.tbl.OmegaSqr(obj.FixedSources));
        end
        
        function setPowers(obj,TrueMeans,TrueSigmas,alpha)
            obj.setFcrits(alpha);
            obj.setSigmas(TrueSigmas);
            obj.setThetaSqrs(TrueMeans);
            %             obj.setFracSubs;
            obj.setNoncentralities;
            obj.tbl.Power = NaN(obj.NSources,1);
            for jSource = 1:numel(obj.FixedSources)
                iSource = obj.FixedSources(jSource);
                obj.tbl.Power(iSource) = 1 - ncfcdf(obj.tbl.Fcrit(iSource),obj.tbl.df(iSource),obj.tbl.df(obj.tbl.ET(iSource)),obj.tbl.Noncentrality(iSource));
            end
            obj.setOmegaSqrs;
            obj.setCohenfSqrs;
        end
        
        function InitSims(obj)
            obj.tbl.obsSigp = zeros(obj.NSources,1);
            obj.tbl.obsTtlMS = zeros(obj.NSources,1);
            obj.NSims = 0;
            if obj.NBetweenFacs>0
                obj.SimTrials = TrialFrame([obj.ExptlFacs cellstr(obj.SubjectSpec)],[obj.AllFacLevels obj.NSubsPerGrp], ...
                    'Between',{obj.BetweenFacs,obj.SubjectSpec});
            else
                obj.SimTrials = TrialFrame([obj.ExptlFacs {obj.SubjectSpec}],[obj.AllFacLevels obj.NSubsPerGrp]);
            end
            obj.SimTrials.True = CondAssign(obj.SimTrials,obj.ExptlFacs,obj.TrueMeans);
            % obj.SimTrials.pSig = nan(height(obj.SimTrials),1);
            % Make the error term RVs & a list of the constraints for each error term:
            % Also determine whether each source contains the subject term:
            obj.RVerr = cell(obj.NSources,1);
            obj.ErrConstraints = cell(obj.NSources,1);
            obj.SrcWithSub = false(obj.NSources,1);
            for jSource = 1:numel(obj.RandomSources)
                iSource = obj.RandomSources(jSource);
                if obj.tbl.Sigma(iSource)>0
                    obj.RVerr{iSource} = Normal(0,obj.tbl.Sigma(iSource));
                    obj.ErrConstraints{iSource} = obj.FindWithinErrorComponents(iSource);
                end
                obj.SrcWithSub(iSource) = numel(strfind(obj.tbl.Properties.RowNames{iSource},obj.SubjectSpec))>0;
%                 if obj.SrcWithSub(iSource)
%                     newjff = obj.tbl.Properties.RowNames(iSource)
%                     newjff2 = obj.SubjectSpec
%                 end
            end % for jSource
        end
        
        function theseSources = FindWithinErrorComponents(obj,thisSource)
            % Return a cell array with the names of the within-sources that precede S in thisSourceName.
            theseSources = {};
            thisSourceName = obj.tbl.Properties.RowNames{thisSource};  % Get the source name, e.g. AS(B)
            % Delete everything from the subject spec onward
            iPos = strfind(thisSourceName,obj.SubjectSpec);
            if (numel(iPos)==0) || (iPos(1)<2)
                return
            end
            WithinComponents = thisSourceName(1:iPos-1);  % Whatever precedes the S, e.g. A
            for iFac=1:obj.NWithinFacs
                iPos = strfind(WithinComponents,obj.WithinFacs{iFac});
                if numel(iPos)>0
                    theseSources = [theseSources cellstr(obj.WithinFacs{iFac})];%#okAGROW
                end
            end
        end
        
        function TtlErr = SimTtlErr(obj)
            % Generate the sum of the random error terms for one simulated sample.
            NTrials = numel(obj.SimTrials.True);
            TtlErr = zeros(NTrials,1);
            for jSource = 1:numel(obj.RandomSources)
                iSource = obj.RandomSources(jSource);
                if obj.SrcWithSub(iSource)
%                     newjff = iSource
%                     class(obj.RVerr{iSource})
                    obj.SimTrials.ThisErr = CondRand(obj.SimTrials,[obj.ErrConstraints{iSource}{:} cellstr(obj.SubjectSpec)],obj.RVerr{iSource});
                end
                if numel(obj.ErrConstraints{iSource})>0
                    % Center the error terms for each subject across the relevant within-Ss factors
                    for iSub=1:obj.NSubsTotal
                        obj.SimTrials.ThisErr = CondCenter(obj.SimTrials,'ThisErr',obj.ErrConstraints{iSource}, ...
                            'Include',obj.SimTrials.(obj.SubjectSpec)==obj.UniqueSubs(iSub));
                    end
                elseif ~obj.SrcWithSub(iSource)
                    obj.SimTrials.ThisErr = randn(NTrials,1)*obj.tbl.Sigma(iSource);
                end
                obj.SimTrials.(['ErrNewJeff' num2str(iSource)]) = obj.SimTrials.ThisErr;
                TtlErr = TtlErr + obj.SimTrials.ThisErr;
            end % for jSource
        end
        
        function SimulateOne(obj)
            obj.NSims = obj.NSims + 1;
            obj.SimTrials.Y = obj.SimTrials.True + obj.SimTtlErr;
            [~, simtbl1] = CallAnovan(obj.SimTrials,'Y',obj.BetweenFacs,obj.WithinFacs,obj.SubjectSpec,'Mean','NoDisplay');
            simtbl = anovantbl2table(simtbl1);
            % simtbl.pSig = nan(height(simtbl),1);
            for iSource=1:(height(simtbl)-1)
                if simtbl.df(iSource)>0
                    obj.tbl.obsTtlMS(iSource) = obj.tbl.obsTtlMS(iSource) + simtbl.MeanSq{iSource};
                end
                try
                    if simtbl.ProbF{iSource}<obj.alpha
                        obj.tbl.obsSigp(iSource) = obj.tbl.obsSigp(iSource) + 1;
                    end
                catch
                    % Ignore nan, inf, empty, etc
                end  % try
            end % for iSource
        end
        
        function Report(obj)
            % NewJeff: option to report only fixed lines
            Conf = .99;  % Confidence intervals for p use this confidence level
            ColHdr = {'Source', 'df', 'Fcrit', 'ThetaSqr', 'Noncen', 'OmegaSqr', 'CohenfSqr', 'Power' , 'EMS', 'ObsPrSig', 'LoBnd', 'UpBnd'};
            ColWid = {    '12',  '5',     '7',       '14',     '14',       '10',        '11',     '8' ,  '12',       '10',     '8',     '8'};
            ReportSims = obj.NSims > 0;
            if ReportSims
                sSimTxt = [' with ' num2str(obj.NSims) ' simulations'];
                NColsToUse = numel(ColHdr);
            else
                sSimTxt = '';
                NColsToUse = 8;
            end
            fprintf('Power report%s:\n',sSimTxt);
            %             fprintf('               Source   df   Fcrit     E[MS]   Theta^2   Noncen.   Omega^2   Cohen-f^2    Power   Obs Pr(Sig)   LowerBnd   UpperBnd\n');
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
                    iCol = iCol+1;  fprintf(['%' ColWid{iCol} '.3f'],obj.tbl.obsTtlMS(iSource)/obj.NSims);
                end
                if ReportSims && (~isnan(obj.tbl.Power(iSource)))
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
                end
                fprintf('\n');
            end
        end
        
    end  % methods
    
end  % class AnovaPower
