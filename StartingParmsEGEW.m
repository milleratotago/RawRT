function starting_parms = StartingParmsEGEW(Trials,sDV,CondSpecs,VarianceProportionInEx,varargin)
    % Compute a set of starting parameters mu, sigma, and exmean to use when
    % fitting the exGauMn or exWaldMS distribution.
    % Optional parameters Include/Exclude

    Observed = CondFunsOfDVs(Trials,sDV,CondSpecs,{@mean @std},varargin{:});  % Compute observed mean & sd of values in each condition
    
    % Make the table of starting parm values for each condition
    starting_parms = table;  % empty table in which to accumulate starting values for different variance proportions
    for iProp=1:numel(VarianceProportionInEx)
        thisProp = VarianceProportionInEx(iProp);
        % Compute starting parameter values that put thisProp of the sDV variance into
        % the exponential component and the rest into the Gaussian or Wald component.
        onetbl = Observed;
        startexvar = onetbl.RT_std.^2 * thisProp;
        startnormalvar = onetbl.RT_std.^2 * (1 - thisProp);
        startexmean = sqrt(startexvar);
        startsigma = sqrt(startnormalvar);
        startmu = onetbl.RT_mean - startexmean;
        onetbl.Parms = [startmu, startsigma, startexmean];
        starting_parms = [starting_parms; onetbl]; %#ok<AGROW>
    end
    
end

