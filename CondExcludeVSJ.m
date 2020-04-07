function [TooLo, TooHi] = CondExcludeVSJ(inTrials,sDV,CondSpecs,Method,varargin)
    % Compute a vector of scores indicating whether each trial in inTrials would be excluded
    % by one of the outlier-exclusion methods considered by Van Selst & Jolicoeur (1994).
    % Method is an integer 1-6 indicating which of their methods to use, as defined in the class VSJmnRTs.
    % sDV is a string name for the DV: only one is allowed.
    %
    % varargin options:
    %  initial 0-2: none, 'SD', or 'SD' and 'SD2', as needed by the specific method called (see class VSJmnRTs)
    %    remainder: Include/Exclude options passed through.
    %
    % Output vectors TooLo & TooHi:
    %   1 = Excluded
    %   0 = considered but not excluded
    %  -1 = not considered
    
    TooLo = -1*ones(height(inTrials),1);
    TooHi = -1*ones(height(inTrials),1);
    
    nVSJargs = VSJmnRTs.Props(Method).NParms;
    VSJargs = varargin(1:nVSJargs);
    OtherArgs = varargin(nVSJargs+1:end);
    
    [mySubTableIndices, CondLabels] = SubTableIndices(inTrials,CondSpecs,OtherArgs{:});
    
    NConds = height(CondLabels);
    
    nFnOutputs = VSJmnRTs.Props(Method).NOuts;
    mycell = cell(1,nFnOutputs);
    TooLoCellNo = VSJmnRTs.Props(Method).TooLoCell;
    TooHiCellNo = VSJmnRTs.Props(Method).TooHiCell;
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        OneDV = OneSubTable.(sDV);
        
        [mycell{:}] = VSJmnRTs.Props(Method).Func(OneDV,VSJargs{:});
        theseTooLo = mycell{TooLoCellNo};
        theseTooHi = mycell{TooHiCellNo};
        
        TooLo(Indices) = theseTooLo;
        TooHi(Indices) = theseTooHi;
    end
    
end % function
