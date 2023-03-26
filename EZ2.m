classdef EZ2
    % A collection of functions used in estimating the parameters of the EZ2 model
    % of Grasman, Wagenmakers, & van der Maas (2009). doi: 10.1016/j.jmp.2009.01.006
    % These functions are translations from the Grasman R package, provided to me by Tobias Rieger.
    % Note that this version of the diffusion model is fit with separate RTs for correct & error,
    % and it produces estimates of four parameters.
    % In contrast, the version of Wagenmakers, Van der Maas, and Grasman (2007) is fit with just correct RTs
    % and it produces estimates of only three parameters.
    %
    % WARNING: The parameter estimates produced by these procedures are HIGHLY SENSITIVE to the starting
    % values of the parameter search.  Ter values and drift rates can be negative.
    
    % The model parameters are:
    % v: drift rate
    % z: starting point
    % a: boundary separation
    % Ter: Residual response time
    
    % s: arbitrary scaling parameter that is conventionally fixed at 0.1
    
    % observed & predicted values are always given in the order:
    % mean of correct rt
    % variance of correct rt
    % mean of all rt
    % variance of all rt
    % prob of error

    
    methods (Static)
        
        function predcmrt = cmrt(v,z,a)
            % Description from the Grasman R Package
            % Given a boundary separation, a starting point, and a drift rate, this
            % function computes the mean exit time/exit time variance of a one dimensional
            % diffusion process under constant drift on an interval with absorbing boundaries,
            % conditioned on the point of exit. Used as a model of information accumulation,
            % it is gives the mean decision time/decision time variance of responses in a
            % speeded two-alternative forced choice (2AFC) response time task, conditional
            % on what alternative was decided upon.
            % EZ2.cmrt returns the mean exit/decision time(s)
            
            
            s = 0.1;  % fixed at conventional value
            
            sSquare = s^2;
            TwoV = 2 * v;
            
            predcmrt = (((((exp((4 * v/sSquare) * a)) + (exp(TwoV * (z + a)/sSquare)) - (exp((TwoV/sSquare) * a)) - (exp(TwoV * z/sSquare))) * z + ...
                (2 * (exp((TwoV/sSquare) * a)) - 2 * (exp(TwoV * (z + a)/sSquare))) * a)/v)/...
                ((exp((TwoV/sSquare) * a)) - (exp(TwoV * z/sSquare)))) / ... %expr28
                (-1 + (exp((TwoV/sSquare) * a))); %expr30
            
        end % function cmrt
        
        
        function predcvrt = cvrt(v,z,a)
            % Description from the Grasman R Package:
            % Given a boundary separation, a starting point, and a drift rate, this
            % function computes the mean exit time/exit time variance of a one dimensional
            % diffusion process under constant drift on an interval with absorbing boundaries,
            % conditioned on the point of exit. Used as a model of information accumulation,
            % it is gives the mean decision time/decision time variance of responses in a
            % speeded two-alternative forced choice (2AFC) response time task, conditional
            % on what alternative was decided upon.
            % EZ2.cmrt returns the mean exit/decision time(s)
            
            s = 0.1;  % fixed at conventional value
            sSquare = s^2;
            TwoZ = 2 * z;
            FourZ = 4 * z;
            aSquare = a^2;
            zSquare = z^2;
            
            predcvrt = (((((((-4 * v) * (exp((2 * v/sSquare) * a))) * (-1 + (exp(TwoZ * v/sSquare)))) *...
                ((exp((4 * v/sSquare) * a)) - (exp(TwoZ * v/sSquare)))) * aSquare - (((4 * (exp((2 * (z + a)) * v/sSquare))) * v) *...
                (((exp((2 * v/sSquare) * a)) - 1)^2)) * zSquare + ((((8 * (exp((2 * (z + a)) * v/sSquare))) * v) *...
                (((exp((2 * v/sSquare) * a)) - 1)^2)) * a) * ...
                z + (((((2 * sSquare) * (exp((2 * v/sSquare) * a))) * (-1 + (exp(TwoZ * v/sSquare)))) * ((exp((2 * v/sSquare) * a)) - 1)) * ...
                (-(exp((2 * v/sSquare) * a)) + (exp(TwoZ * v/sSquare)))) * a - ((sSquare * (((exp((2 * v/sSquare) * a)) - 1)^2)) * ...
                (-(exp((4 * v/sSquare) * a)) + (exp(FourZ * v/sSquare)))) * z)/(((exp((2 * v/sSquare) * a)) - 1)^2))/(v^3) )/ ... %expr64
                ((exp((2 * v/sSquare) * a)) - (exp(TwoZ * v/sSquare)))^2; %expr66
            
        end % function cvrt
        
        
        function predmrt = mrt (v, z, a)
            % Description from the Grasman R Package:
            % "Given a boundary separation, a starting point, and a drift rate, this
            % function computes the mean exit time/exit time variance of a one dimensional
            % diffusion process under constant drift on an interval with absorbing boundaries.
            % Used as a model of information accumulation, it is gives the mean decision
            % time/decision time variance of responses in a speeded two-alternative forced choice
            % (2AFC) response time task, regardless of whether the response is correct or incorrect."
            
            s = 0.1;  % fixed at conventional value
            sSquare = s * s;
            
            predmrt = ((a/((exp((-2 * v/sSquare) * a)) - 1))/v) * ... % expr9
                (exp((-2 * v/sSquare) * z)) - ... %expr11
                (1/v) * ... %expr13
                (z) - ...
                ((1/v) * a) / ... %expr16
                ((exp((-2 * v/sSquare) * a)) - 1); %expr7
            
            % mrt = mrt*1000; %converts seconds into milliseconds
            
        end % function mrt
        
        
        function predvrt = vrt (v, z, a)
            % Description from the Grasman R Package:
            % "Given a boundary separation, a starting point, and a drift rate, this
            % function computes the mean exit time/exit time variance of a one dimensional
            % diffusion process under constant drift on an interval with absorbing boundaries.
            % Used as a model of information accumulation, it is gives the mean decision
            % time/decision time variance of responses in a speeded two-alternative forced choice
            % (2AFC) response time task, regardless of whether the response is correct or incorrect."
            
            s = 0.1;  % fixed at conventional value
            sSquare = s^2;
            aSquare = a^2;
            
            denominator = ((-v * (((exp((-2 * v/sSquare) * z)) - 1)^2)) * aSquare - ((4 * v) * ((exp((-2 * v/sSquare) * z)) - 1)) * aSquare) / ... %expr16
                (((exp((-2 * v/sSquare) * a)) - 1)^2) + ... %expr20
                (((-3 * v) * aSquare + (((4 * v) * z) * a) + sSquare * a) * ((exp((-2 * v/sSquare) * z)) - 1) + (((4 * v) * z) * a)) / ... %expr31
                ((exp((-2 * v/sSquare) * a)) - 1) - ... %expr19
                sSquare * ...
                z;
            predvrt = denominator/...
                (v^3); %expr36
            % vrt = vrt*1000;
            
        end % function vrt
        
        
        function predpe = pe (v, z, a)
            % Description from the Grasman R Package:
            % "Computes the probability of exit through the lower bound of a univariate
            % diffusion process with constant drift on an interval with absorbing boundaries.
            % Used as a model of information accumulation, it is gives the probability of
            % an error response in a speeded two-alternative forced choice (2AFC)
            % response time task."
            
            s = 0.1;  % fixed at conventional value
            sSquare = s * s;
            
            predpe = ((exp((-2 * v/sSquare) * a)) - (exp((-2 * v/sSquare) * z))) / ... %expr9
                ((exp((-2 * v/sSquare) * a)) - 1); %expr10
            
        end % function pe
        

        function pred = predicted(v,z,a,Ter)
            % Compute the 5 predicted values from these parameter values.
            pred = nan(1,5);
            pred(1) = EZ2.cmrt(v,z,a) + Ter;  % EZ2cmrt & EZ2mrt treated Ter differently in R, but JOM changed that
            pred(2) = EZ2.cvrt(v,z,a);
            pred(3) = EZ2.mrt(v,z,a) + Ter;
            pred(4) = EZ2.vrt(v,z,a);
            pred(5) = EZ2.pe(v,z,a);
        end

        function thiserr=error(parms,obs)
            % Compute error between the observed values and
            % the values predicted from these parameters.
            pCell = num2cell(parms);
            [v,z,a,Ter] = pCell{:};
            pred = EZ2.predicted(v,z,a,Ter);
            thiserr = sum((pred-obs).^2);
        end
        
        function [v, z, a, Ter] = Fit(CorMRT, CorVRT, MRT, VRT, Pe, varargin)
            % Estimate parameters of EZ2-Diffusion model for a 2-choice RT task
            %
            % Inputs:
            % Pe = proportion error, between 0 and 1; cannot be 0.0, 0.5, or 1.0.
            % MRT, VRT = mean /variance of ALL response RTs MEASURED IN SECONDS
            % CorMRT, CorVRT = mean /variance of CORRECT response RTs MEASURED IN SECONDS
            %
            % Optional inputs:
            %   'SearchOptions',SO: SO is a MATLAB optimset structure passed through to fminsearch
            %   'StartingValues',SV: SV is a vector of fminsearch starting values for the 5 parameters v, z, a, Ter.
            %
            % Outputs:
            % Estimated parameter values.
            % SearchResults returned by from fminsearch

            assert(CorMRT<10 && MRT<10,'This function requires the means and variances of RTs measured in SECONDS, not milliseconds!');
            
            DefaultStartingValues = [0.15, 0.08, 0.17, 0.3];
            [StartingValues, varargin] = ExtractNameVali('StartingValues',DefaultStartingValues,varargin);
            [SearchOptions, varargin] = ExtractNameVali('SearchOptions',{},varargin);
            % SearchOptions = EnsureCell(SearchOptions);
            EnsureEmpty(varargin); % Halt if there are any unprocessed input arguments:
            
            obs = [CorMRT, CorVRT, MRT, VRT, Pe];
            
            ErrFn = @myerror;
            EndingVals = fminsearch(ErrFn,StartingValues,SearchOptions);
            cEndingVals = num2cell(EndingVals);
            [v, z, a, Ter] = cEndingVals{:};
            
            function thiserr=myerror(parms)
                thiserr = EZ2.error(parms,obs);
            end
            
        end  % function Fit
        
        
    end % methods (Static)
    
end

