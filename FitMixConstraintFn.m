function [Dists, Penalty] = FitMixConstraintFn(Dists,Reals)
% Constraint function to implement constraints used in fitting the
% mixture distribution.
% Parms(1) is assumed to reflect the mixture probability.
% The first half of the remaining parms are assumed to reflect the control distribution
% and the second half are assumed to reflect the effect-present part of the mixture distribution.

Parms = Dists{2}.RealsToParms(Reals);

NParmsPerDist = (numel(Parms) - 1) / 2;

Dists{1}.ResetParms(Parms(2:NParmsPerDist+1));
Dists{2}.ResetParms(Parms);

Penalty = 0;

end
