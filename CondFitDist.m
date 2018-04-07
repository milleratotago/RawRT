function [outResultTable, outDVNames] = CondFitDist(inTable,sDVs,CondSpecs,DistObj,varargin)
% For each combination of CondSpecs, adjust the parameters of the DistObj to provide
% the best fit to the observed values of sDVs.
%
% varargin options:
%   Include/Exclude options passed through.
%
% If the DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
%   should be set to the desired values before calling this function.

[sFitType, varargin] = ExtractNameVali('FitType','MLE',varargin);
[NChiSqBins, varargin] = ExtractNameVali('NChiSqBins','-10',varargin);
% assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.

FitOptions = {'MLE' 'Moments' 'ChiSquareBins' 'Percentiles'};
FitPos = find(strcmpi(sFitType,FitOptions));
if numel(FitPos)>0
    switch FitPos(1)
        case 1
            NPassThru = 1; % DistObj
            [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistMLE,varargin{:},'NPassThru',NPassThru,DistObj);
        case 2
            NPassThru = 1; % DistObj
            [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistMoments,varargin{:},'NPassThru',NPassThru,DistObj);
        case 3
            assert(NChiSqBins>2,'Must specify NChiSqBins>2 to compute ChiSquareBins fits.');
            BinMax = DistObj.MakeBinSet(NChiSqBins,false);
            NPassThru = 2; % DistObj, BinMax
            [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistChiSquareBins,varargin{:},'NPassThru',NPassThru,DistObj,BinMax);
        case 4
            NPassThru = 1; % DistObj
            [outResultTable, outDVNames1] = CondFunsOfDVs(inTable,sDVs,CondSpecs,@FitDistPercentiles,varargin{:},'NPassThru',NPassThru,DistObj);
    end
else
    warning('Unrecognized fitting sFitType.  Options are:');
    FitOptions
    outResultTable = [];
    outDVNames = [];
    return
end


% Break up and relabel the parameter estimates and maximized fit value in the output table.
NDVsOut = DistObj.NDistParms + 1;  % Parameters and maximized fit score
outDVNames = cell(NDVsOut,1);
for iParm=1:DistObj.NDistParms
    outDVNames{iParm} = UniqueVarname(outResultTable,DistObj.ParmNames{iParm});
    outResultTable.(outDVNames{iParm}) = outResultTable.(outDVNames1{1})(:,iParm);
end
outDVNames{NDVsOut} = UniqueVarname(outResultTable,'Best');
outResultTable.(outDVNames{NDVsOut}) = outResultTable.(outDVNames1{1})(:,NDVsOut);

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end


function out = FitDistMLE(inDVs,DistObj)
HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
DistObj.EstML(inDVs);
Best = -DistObj.LnLikelihood(inDVs);
out = [DistObj.ParmValues Best]; % List of parameter values plus final maximum fit score
DistObj.ResetParms(HoldParms);   % Restore original parameter values
end


function out = FitDistMoments(inDVs,DistObj)
HoldParms = DistObj.ParmValues;
ObsMoments = DistObj.MomentsFromScores(inDVs);
DistObj.EstMom(ObsMoments);
Best = DistObj.MomentError(ObsMoments);
out = [DistObj.ParmValues Best];
DistObj.ResetParms(HoldParms);
end


function out = FitDistChiSquareBins(inDVs,DistObj,BinMax)
HoldParms = DistObj.ParmValues;
BrainDeadHistc=histc(inDVs,BinMax);
BinProbs = BrainDeadHistc(1:numel(BinMax))/numel(inDVs);
DistObj.EstChiSq(BinMax,BinProbs);
Best = DistObj.GofFChiSq(BinMax,BinProbs);
out = [DistObj.ParmValues Best];
DistObj.ResetParms(HoldParms);
end


function out = FitDistPercentiles(inDVs,DistObj)
HoldParms = DistObj.ParmValues;
[ObsPrctiles, TargetCDFs] = DistObj.PercentilesFromScores(inDVs);
DistObj.EstPctile(ObsPrctiles,TargetCDFs);
Best = DistObj.PercentileError(ObsPrctiles,TargetCDFs);
out = [DistObj.ParmValues Best];
DistObj.ResetParms(HoldParms);
end

