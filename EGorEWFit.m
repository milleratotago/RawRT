function [GlobalBestParms, GlobalBestScore, Disagreement, LocalBestParms, LocalBestScore] = EGorEWFit(RT, Dist, SigmaProportionInEx, varargin)
    % Function to run multiple searches for best-fitting parameters for Ex-Gaussian or Ex-Wald distribution,
    %  starting at a series of plausible starting values (SigmaProportionInEx), selected based on the current RTs.
    % Fitting is either maximum-likelihood or percentile-based depending on whether varargin
    %  contains a vector of 3 CDF points to use for percentile-based fitting.
    % NEWJEFF: There is some redundancy between CondFitDist and EGorEWFit
    
    % Inputs:
    %   RTs is a vector of the RTs to be fit.
    %   Dist is the distribution to be fit, either ExGauMn or ExWaldMSM
    %   SigmaProportionInEx is a vector of proportions (0-1) of the proportions of
    %    observed variance to put into the starting values of the exponential component.
    % Optional:
    %   NDecPlaces: The number of decimal places to which the parameter estimates must be the same
    %    in order to be considered as in agreement. Default = 2.
    %   varargin: vector of 3 CDF points (e.g., .25/.50/.75 or .15/.50/.85) to use in fitting via percentiles; if omitted, use max likelihood
    
    % Outputs:
    %   Best-fitting parameter values
    %   The best minimized error function value
    %   A measure of the disagreement of the different ending values: the number of final parameter
    %     values that were NOT the same to NDecPlaces.
    %   The ending values, search by search.
    
    [NDecPlaces, varargin] = ExtractNameVali({'NDecPlaces','NDP'},2,varargin);

    if numel(varargin) == 0
        MLEFit = true;
    else
        MLEFit = false;
        PercentilesToFit = varargin{1};
        RTPctiles = prctileTies(RT,PercentilesToFit*100);
    end
    
    NSearches = numel(SigmaProportionInEx);
    obsmu = mean(RT);
    obsvar = var(RT);
%     obssd = sqrt(obsvar)
    
    LocalBestParms = cell(NSearches,1);
    LocalBestScore = zeros(NSearches,1);
    
    endSigmaPropInEx = 0;  % Do not skip the next search
    
    if isprop(Dist,'MinSigma')
        MinSigma = Dist.MinSigma;
    elseif isprop(Dist,'MinWaldSD')
        MinSigma = Dist.MinWaldSD;
    else
        MinSigma = 0;
    end

    for iSearch=1:NSearches
        starttauvar = SigmaProportionInEx(iSearch)*obsvar;
        startNWvar = obsvar - starttauvar;
        starttaumean = sqrt(starttauvar);
        startNWmean = obsmu - starttaumean;
        startNWmean = max(1,startNWmean);
        thisSigmaStart = sqrt(startNWvar);
        if (thisSigmaStart > MinSigma) && ( (endSigmaPropInEx < SigmaProportionInEx(iSearch)) || (iSearch == NSearches) )
            % Perform this search if it is the last search or if the previous search ended at a lower SigmaProportion
            Dist.ResetParms([startNWmean,thisSigmaStart,starttaumean]);
%           [~,LocalBestParms{iSearch},LocalBestScore(iSearch),~,~] = Dist.EstML(RT);
            if MLEFit
                [~,LocalBestParms{iSearch},LocalBestScore(iSearch),~,~] = Dist.EstML(RT);
            else
                [~,LocalBestParms{iSearch},LocalBestScore(iSearch),~,~] = Dist.EstPctile(RTPctiles,PercentilesToFit);
            end
            endExVar = LocalBestParms{iSearch}(3)^2;
            endSigmaPropInEx = endExVar / (endExVar + LocalBestParms{iSearch}(2)^2);
        else
            % Do not perform this search if the previous search ended at a higher SigmaProportionInEx
            % or if the starting sigma is too small.
%             disp('Skipped a search');
            LocalBestParms{iSearch} = LocalBestParms{iSearch-1};
            LocalBestScore(iSearch) = LocalBestScore(iSearch-1);
            endSigmaPropInEx = 0;  % Do not skip the next search
        end
    end
    
    BestSearch = find(LocalBestScore==min(LocalBestScore),1);
    GlobalBestScore = LocalBestScore(BestSearch);
    GlobalBestParms = LocalBestParms{BestSearch};
    
    % Measure disagreement among search end points
    Disagreement = 0;
    RoundBest = round(GlobalBestParms,NDecPlaces);
    for iSearch = 1:NSearches
        thisBest = round(LocalBestParms{iSearch},NDecPlaces);
        Disagreement = Disagreement + sum(abs(thisBest-RoundBest)>0);
    end
    
end
