function [outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,FunHandleCellArray,varargin)
% Call each of the functions in FunHandleCellArray on each DV in sDVs for all combinations
%   of the conditions indicated by CondSpecs.
% Notes:
%   Each function receives a list of the numbers for one DV.
%   All functions must take the same arguments.
%   Each function FunHandle can produce a vector of k outputs.
% These will be stored as outResultTable.DVFun(iCond,1:k).
%
% Optional arguments:
%   Include/Exclude options passed through to SubTableIndices.
%   'SaveNaNs' indicates that the output should include rows for which all computed values are NaNs.
%             By default these all-NaN rows are deleted.
%   'ShortNames' indicates that the names of the output variables should be the same as
%                the names of the input variables, _without_ appending the function name.

[sDVs, NDVs] = EnsureCell(sDVs);

[FunHandleCellArray, NFuns] = EnsureCell(FunHandleCellArray);

[SaveNaNs, varargin] = ExtractNamei('SaveNaNs',varargin);
DropNaNs = ~SaveNaNs;

[ShortNames, varargin] = ExtractNamei('ShortNames',varargin);

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
outDVNames = cell(NDVs,NFuns);
for iDV=1:NDVs
    siDV = sDVs{iDV};
    for iFun=1:NFuns
        if ~ShortNames
            siDVj = [siDV '_' func2str(FunHandleCellArray{iFun})];
        else
            siDVj = siDV;
        end
        outDVNames{iDV,iFun} = UniqueVarname(outResultTable,siDVj);
    end
end

NaNIndices = [];  % Keep a list of any rows that have all NaNs.

for iCond = 1:NConds
    OneSubTable = inTrials(mySubTableIndices{iCond},:);
    NaNCtr = 0;
    for iDV=1:NDVs
        OneDV = OneSubTable.(sDVs{iDV});
        for iFun=1:NFuns
            OneResult = FunHandleCellArray{iFun}(OneDV,PassThruArgs{:});
            if iCond==1
                outResultTable.(outDVNames{iDV,iFun}) = NaN(NConds,numel(OneResult));
            end
            outResultTable.(outDVNames{iDV,iFun})(iCond,:) = OneResult;
            if sum(isnan(OneResult)) == numel(OneResult)
                NaNCtr = NaNCtr + 1;
            end
        end
    end
    if NaNCtr == NDVs*NFuns
       NaNIndices = [NaNIndices iCond];
    end
end

if DropNaNs
   outResultTable(NaNIndices,:) = [];
end

outDVNames = reshape(outDVNames,[1 NDVs*NFuns]);

end
