function StartParms = LC2008EGStartParms80(data)
% Return starting parameters suggested by Lacouture & Cousineau (2008) for fitting ex-Gaussian
tau = std(data)*0.8;
mu = mean(data) - tau;
sig = sqrt(var(data)-(tau^2));
StartParms = [mu, sig, tau];
end
