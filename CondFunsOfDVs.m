function [outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,FunHandleCellArray,varargin)
    % Call each of the functions in FunHandleCellArray on each DV in sDVs for all combinations
    %   of the conditions indicated by CondSpecs.
    % outResultTable has one row for each combination of conditions in CondSpecs.  Its variables are:
    %   One variable to indicate the value of each CondSpec.
    %   One set of variables for each combination of SDV & FunHandleCellArray.  This set contains one variable for each function output.
    % Assumptions/restrictions:
    %   o Each function must take as its first argument a vector of the data values for one DV.
    %   o Each function must take the the same additional arguments (PassThru arguments).
    %   o Each function must produce the same number of outputs (NoutVars) with the same structure (e.g., output 1 a scaler, output 2 a 10-item vector, etc).
    %     The different outputs of each function will be stored as outResultTable.DVFun(iCond,1:k).
    %   o DropOuts, if used, refers to the outputs of all functions (e.g., you must drop the same outputs from each function).
    %     If DropOuts has fewer booleans than the number of outputs produced, the additional outputs are NOT kept.
    %
    % Optional arguments:
    %   Include/Exclude options passed through to SubTableIndices.
    %   'SaveNaNs' indicates that the output should include rows for which all computed values are NaNs.
    %             By default these all-NaN rows are deleted.
    %   'ShortNames' indicates that the names of the output variables should be the same as
    %                the names of the input variables, _without_ appending the function name.
    %                This parameter is ignored if there are multiple functions because that would lead to variable name clashes.
    %   'outDVNames' is a cell array of output names for the computed functions (useful with anonymous fns)
    %              outDVNames _must_ be a 3D array of size (NDVs,NFuns,NoutVarsToKeep)
    %   'DropOutputs' is an array of booleans, 1..nOutVars, where true in position i indicates that the i'th output cell should be dropped.
    %   'NPassThru': Number of additional arguments to be passed through to the function, followed by those arguments as successive paramters. E.g.
    %          CondCenMoment uses  CondFunsOfDVs(inTrials,sDVs,CondSpecs,@obscenmoment,'NPassThru',1,NMoment);
    
    [CondSpecs, NCondSpecs] = EnsureCell(CondSpecs);
    [sDVs, NDVs] = EnsureCell(sDVs);
    
    [FunHandleCellArray, NFuns] = EnsureCell(FunHandleCellArray);
    
    NoutVarsPerFun = nargout(FunHandleCellArray{1});  % Assume without checking that all functions produce the same number of outputs.
    NoutVarsPerFun = abs(NoutVarsPerFun);  % Cluge because nargout returns negative value if varargout specified in function
    NoutVars = NoutVarsPerFun*NDVs*NFuns;
    
    [SaveNaNs, varargin] = ExtractNamei('SaveNaNs',varargin);
    
    [ShortNames, varargin] = ExtractNamei('ShortNames',varargin);
    if NFuns > 1
        ShortNames = false;
    end
    
    [outDVNames, varargin] = ExtractNameVali('outDVNames',{},varargin);

    [DropOutputs, varargin] = ExtractNameVali('DropOutputs',false(1,NoutVarsPerFun),varargin);

    [NPassThru, varargin, FirstPassThruArgPos] = ExtractNameVali('NPassThru',0,varargin);  % Save NPassThru arguments for passing to FunHandle
    if NPassThru>0
        PassThruArgs = varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1);
        varargin(FirstPassThruArgPos:FirstPassThruArgPos+NPassThru-1) = [];
    else
        PassThruArgs = {};
    end
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    NoutVarsToKeepPerFun = NoutVarsPerFun - sum(DropOutputs);
    
    % Make names for computed columns in output table if they were not already specified:
    if numel(outDVNames)==0
        outDVNames = cell(NDVs,NFuns,NoutVarsPerFun);
        for iDV=1:NDVs
            siDV = sDVs{iDV};
            for iFun=1:NFuns
                for iOutVar=1:NoutVarsToKeepPerFun
                    if NoutVarsPerFun>1
                        sVar = ['_' num2str(iOutVar)];
                    else
                        sVar = '';
                    end
                    if ~ShortNames
                        siDVj = [siDV '_' func2strmod(FunHandleCellArray{iFun}) sVar];
                    else
                        siDVj = [siDV sVar];
                    end
                    siDVj = matlab.lang.makeValidName(siDVj);  % Make sure it is a valid MATLAB variable name.
                    outDVNames{iDV,iFun,iOutVar} = UniqueVarname(outResultTable,siDVj);
                end % for iOutVar
            end % for iFun
        end % for iDV
    end
    
    OneResult = cell(1,NoutVarsPerFun);  % Make a cell array to hold the output of each function temporarily
    
    for iCond = 1:NConds   % parfor not allowed here because of OneResult and outResultTable
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        for iDV=1:NDVs
            OneDV = OneSubTable.(sDVs{iDV});
            for iFun=1:NFuns
                [OneResult{:}] = FunHandleCellArray{iFun}(OneDV,PassThruArgs{:});
                OneResultToKeep = OneResult(~DropOutputs);
                for iOutVar=1:min(NoutVarsToKeepPerFun,numel(OneResultToKeep))
                    if iCond==1
                        outResultTable.(outDVNames{iDV,iFun,iOutVar}) = NaN(NConds,numel(OneResultToKeep{iOutVar}));
                    end
                    outResultTable.(outDVNames{iDV,iFun,iOutVar})(iCond,:) = OneResultToKeep{iOutVar};
                end % for iOutVar
            end % for iFun
        end % for iDV
    end % for iCond
    
    if ~SaveNaNs
        DVIndices = NCondSpecs+1:width(outResultTable);  % Initial output table variables are CondSpecs & the rest are DVs.
        NaNRowIndices = TableFindNaNRows(outResultTable,DVIndices);
        outResultTable(NaNRowIndices,:) = [];
    end
    
    % There is a condition variable called All, even if there are no CondSpecs.
    outDVNames = outResultTable.Properties.VariableNames(max(NCondSpecs,1)+1:end);
    
end
