function [outResultTable, outDVNames] = CondCorrs(inTable,sDV1,sDV2,CondSpecs,Degree,varargin)
% For each combination of CondSpecs, compute the linear/nonlinear prediction
% of sDV2 from sDV1 across all rows with that combination.

sModel = [sDV2 '~' sDV1];
for iDeg = 2:Degree
    PwrName = UniqueVarname(inTable,['Pwr' num2str(iDeg)]);
    inTable.(PwrName) = inTable.(sDV1).^iDeg;
    sModel = [sModel '+' PwrName];  %#ok<AGROW>
end

[outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@Fit,varargin{:},'NPassThru',1,sModel);

% Break up and relabel the fitting-related variables in the output table.
NDVsOut = Degree + 3; % Intercept, Slopes, Rsqr, RMSE
outDVNames = cell(NDVsOut,1);
outDVNames{1} = UniqueVarname(outResultTable,'Intercept');
outResultTable.(outDVNames{1}) = outResultTable.(outDVNames1{1})(:,1);
for i=1:Degree
    outDVNames{i+1} = UniqueVarname(outResultTable,['Slope' num2str(i)]);
    outResultTable.(outDVNames{i+1}) = outResultTable.(outDVNames1{1})(:,i+1);
end
outDVNames{Degree+2} = UniqueVarname(outResultTable,'Rsqr');
outDVNames{Degree+3} = UniqueVarname(outResultTable,'RMSE');
outResultTable.(outDVNames{Degree+2}) = outResultTable.(outDVNames1{1})(:,Degree+2);
outResultTable.(outDVNames{Degree+3}) = outResultTable.(outDVNames1{1})(:,Degree+3);

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

function out = Fit(inTable,sModel)
lm = fitlm(inTable,sModel); 
% Note that the output is a list of several component values:
out = [lm.Coefficients.Estimate(:)' lm.Rsquared.Ordinary lm.RMSE];
end

