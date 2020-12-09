function  [obschisqval, obschisqp] = obschisq2x2(n1, n2, N1, N2)
    % compute chi-square test for 2x2 contingency table.
    % n1, N1 are the success & total counts for sample 1
    % n2, N2 are the success & total counts for sample 2
    % No correction for continuity
    
    % Pooled estimate of proportion
    p0 = (n1+n2) / (N1+N2);
    % Expected counts under H0 (null hypothesis)
    n10 = N1 * p0;
    n20 = N2 * p0;
    % Chi-square test, by hand
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    obschisqval = sum((observed-expected).^2 ./ expected);
    obschisqp = 1 - chi2cdf(obschisqval,1);
end
