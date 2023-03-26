function [v, a, Ter, MDT] = EZDiff(Pc, VRT, MRT, varargin)
    % Compute parameters of EZ-Diffusion model for a 2-choice RT task
    % (Wagenmakers, Van der Maas, and Grasman, 2007, doi: 10.3758/BF03194023)
    %
    % Pc = proportion correct, between 0 and 1; cannot be 0.0, 0.5, or 1.0.
    % MRT, VRT = mean /variance of correct response RTs MEASURED IN SECONDS
    % Note from http://www.ejwagenmakers.com/EZ.html:
    % "If you have calculated the RT mean and RT variance based on data measured in milliseconds,
    % you need to take some care when transforming these quantities to seconds. The RT mean in seconds
    % is obtained from the RT mean in milliseconds by simply dividing by 1000, but the RT variance
    % in seconds-squared is obtained from the RT variance in milliseconds by dividing by 1000 times 1000
    % (i.e., 1,000,000)."
    %
    % Note that this version of the diffusion model is fit with just correct RTs,
    % and it produces estimates of three parameters.
    % In contrast the version of Grasman, Wagenmakers, & van der Maas (2009) is fit with separate RTs for correct & error,
    % and it produces estimates of four parameters.
      
    if numel(varargin)==0
        s = 0.1;  % default value for the scaling parameter
    else
        s = varargin{1};
    end
    
    s2 = s^2;
    
    if (Pc == 0) || (Pc == 0.5) || (Pc == 1.0)
        error(['The EZDiff method will not work if Pc equals 0, .5, or 1,' ...
               ' so an edge-correction is required (see Wagenmakers et al).']);
    end
    
    L = logit(Pc);
    x = L*(L*Pc^2 - L*Pc + Pc - 0.5)/VRT;
        
    % The sign function returns -1 for all negative numbers and returns +1 for all positive numbers.
    v = sign(Pc-0.5)*s*x^(1/4);
    % this gives drift-rate
    
    a = s2*logit(Pc)/v;
    % this gives boundary separation
    
    y = -v*a/s2;
    MDT = (a/(2*v))*(1-exp(y))/(1+exp(y));
    Ter = MRT-MDT;
    % this gives nondecision time
    
end

function y=logit(p)
    y = log(p/(1-p));
end
