%% sandbox for extending SubTableIndices to allow non-numeric CondSpecs

test = DemoData('Demo0');
test.catCond = categorical(test.Cond);
unique(test.catCond)
test.iCond = grp2idx(test.catCond);

test.sCond = repmat({'cond'},height(test),1);

for iRow=1:height(test)
    if test.Cond(iRow)==1
        test.sCond{iRow} = 'cond1';
    elseif test.Cond(iRow)==2
        test.sCond{iRow} = 'cond2';
    elseif test.Cond(iRow)==3
        test.sCond{iRow} = 'cond3';
    end
end

% CondMeans(test,'RT','iCond')
CondMeans(test,'RT','Cond')

CondMeans(test,'RT','Cor')
% CondMeans(test,'RT','catCond')

CondMeans(test,'RT',{'Blk','sCond'})

CondMeans(test,'RT',{'Blk','Cond'})

% Find the variable number of each CondSpec variable
% Find its variable type
% If it is a cell variable, make a new categorical variable to represent it   with categorical
%   BE CAREFUL ABOUT THE ORDER OF CATEGORIES
% If it is a categorical variable, make a new numeric variable to represent it  with grp2idx
%   BE CAREFUL ABOUT THE ORDER OF CATEGORIES
% Use the index variable as the temporary condspec

% find out the class of each variable with output as a vector of cells.
% varfun(@class,test,'OutputFormat','cell')


% test.sCond(test.Cond==2) = 'cond2';
% test.sCond(test.Cond==3) = 'cond3';
% 
% test.sCond(test.Cond==1) = repmat('cond1',sum(test.Cond==1),1);


return

%% sandbox for DemoFitTruncPMLE

DistObj = ExGauMn(400,40,200);
LowerTruncP = 0.03;
UpperTruncP = 0.97;
DistToFit = TruncatedP(DistObj,LowerTruncP,UpperTruncP,'FixedCutoffLow','FixedCutoffHi');
DistToFit.PlotDens
DistToFit.ParmValues
DistToFit.NDistParms
DistToFit.DefaultParmCodes
