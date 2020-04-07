function [outResultTable, outDVNames] = CondFunsOfTrials(inTrials,CondSpecs,FunHandleCellArray,varargin)
% Call each of the functions in FunHandleCellArray on each subset of trials for all combinations
%   of the conditions indicated by CondSpecs, passing the optional arguments in varargin.
% Notes:
%   Each function receives the whole table so it can compute a function of multiple DVs
%     DV names or numbers (these can be passed as arguments).
%   All functions must take the same arguments.
%   Each function FunHandle can produce a vector of k outputs.
%
% Optional arguments:
%   Include/Exclude options passed through to SubTableIndices.
%   'SaveNaNs' indicates that the output should include rows for which all computed values are NaNs.
%             By default these all-NaN rows are deleted.

[FunHandleCellArray, NFuns] = EnsureCell(FunHandleCellArray);

[SaveNaNs, varargin] = ExtractNamei('SaveNaNs',varargin);
DropNaNs = ~SaveNaNs;

[NPassThru, varargin, FirstPassThruArgPos] = ExtractNameVali('NPassThru',0,varargin);  % Save NPassThru arguments for passing to FunHandle
if NPassThru>0
    PassThruArgs = varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1);
    varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1) = [];
else
    PassThruArgs = {};
end

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

% Make names for computed columns in output table:
outDVNames = cell(1,NFuns);
for iFun=1:NFuns
    outDVNames{iFun} = UniqueVarname(outResultTable,func2strmod(FunHandleCellArray{iFun}));
end

NaNIndices = [];  % Keep a list of any rows that have all NaNs.

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    NaNCtr = 0;
    for iFun=1:NFuns
        if height(OneSubTable)==0  % NEWJEFF
            disp('Error in CondFunsOfTrials: No lines in table.')
            pause
        end
        OneResult = FunHandleCellArray{iFun}(OneSubTable,PassThruArgs{:});
        if iCond==1
            outResultTable.(outDVNames{iFun}) = NaN(NConds,numel(OneResult));
% Slower using SingleResults!
%           SingleResults = NaN(NConds,numel(OneResult));
        end
        outResultTable.(outDVNames{iFun})(iCond,:) = OneResult;
%       SingleResults(iCond,:) = OneResult;
        if sum(isnan(OneResult)) == numel(OneResult)
            NaNCtr = NaNCtr + 1;
        end
    if NaNCtr == NFuns
       NaNIndices = [NaNIndices iCond];
    end
    end
end

% outResultTable.(outDVNames{iFun}) = SingleResults;

end
