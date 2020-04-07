function [GlobalBestParms, GlobalBestScore, Disagreement, LocalBestParms, LocalBestScore] = EGorEWMLSearch(RT, Dist, SigmaProportionInEx, varargin)
    % Function to run multiple searches for best-fitting parameters for Ex-Gaussian or Ex-Wald distribution,
    % starting at a series of plausible starting values (SigmaProportionInEx), selected based on the current RTs.
    
    % Inputs:
    %   RTs is a vector of the RTs to be fit.
    %   Dist is the distribution to be fit, either ExGauMn or ExWaldMSM
    %   SigmaProportionInEx is a vector of proportions (0-1) of the proportions of
    %    observed variance to put into the starting values of the exponential component.
    % Optional:
    %   NDecPlaces: The number of decimal places to which the parameter estimates must be the same
    %    in order to be considered as in agreement. Default = 2.
    
    % Outputs:
    %   Best-fitting parameter values
    %   The best minimized error function value
    %   A measure of the disagreement of the different ending values: the number of final parameter
    %     values that were NOT the same to NDecPlaces.
    %   The ending values, search by search.

    % Original version replaced by EGorEWFit which also does percentile-based fitting (old version saved in storage)
    
    [GlobalBestParms, GlobalBestScore, Disagreement, LocalBestParms, LocalBestScore] = EGorEWFit(RT, Dist, SigmaProportionInEx, varargin{:});

end
