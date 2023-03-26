% The goals of this demo are to illustrate how to fit the observations in each condition
% to the EZ-Diffusion model.

%% Generate some simulated data for a demonstration.
% Normally, you would start your script by reading in your real data.
Trials = DemoData('DemoFitDist');
Trials.RTOK = true(height(Trials),1);  % Mark the trials as all OK for the analysis (this demo ignores the possibility of outliers).

Trials.Cor = rand(height(Trials),1)>.2;  % Assign some random accuracies to the test data

%% EZDiff

EZDiffParms = CondFitEZDiff(Trials,'RT',{'SubNo' 'Cond'});

%% EZ2Diff

EZ2DiffParms = CondFitEZ2Diff(Trials,'RT',{'SubNo' 'Cond'});  % This assumes RTs are in msec

% Here is how to get the predicted values from the parameter estimates:
% Note that the predicted values are in SECONDS.
EZ2DiffParms.pred_cormrt = zeros(height(EZ2DiffParms),1);
EZ2DiffParms.pred_corvrt = zeros(height(EZ2DiffParms),1);
EZ2DiffParms.pred_mrt = zeros(height(EZ2DiffParms),1);
EZ2DiffParms.pred_vrt = zeros(height(EZ2DiffParms),1);
EZ2DiffParms.pred_pe = zeros(height(EZ2DiffParms),1);
for iCond=1:height(EZ2DiffParms)
    preds = EZ2.predicted( EZ2DiffParms.EZ2Diff_v(iCond),EZ2DiffParms.EZ2Diff_z(iCond), ...
        EZ2DiffParms.EZ2Diff_a(iCond),EZ2DiffParms.EZ2Diff_Ter(iCond) );
    EZ2DiffParms.pred_cormrt(iCond) = preds(1);
    EZ2DiffParms.pred_corvrt(iCond) = preds(2);
    EZ2DiffParms.pred_mrt(iCond) = preds(3);
    EZ2DiffParms.pred_vrt(iCond) = preds(4);
    EZ2DiffParms.pred_pe(iCond) = preds(5);
end

%% LBA

StartParmsArray = [0.8 300 150 0.4 200];
LBAParms = CondFitLBA2(Trials,'RT',{'SubNo' 'Cond'},StartParmsArray);