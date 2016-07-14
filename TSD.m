classdef TSD
    
    % Methods for computing signal detection theory measures of sensitivity and bias.
    %
    % References with computational formulas and example values:
    % Macmillan, N. A. & Creelman, C. D. (1991). Detection theory: A user's guide. Cambridge Univ. Press.
    % Macmillan & Creelman, 1996, Psychonomic Bulletin & Review, vol 3(2) pp 164-170
    % Stanislaw, H. and Todorov, N. (1999).  Calculation of signal detection theory measures.
    %    Behavior Research Methods, Instruments & Computers, vol 31, pages 137-149. doi: 10.3758/BF03207704.
    
    methods(Static)
        
        % *** Yes-No Tasks **************************************************************
        
        function [PrHit, PrFA] = PrsFromNsYN(NHits,NFAs,NSignal,NNoise,AdjustType)
            % Compute PrHit and PrFA from relevant N's, with adjustments for Pr's of 0 & 1 that
            %   may be needed to avoid NaN's with Gaussian-based models (e.g., d').
            % AdjustType::
            %    0 : None
            %    1 : Replace 0 and maximum with 0.5 and maximum-0.5 to avoid Pr's of 0 and 1.
            %    2 : Loglinear
            switch AdjustType
                case 0
                    PrHit = NHits ./ NSignal;
                    PrFA = NFAs ./ NNoise;
                case 1
                    NHits(NHits == 0) = 0.5;
                    NHits(NHits == NSignal) = NSignal(NHits == NSignal) - 0.5;
                    NFAs(NFAs == 0) = 0.5;
                    NFAs(NFAs == NNoise) = NNoise(NFAs == NSignal) - 0.5;
                    PrHit = NHits ./ NSignal;
                    PrFA = NFAs ./ NNoise;
                case 2
                    PrHit = (NHits + 0.5) ./ (NSignal + 1);
                    PrFA = (NFAs + 0.5) ./ (NNoise + 1);
           end
        end
        
        function [dPrime, Beta, Crit] = dPrimeYN(PrHit, PrFA)
            OK = (PrHit>0) & (PrHit<1) & (PrFA>0) & (PrFA<1);
            dPrime(~OK) = NaN;
            Beta(~OK) = NaN;
            Crit(~OK) = NaN;
            ZHit(OK) = norminv(PrHit(OK));
            ZFA(OK) = norminv(PrFA(OK));
            dPrime(OK) = ZHit(OK) - ZFA(OK);
            Crit(OK) = -(ZHit(OK) + ZFA(OK)) / 2;  % Larger values indicate bias toward responding "yes"
            HitPDF(OK) = normpdf(ZHit(OK));
            FAPDF(OK) = normpdf(ZFA(OK));
            Beta(OK) = HitPDF(OK) ./ FAPDF(OK);
        end
        
        function [APrime, BDblPrime, BDonaldson] = NonparamYN(PrHit, PrFA)
            
            % Compute A', a non-parametric sensitivity index, from PrHit and PrFA in Yes/No task.
            % e.g., Aaronson & Watts, 1987, Equations 2 & 9
            APrime = 0.5*ones(size(PrHit));
            Degenerate = (PrFA == 1) | (PrHit == 0);
            %  APrime(Degenerate) = 0.5;  Not needed because all values are initialized to 0.5
            BigA = (PrHit >= PrFA) & ~Degenerate;
            APrime(BigA) = 0.5 + (PrHit(BigA) - PrFA(BigA)) .* (1 + PrHit(BigA) - PrFA(BigA)) ./ ( 4 * PrHit(BigA) .* (1 - PrFA(BigA)) );
            SmallA = (PrHit < PrFA) & ~Degenerate;
            APrime(SmallA) = 0.5 - (PrFA(SmallA) - PrHit(SmallA)) .* (1 + PrFA(SmallA) - PrHit(SmallA)) ./ ( 4 * PrFA(SmallA) .* (1 - PrHit(SmallA)) );

%            if PrHit >= PrFA
%                if (PrFA == 1.0) || (PrHit == 0.0)
%                    APrime = 0.5;
%                else
%                    APrime = 0.5 + (PrHit - PrFA) * (1 + PrHit - PrFA) / ( 4 * PrHit * (1 - PrFA) );
%                end
%            else
%                APrime = 0.5 - (PrFA - PrHit) * (1 + PrFA - PrHit) / ( 4 * PrFA * (1 - PrHit) );
%            end
            
            % Compute B'' (also see Aaronson & Watts, 1987, Equations 4 & 12):
            BDblPrime = zeros(size(PrHit));
            Degenerate2 = ( (PrHit == 0) | (PrHit == 1) ) & ( (PrFA  == 0) | (PrFA  == 1) );
            %  BDblPrime(Degenerate2) = 0;  Not needed because all values are initialized to 0
            BigA = (PrHit >= PrFA) & ~Degenerate2;
            BDblPrime(BigA) = ( PrHit(BigA) .* (1 - PrHit(BigA)) - PrFA(BigA) .* (1 - PrFA(BigA)) ) ./ ...
                              ( PrHit(BigA) .* (1 - PrHit(BigA)) + PrFA(BigA) .* (1 - PrFA(BigA)) );
            SmallA = (PrHit < PrFA) & ~Degenerate2;
            BDblPrime(SmallA) = ( PrFA(SmallA) .* (1 - PrFA(SmallA)) - PrHit(SmallA) .* (1 - PrHit(SmallA)) ) ./ ...
                                ( PrFA(SmallA) .* (1 - PrFA(SmallA)) + PrHit(SmallA) .* (1 - PrHit(SmallA)) );

%            if ( (PrHit == 0) || (PrHit == 1) ) && ( (PrFA  == 0) || (PrFA  == 1) )
%                BDblPrime = 0;
%            else
%                if PrHit >= PrFA
%                    BDblPrime = ( PrHit * (1 - PrHit) - PrFA * (1 - PrFA) ) / ...
%                        ( PrHit * (1 - PrHit) + PrFA * (1 - PrFA) );
%                else
%                    BDblPrime = ( PrFA * (1 - PrFA) - PrHit * (1 - PrHit) ) / ...
%                        ( PrFA * (1 - PrFA) + PrHit * (1 - PrHit) );
%                end
%            end

            % Compute Donaldson's Bias Measure, B''_D (Macmillan & Creelman, 1996, p 168)
            BDonaldson = zeros(size(PrHit));
            OK = ~Degenerate;
            BDonaldson(OK) = ( (1 - PrHit(OK)) .* (1 - PrFA(OK)) -  PrHit(OK).*PrFA(OK) ) ./ ...
                             ( (1 - PrHit(OK)) .* (1 - PrFA(OK)) +  PrHit(OK).*PrFA(OK) );
            
        end
        
    end
end
