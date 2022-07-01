classdef VSJmnRTs
    % This class implements various methods for RT analysis discussed by Van Selst & Jolicoeur (1994).
    % All methods produce estimates of the mean RT in a given condition.
    %
    % PROGRAMMING NOTE: For some of the functions that call these functions, it would have been more
    % convenient if the functions in this class produced a single structure output so that the other
    % functions could access the fields by name.
    % Structure output would not be compatible with CondFunsOfDVs, however.
    % In particular, CondExcludeVSJ accesses outputs by number.
    %
    % As I read their article, they consider (at least) these different methods which are implemented here:
    %
    %   NonRecurSD(k):   Compute SD from full sample.
    %                    Remove scores farther than k SDs from the mean.
    %                    Return the mean of the remaining scores.
    %
    %   SimpRecurSD(k):  Compute SD from full sample.
    %                    Remove the highest &/or lowest scores if they are farther than k SDs from the mean.
    %                    Recompute a new SD and maybe exclude more, iterate until no further scores are removed.
    %                    Return the mean of the remaining scores.
    %
    %   ModRecurSD(k):   Temporarily exclude the largest score and compute SD from the remaining sample.
    %                    Then put it back and remove the highest &/or lowest scores if they are farther
    %                      than k SDs from the mean.
    %                    Then temporarily exclude the next highest, recompute a new SD, and maybe exclude more.
    %                    Iterate until no further scores are removed.
    %                    Return the mean of the remaining scores.
    %
    %   HybridSD(k1,k2): Return the average of the means from the SimpRecurSD(k1) & ModRecurSD(k2) methods.
    %                    Note that this identifies individual RTs as outliers or not separately for the two methods.
    %                    THIS IS THE HYBRID PROCEDURE MENTIONED IN THE PAPER.
    %
    %   NonRecur:        Remove scores farther than K SDs from the mean, where K depends on the N of trials
    %                      as shown in their Table 4, NR.
    %                    Return the mean of the remaining scores.
    %                    K is empirically chosen to match 2.5 SD cutoff.
    %
    %   ModRecur:        Remove scores farther than K SDs from the mean, where K depends on the N of trials
    %                      as shown in their Table 4, MR.
    %                    Iterate with new N and maybe remove some more.
    %                    Return the mean of the remaining scores.
    %                    K is empirically chosen to match 3.5 SD cutoff.
    %
    %   Hybrid:          Average of NonRecur & ModRecur
    % 
    % Notes:
    %
    %   Recursion: Although VSJ describe their procedure as recursive and it may be implemented that way,
    %              there is nothing inherently recursive about it.  It is simply iterative.
    %
    %   Ties: VSJ did not describe what to do in the case of tied largest or tied smallest scores,
    %         which might occur in real RT data (e.g., if RTs are measured/rounded to the nearest ms).
    %         The routines in this class treat all equal scores together. For example, if 2+ scores are
    %         tied at the largest value, they are collectively considered to be the largest
    %         (& temporarily or permanently removed) at each step by the recursive methods.
    %         An easy way to over-ride this behavior is to add a small random number to each RT,
    %         e.g., a random increment uniformly distributed between -0.01 ms and +0.01 ms (assuming RTs are
    %         measured in ms). This will eliminate exact ties and have negligible consequences on computed means.
    
    %  To use these routines, you only need to call one or more of these following functions:
    %   function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = NonRecurSD(inRTs,SDcutoff)
    %   function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = SimpRecurSD(inRTs,SDcutoff)
    %   function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = ModRecurSD(inRTs,SDcutoff)
    %   function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = NonRecur(inRTs)
    %   function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = ModRecur(inRTs)
    %   function [Mean, PropTooLo, PropTooHi, PropTooLo1, PropTooHi1, Excluded1, PropTooLo2, PropTooHi2, Excluded2, TooLo1, TooHi1, TooLo2, TooHi2] =
    %          HybridSD(inRTs,SDcutoff1,SDcutoff2)
    %   function [Mean, PropTooLo, PropTooHi, PropTooLo1, PropTooHi1, Excluded1, PropTooLo2, PropTooHi2, Excluded2, TooLo1, TooHi1, TooLo2, TooHi2] = Hybrid(inRTs)
    %
    % Inputs to these functions:
    %   inRTs: a vector of the RTs to be considered.
    %   SDcutoff: a k value as described above.
    %   SDcutoff1,SDcutoff2: k values for NonRecurSD and ModRecurSD, respectively.
    %
    % Outputs from these functions:
    %   Mean: The mean of the RTs remaining after exclusion.
    %   PropTooLo/PropTooHi: The proportion of RTs excluded for being too fast or too slow, respectively.
    %   Excluded: A vector of boolean which is the same size as inRTs.  Excluded(i) is true iff inRT(i) was excluded.
    %   For the hybrid functions:
    %     PropTooLo/PropTooHi are averages of the proportions excluded by the NonRecur & ModRecur functions.
    %     PropTooLo1/PropTooHi1/Excluded1/TooLo1/TooHi1 refer to exclusion by the NonRecur function.
    %     PropTooLo2/PropTooHi2/Excluded2/TooLo2/TooHi2 refer to exclusion by the ModRecur function.

    %  **************** Users should not have to look at anything beyond this point!
    %  **************** (the rest is for programmers)

    properties(Constant)

        % This array gives the linearly interpolated SD cutoffs for use with the non-recursive
        % method of Van Selst & Jolicoeur (1994).
        % The cutoff values (NRCutVals) were computed from the NR values in their Table 4 using linear interpolation.
        % SampleNs:
        NRCutVals = [                 1.4580, 1.6800, 1.8410, 1.9610, 2.0500, 2.1200, 2.1700,   ... 04-010
            2.2200, 2.2460, 2.2740, 2.3100, 2.3260, 2.3390, 2.3520, 2.3650, 2.3780, 2.3910,   ... 11-020
            2.3948, 2.3986, 2.4024, 2.4062, 2.4100, 2.4141, 2.4182, 2.4223, 2.4264, 2.4305,   ... 21-030
            2.4344, 2.4383, 2.4422, 2.4461, 2.4500, 2.4520, 2.4540, 2.4560, 2.4580, 2.4600,   ... 31-040
            2.4620, 2.4640, 2.4660, 2.4680, 2.4700, 2.4720, 2.4740, 2.4760, 2.4780, 2.4800,   ... 41-050
            2.4804, 2.4808, 2.4812, 2.4816, 2.4820, 2.4824, 2.4828, 2.4832, 2.4836, 2.4840,   ... 51-060
            2.4844, 2.4848, 2.4852, 2.4856, 2.4860, 2.4864, 2.4868, 2.4872, 2.4876, 2.4880,   ... 61-070
            2.4884, 2.4888, 2.4892, 2.4896, 2.4900, 2.4904, 2.4908, 2.4912, 2.4916, 2.4920,   ... 71-080
            2.4924, 2.4928, 2.4932, 2.4936, 2.4940, 2.4944, 2.4948, 2.4952, 2.4956, 2.4960,   ... 81-090
            2.4964, 2.4968, 2.4972, 2.4976, 2.4980, 2.4984, 2.4988, 2.4992, 2.4996, 2.5000];   %  91-100
        
        % This array gives the linearly interpolated SD cutoffs for use with the modified recursive
        % method of Van Selst & Jolicoeur (1994).
        % The cutoff values (MRCutVals) were computed from the MR values in their Table 4 using linear interpolation.
        % SampleNs:
        MRCutVals = [               8.0000, 6.2000, 5.3000, 4.8000, 4.4750, 4.2500, 4.1100,   ... 04-010
            4.0000, 3.9200, 3.8500, 3.8000, 3.7500, 3.7280, 3.7060, 3.6840, 3.6620, 3.6400,   ... 11-020
            3.6310, 3.6220, 3.6130, 3.6040, 3.5950, 3.5860, 3.5770, 3.5680, 3.5590, 3.5500,   ... 21-030
            3.5480, 3.5460, 3.5440, 3.5420, 3.5400, 3.5380, 3.5360, 3.5340, 3.5320, 3.5300,   ... 31-040
            3.5280, 3.5260, 3.5240, 3.5220, 3.5200, 3.5180, 3.5160, 3.5140, 3.5120, 3.5100,   ... 41-050
            3.5098, 3.5096, 3.5094, 3.5092, 3.5090, 3.5088, 3.5086, 3.5084, 3.5082, 3.5080,   ... 51-060
            3.5078, 3.5076, 3.5074, 3.5072, 3.5070, 3.5068, 3.5066, 3.5064, 3.5062, 3.5060,   ... 61-070
            3.5058, 3.5056, 3.5054, 3.5052, 3.5050, 3.5048, 3.5046, 3.5044, 3.5042, 3.5040,   ... 71-080
            3.5038, 3.5036, 3.5034, 3.5032, 3.5030, 3.5028, 3.5026, 3.5024, 3.5022, 3.5020,   ... 81-090
            3.5018, 3.5016, 3.5014, 3.5012, 3.5010, 3.5008, 3.5006, 3.5004, 3.5002, 3.5000];   %  91-100
        
        minSampleN = 3;  % The smallest acceptable sample size. Never exclude observations from a sample this small.
        maxSampleN = 100;
        SampleNOffset = 3;  % The number of sample sizes omitted from the CutVals tables (i.e., sample sizes 1,2,3).
        

        % **************** The following constants & structure are helpful when writing simulation
        % **************** programs to be used with any of the VSJ methods, chosen _at run time_.
        % **************** These will not ordinarily be used when writing data analysis programs,
        % **************** where the VSJ method will be chosen in advance.

        % Define constant string names & integer identifiers for the different methods.
        % The integers must match the order of the different methods in the following Props array.
        sNonRecurSD  = 'NonRecurSD';       cNonRecurSD  = 1;
        sSimpRecurSD = 'SimpRecurSD';      cSimpRecurSD = 2;
        sModRecurSD  = 'ModRecurSD';       cModRecurSD  = 3;
        sHybridSD    = 'HybridSD';         cHybridSD    = 4;
        sNonRecur    = 'NonRecur';         cNonRecur    = 5;
        sModRecur    = 'ModRecur';         cModRecur    = 6;
        sHybrid      = 'Hybrid';           cHybrid      = 7;
        
        % The following properties array holds information about each of the different analysis methods.
        % Each method has a string name, a function that is called to compute it, and a number of parameters
        % that it requires.
        % The order of the methods in this array must match the order of the constants cNonRecurSD, etc, above:
        Props = [...
struct('sName',VSJmnRTs.sNonRecurSD, 'Func',@VSJmnRTs.NonRecurSD, 'NParms',1,'NOuts',6,'TooLoCell',5,'TooHiCell',6), ... Parm is k multiplier of SD
struct('sName',VSJmnRTs.sSimpRecurSD,'Func',@VSJmnRTs.SimpRecurSD,'NParms',1,'NOuts',6,'TooLoCell',5,'TooHiCell',6), ... Parm is k multiplier of SD
struct('sName',VSJmnRTs.sModRecurSD, 'Func',@VSJmnRTs.ModRecurSD, 'NParms',1,'NOuts',6,'TooLoCell',5,'TooHiCell',6), ... Parm is k multiplier of SD
struct('sName',VSJmnRTs.sHybridSD,   'Func',@VSJmnRTs.HybridSD,   'NParms',2,'NOuts',15,'TooLoCell',14,'TooHiCell',15), ... Parms are k1 & k2 multipliers of SDs
                                                                                         ... for SimpRecurSD(k1) & ModRecurSD(k2).
struct('sName',VSJmnRTs.sNonRecur,   'Func',@VSJmnRTs.NonRecur,   'NParms',0,'NOuts',6,'TooLoCell',5,'TooHiCell',6), ...
struct('sName',VSJmnRTs.sModRecur,   'Func',@VSJmnRTs.ModRecur,   'NParms',0,'NOuts',6,'TooLoCell',5,'TooHiCell',6), ...
struct('sName',VSJmnRTs.sHybrid,     'Func',@VSJmnRTs.Hybrid,     'NParms',0,'NOuts',15,'TooLoCell',14,'TooHiCell',15), ...
];
        
    end  %  properties(Constant)
    
    methods(Static)
        
        % ******** Functions to be called by the user:


        function [Mean, PropTooLo, PropTooHi, Excluded, TooLo, TooHi] = NonRecurSD(inRTs,SDcutoff)
            [Mean, PropTooLo, PropTooHi, Excluded, TooLo, TooHi] = VSJmnRTs.NonRecurGen(inRTs,SDcutoff);
        end % function NonRecurSD
        

        function [Mean, PropTooLo, PropTooHi, Excluded, TooLo, TooHi] = SimpRecurSD(inRTs,SDcutoff)

            Excluded = false(size(inRTs));
            TooLo = false(size(inRTs));
            TooHi = false(size(inRTs));
            
            NeedToCheck = true;
            
            while NeedToCheck
                SampleN = numel(inRTs) - sum(Excluded);
                NeedToCheck = false;  % don't check again unless one of the following conditions is met
                if SampleN > VSJmnRTs.minSampleN  % No further exclusions once we reach minSampleN.
                    currentMax = max(inRTs(~Excluded));
                    currentMin = min(inRTs(~Excluded));
                    
                    % Do NOT temporarily exclude RTs at max or min
                    tempMean = mean(inRTs(~(Excluded)));
                    tempSD = std(inRTs(~(Excluded)));
                    
                    tempDist = SDcutoff*tempSD;
                    tempmaxCutoff = tempMean + tempDist;
                    tempminCutoff = tempMean - tempDist;
                    
                    % if the max is above the cutoff, exclude it INCLUDING ALL TIES & check again
                    if currentMax > tempmaxCutoff
                        TooHi = TooHi | (inRTs>=currentMax-eps);  % Use eps here to avoid numerical problems
                        NeedToCheck = true;
                    end
                    
                    % if the min is below the cutoff, exclude it INCLUDING ALL TIES & check again
                    if currentMin < tempminCutoff
                        TooLo = TooLo | (inRTs<=currentMin+eps);  % Use eps here to avoid numerical problems
                        NeedToCheck = true;
                    end
                    
                    Excluded = TooLo | TooHi;

                end  % while NeedToCheck
                
            end % while
            
            PropTooLo = sum(TooLo) / numel(inRTs);
            PropTooHi = sum(TooHi) / numel(inRTs);
            Mean = mean(inRTs(~Excluded));
            
        end % function SimpRecurSD
        

        function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = ModRecurSD(inRTs,SDcutoff)
            [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = VSJmnRTs.ModRecurGen(inRTs,SDcutoff);
        end % function ModRecurSD

        
        function [Mean, PropTooLo, PropTooHi, PropTooLo1, PropTooHi1, Excluded1, PropTooLo2, PropTooHi2, Excluded2, ...
                  TooLo1, TooHi1, TooLo2, TooHi2, EitherTooLo, EitherTooHi] = ...
                     HybridSD(inRTs,SDcutoff1,SDcutoff2)
            [Mean1, PropTooLo1, PropTooHi1, Excluded1, TooLo1, TooHi1] = VSJmnRTs.NonRecurSD(inRTs,SDcutoff1);
            [Mean2, PropTooLo2, PropTooHi2, Excluded2, TooLo2, TooHi2] = VSJmnRTs.ModRecurSD(inRTs,SDcutoff2);
            Mean = (Mean1 + Mean2) / 2;
            PropTooLo = (PropTooLo1 + PropTooLo2) / 2;
            PropTooHi = (PropTooHi1 + PropTooHi2) / 2;
            EitherTooLo = TooLo1 | TooLo2;
            EitherTooHi = TooHi1 | TooHi2;
        end % function HybridSD
        

        function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = NonRecur(inRTs)
            [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = VSJmnRTs.NonRecurGen(inRTs);
        end % function NonRecur
        

        function [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = ModRecur(inRTs)
            [Mean, PropTooLo, PropTooHi, Excluded, TooLow, TooHi] = VSJmnRTs.ModRecurGen(inRTs);
        end % function ModRecur


        function [Mean, PropTooLo, PropTooHi, PropTooLo1, PropTooHi1, Excluded1, PropTooLo2, PropTooHi2, Excluded2, TooLo1, TooHi1, TooLo2, TooHi2, EitherTooLo, EitherTooHi] = Hybrid(inRTs)
            [Mean1, PropTooLo1, PropTooHi1, Excluded1, TooLo1, TooHi1] = VSJmnRTs.NonRecur(inRTs);
            [Mean2, PropTooLo2, PropTooHi2, Excluded2, TooLo2, TooHi2] = VSJmnRTs.ModRecur(inRTs);
            Mean = (Mean1 + Mean2) / 2;
            PropTooLo = (PropTooLo1 + PropTooLo2) / 2;
            PropTooHi = (PropTooHi1 + PropTooHi2) / 2;
            EitherTooLo = TooLo1 | TooLo2;
            EitherTooHi = TooHi1 | TooHi2;
        end % function Hybrid



        % ******** Utility functions, not intended to be called by the user:


        function thiscutoff = SDCutoff(CutVals,CurrentSampleN)
            CurrentSampleN = min(CurrentSampleN,VSJmnRTs.maxSampleN);
            if CurrentSampleN <= VSJmnRTs.minSampleN
                error(['There is no cutoff for a sample size this small: ' num2str(CurrentSampleN) '; minimum is ' num2str(VSJmnRTs.minSampleN+1) '.']);
            end
            thiscutoff = CutVals(CurrentSampleN-VSJmnRTs.SampleNOffset);
        end

       
        function [Mean, PropTooLo, PropTooHi, Excluded, TooLo, TooHi] = ModRecurGen(inRTs,varargin)
            % Examine the RTs in the vector inRTs using VSJ's modified-recursive method with either fixed or moving SD.
            % Return the mean of the unexcluded ones & and array marking true for the excluded ones.
            % Output Excluded is a boolean vector of the same length as inRTs,
            %  where 'true' indicates excluded.
            % The optional argument is the SD cutoff to use for exclusion.
            %  with true indicating the RT should be excluded right from the start (e.g. errors).
            % Note that if errors are to be excluded or separate high/low cutoffs
            %  are to be applied, that can be done with varargin or when constructing inRTs.
            
            switch numel(varargin)
                case 0
                    Moving = true;
                case 1
                    Moving = false;
                    SDcutoff = varargin{1};
                otherwise
                    error('Illegal arguments.')
            end
            
            Excluded = false(size(inRTs));
            TooLo = false(size(inRTs));
            TooHi = false(size(inRTs));
            
            NeedToCheck = true;
            
            while NeedToCheck
                SampleN = numel(inRTs) - sum(Excluded);
                NeedToCheck = false;  % don't check again unless one of the following conditions is met
                if SampleN > VSJmnRTs.minSampleN  % No further exclusions once we reach minSampleN
                    if Moving
                        SDcutoff = VSJmnRTs.SDCutoff(VSJmnRTs.MRCutVals,SampleN);
                    end
                    
                    currentMax = max(inRTs(~Excluded));
                    currentMin = min(inRTs(~Excluded));
                    
                    % temporarily exclude RTs at max, INCLUDING ALL TIES
                    tempExcluded = inRTs==currentMax;
                    tempMean = mean(inRTs(~(Excluded|tempExcluded)));
                    tempSD = std(inRTs(~(Excluded|tempExcluded)));
                    
                    tempDist = SDcutoff*tempSD;
                    tempmaxCutoff = tempMean + tempDist;
                    tempminCutoff = tempMean - tempDist;
                    
                    % if the max is above the cutoff, exclude it INCLUDING ALL TIES & check again
                    if currentMax > tempmaxCutoff
                        TooHi = TooHi | (inRTs>=currentMax-eps);  % Use eps here to avoid numerical problems
                        NeedToCheck = true;
                    end
                    
                    % if the min is below the cutoff, exclude it INCLUDING ALL TIES NEWJEFF & check again
                    if currentMin < tempminCutoff
                        TooLo = TooLo | (inRTs<=currentMin+eps);  % Use eps here to avoid numerical problems
                        NeedToCheck = true;
                    end
                    
                    Excluded = TooLo | TooHi;

                end  % while NeedToCheck
                
            end % while
            
            PropTooLo = sum(TooLo) / numel(inRTs);
            PropTooHi = sum(TooHi) / numel(inRTs);
            Mean = mean(inRTs(~Excluded));
            
        end % function ModRecurGen
        

        function [Mean, PropTooLo, PropTooHi, Excluded, TooLo, TooHi] = NonRecurGen(inRTs,varargin)
            % Examine the RTs in the vector inRTs using VSJ's nonrecursive method with either fixed or moving SD.
            % Return the mean of the unexcluded ones & and array marking true for the excluded ones.
            % The optional argument is the SD cutoff to use for exclusion.
            
            switch numel(varargin)
                case 0
                    Moving = true;
                case 1
                    Moving = false;
                    SDcutoff = varargin{1};
                otherwise
                    error('Illegal arguments.')
            end
            
            Excluded = false(size(inRTs));
            TooLo = false(size(inRTs));
            TooHi = false(size(inRTs));

            SampleN = numel(inRTs);
            
            if SampleN > VSJmnRTs.minSampleN   % No further exclusions once we reach minSampleN.
                if Moving
                    SDcutoff = VSJmnRTs.SDCutoff(VSJmnRTs.NRCutVals,SampleN);
                end
                
                tempMean = mean(inRTs);
                tempSD = std(inRTs);
                
                tempDist = SDcutoff*tempSD;
                tempmaxCutoff = tempMean + tempDist;
                tempminCutoff = tempMean - tempDist;
                
                TooHi = (inRTs>tempmaxCutoff);
                TooLo = (inRTs<tempminCutoff);
                Excluded  = TooLo | TooHi;
                 
            end
            
            PropTooLo = sum(TooLo) / numel(inRTs);
            PropTooHi = sum(TooHi) / numel(inRTs);
            Mean = mean(inRTs(~Excluded));
            
        end % function NonRecurGen
        
    end % methods (Static)
    
end % classdef

