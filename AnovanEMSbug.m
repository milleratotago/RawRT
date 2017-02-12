% anovan EMS bug report

% Load some test data.  Y holds the data, and A,B,S hold the group labels.
A = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2];
B = [1;1;1;1;1;1;2;2;2;2;2;2;3;3;3;3;3;3;4;4;4;4;4;4;5;5;5;5;5;5;1;1;1;1;1;1;2;2;2;2;2;2;3;3;3;3;3;3;4;4;4;4;4;4;5;5;5;5;5;5];
S = [1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6;1;2;3;4;5;6];
Y = [281;300;318;276;341;336;303;297;325;276;333;342;316;317;329;294;342;354;320;315;347;311;366;350;329;331;354;318;367;379;281;300;298;258;330;336;300;290;318;280;328;347;319;312;325;292;344;360;314;309;340;303;353;342;314;309;339;310;350;362];

% Run anovan
[~, tbl, ~] = anovan(Y,{A,B,S},'model','full','random',3,'varnames',{'A' 'B' 'S'},'display','off');

disp('Many of the expressions shown in column 9 of the output tbl (Expected MS) are incorrect.');
disp('For example, the following two expected MS expressions are incorrect.');
Error1 = tbl{2,9}
Error2 = tbl{3,9}
disp('The correct expressions for this design are:');
Correct1 = '30*Q(A)+5*V(A*S)+V(A*B*S)+V(Error)'
Correct2 = '12*Q(B)+2*V(B*S)+V(A*B*S)+V(Error)'

% Column 9 is also incorrect in several other rows.

% Here is one source that can be used to check the correct Expected MS expressions for this design:
%   title = {Designing experiments and analyzing data: {A} model comparison perspective.},
%   author = {Maxwell, S E and Delaney, H D},
%   publisher = {Wadsworth},
%   year = {1990},
%   address = {Monterey, CA, US},
% Table 12.3 on page 500 shows the correct E[MS] values for this design.

%% an example from the book by Milliken and Johnson, “Analysis of Messy Data”, Volume 1.
% Generate data in the structure of their Table 26.8 (but not their data)
% & compare the EMS table produced by anovan with that shown in their Table 26.9

% Trials = TrialFrame({'R','Sex','Clothing','Time','Environment'},[3 2 2 3 3],'Between',{'Sex'
% Example abandoned--too complex.
