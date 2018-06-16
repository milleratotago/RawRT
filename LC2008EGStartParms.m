function StartParms = LC2008EGStartParms(data,varargin)
% Return starting parameters for fitting ex-Gaussian based on the to-be-fitted data,
%   using an approach based on a suggestion of Lacouture & Cousineau (2008).
% If the optional argument is not included, the default starting fraction
%   of the std assigned to tau is 0.8, as they recommendeded.
% If the optional argument is included, it is used as the starting fraction.
if numel(varargin)==0
    StartFrac = 0.8;
else
    StartFrac = varargin{1};
end
tau = std(data)*StartFrac;
mu = mean(data) - tau;
sig = sqrt(var(data)-(tau^2));
StartParms = [mu, sig, tau];
end
