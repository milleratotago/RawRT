function ZofYs = ZCouChSqrt(x)
    % Compute ZofY scores for each of the x using the formulas in CousineauChartier2010, starting at Eqn (1).
    xmin = min(x);
    xmax = max(x);
    props = (x - xmin) / (xmax - xmin);
    Ys = sqrt(props);
    ZofYs = (Ys - mean(Ys)) / std(Ys);
end
