function [outResultTable, outDVNames] = CondFitPmetric(inTable,StimDV,RespDV,CondSpecs,DistObj,varargin)
% For each combination of CondSpecs, adjust the parameters of the DistObj to provide
% the best fitting psychometric function relating RespDV to StimDV.
%
% varargin options:
%   Include/Exclude options passed through.
%
% If the DefaultParmCodes are not to be used (see Cupid), then DistObj.ParmCodes
%   should be set to the desired values before calling this function.

[sFitType, varargin] = ExtractNameVali('Fit','MLE',varargin);
[sTaskType, varargin] = ExtractNameVali('Task','YN',varargin);
% assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);  % Allow arguments to pass through.

FitOptions = {'MLE' 'ChiSquare'};  % Do not change order: assumed where FitPos is used.
FitPos = find(strcmpi(sFitType,FitOptions));
assert(numel(FitPos)==1,['Unrecognized fit type "' sFitType '". Legal options are: ' strjoin(FitOptions)]);

TaskOptions = {'YN' '2AFC' '3AFC' '4AFC' '5AFC' '6AFC' '7AFC' '8AFC' '9AFC'};  % Do not change order: assumed where TaskPos is used.
TaskPos = find(strcmpi(sTaskType,TaskOptions));
assert(TaskPos>0,['Unrecognized task type "' sTaskType '". Legal options are: ' strjoin(TaskOptions)]);
mAFC = TaskPos;  % 2+;  Not used with YN tasks.

switch FitPos
    case 1   % MLE fit
        if TaskPos == 1
            NPassThru = 3; % DistObj, StimDV, RespDV
            [outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@FitYNMLE,varargin{:},'NPassThru',NPassThru,DistObj,StimDV,RespDV);
        else
            NPassThru = 4; % DistObj, mAFC, StimDV, RespDV
            [outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@FitmAFCMLE,varargin{:},'NPassThru',NPassThru,DistObj,mAFC,StimDV,RespDV,varargin{:});
        end
    case 2   % ChiSquare fit
        if TaskPos == 1
            NPassThru = 3; % DistObj, StimDV, RespDV
            [outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@FitYNChiSq,'NPassThru',NPassThru,DistObj,StimDV,RespDV,varargin{:});
        else
            NPassThru = 4; % DistObj, mAFC, StimDV, RespDV
            [outResultTable, outDVNames1] = CondFunsOfTrials(inTable,CondSpecs,@FitmAFCChiSq,'NPassThru',NPassThru,DistObj,mAFC,StimDV,RespDV,varargin{:});
        end
end  % switch FitPos


% Break up and relabel the parameter estimates and maximized fit value in the output table.
NExtraDVs = 3;  % PSE, DL, and best fit score
NDVsOut = DistObj.NDistParms + NExtraDVs;  % Parameters + NExtraDVs
outDVNames = cell(NDVsOut,1);
for iParm=1:DistObj.NDistParms
    outDVNames{iParm} = UniqueVarname(outResultTable,DistObj.ParmNames{iParm});
    outResultTable.(outDVNames{iParm}) = outResultTable.(outDVNames1{1})(:,iParm);
end
outDVNames{DistObj.NDistParms+1} = UniqueVarname(outResultTable,'PSE');
outDVNames{DistObj.NDistParms+2} = UniqueVarname(outResultTable,'DL');
outDVNames{DistObj.NDistParms+3} = UniqueVarname(outResultTable,'Best');
for iExtra = 1:NExtraDVs
   outResultTable.(outDVNames{DistObj.NDistParms+iExtra}) = outResultTable.(outDVNames1{1})(:,DistObj.NDistParms+iExtra);
end

% Remove the variable that held all of the output components.
outResultTable.(outDVNames1{1}) = [];

end

function out = FitYNMLE(inTrials,DistObj,StimDV,RespDV)
HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
[TheseStims, NTrials, NGreater] = Preprocess(inTrials,StimDV,RespDV);
DistObj.EstProbitYNML(TheseStims,NTrials,NGreater);
Best = -DistObj.YNProbitLnLikelihood(TheseStims,NTrials,NGreater);
PSE = DistObj.InverseCDF(0.50);
DL = DistObj.InverseCDF(0.75) -  DistObj.InverseCDF(0.25);
out = [DistObj.ParmValues PSE DL Best]; % List of parameter values plus final maximum fit score
DistObj.ResetParms(HoldParms);   % Restore original parameter values
end


function out = FitYNChiSq(inTrials,DistObj,StimDV,RespDV)
HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
[TheseStims, NTrials, NGreater] = Preprocess(inTrials,StimDV,RespDV);
DistObj.EstProbitYNChiSq(TheseStims,NTrials,NGreater);
Best = -DistObj.YNProbitChiSq(TheseStims,NTrials,NGreater);
PSE = DistObj.InverseCDF(0.50);
DL = DistObj.InverseCDF(0.75) -  DistObj.InverseCDF(0.25);
out = [DistObj.ParmValues PSE DL Best]; % List of parameter values plus final maximum fit score
DistObj.ResetParms(HoldParms);   % Restore original parameter values
end

function out = FitmAFCMLE(inTrials,DistObj,mAFC,StimDV,RespDV)
HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
[TheseStims, NTrials, NGreater] = Preprocess(inTrials,StimDV,RespDV);
DistObj.EstProbitmAFCML(mAFC,TheseStims,NTrials,NGreater);
Best = -DistObj.mAFCProbitLnLikelihood(mAFC,TheseStims,NTrials,NGreater);
PSE = DistObj.InverseCDF(0.50);
DL = DistObj.InverseCDF(0.75) -  DistObj.InverseCDF(0.25);
out = [DistObj.ParmValues PSE DL Best]; % List of parameter values plus final maximum fit score
DistObj.ResetParms(HoldParms);   % Restore original parameter values
end


function out = FitmAFCChiSq(inTrials,DistObj,mAFC,StimDV,RespDV)
HoldParms = DistObj.ParmValues;  % Save and later restore parameter values so that each data set is fit with the same starting parameter values.
[TheseStims, NTrials, NGreater] = Preprocess(inTrials,StimDV,RespDV);
DistObj.EstProbitmAFCChiSq(mAFC,TheseStims,NTrials,NGreater);
Best = -DistObj.mAFCProbitChiSq(mAFC,TheseStims,NTrials,NGreater);
PSE = DistObj.InverseCDF(0.50);
DL = DistObj.InverseCDF(0.75) -  DistObj.InverseCDF(0.25);
out = [DistObj.ParmValues PSE DL Best]; % List of parameter values plus final maximum fit score
DistObj.ResetParms(HoldParms);   % Restore original parameter values
end

function [AllStims, NTrials, NLarger] = Preprocess(inTrials,StimDV,RespDV)
% Determine the list of stimuli, number of trials for each stimulus, and the
% number of times each stimulus value received the response "larger"
[outResultTable, ~, ~, AllStims, AllResps] = CondSRCrosstab(inTrials,StimDV,RespDV,{});
% Assume there are exactly 2 responses and that they are in the order of: smaller, larger.
assert(numel(AllResps)==2,'Need exactly 2 responses to fit psychometric model.');
NSmaller  = outResultTable.Count(outResultTable.(RespDV)==AllResps(1));
NLarger = outResultTable.Count(outResultTable.(RespDV)==AllResps(2));
NTrials = NSmaller + NLarger;
end

