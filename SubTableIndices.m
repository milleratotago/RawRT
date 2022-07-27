function [outIndices, outCondLabels] = SubTableIndices(Trials,CondSpecs,varargin)
    %
    % Find the indicated subset of trials for each combination of the conditions indicated by CondSpecs.
    % CondSpecs variables can be numeric or logical.
    %
    % NConds subsets will be found, where NConds is the number of different combinations of CondSpecs.
    % Note that some subsets may be empty if not all combinations of CondSpecs are present.
    %
    % outIndices is a cell array of NConds cells. Each cell contains a 1-dimensional
    %  array of integers indicating the row outIndices within the input array Trials
    %  of the different trials included in the iCond'th subset.
    %
    % outCondLabels is a table with NConds rows and NCondSpecs columns showing
    %  the combination of the NCondSpecs conditions for each of the NConds subsets.
    %
    % Optional arguments:
    %   Include/Exclude selection criteria.
    %   sortOrder: a cell array of strings, one per CondSpec, indicating whether you want
    %     the unique values sorted (option 'sorted') or in their original order (option 'stable')
    %     By default, sortOrder is stable for string values and sorted for all others
    
    % Each CondSpec variable must be one of these types:
    eEquals = 1;  % Compare two values with ==
    eFloat  = 2;  % Compare two values with abs(difference)
    eStrcmp = 3;  % Compare two values with strcmpi
    
    [IncludeIndicators, outArg] = ExtractNameVali({'Include','IncludeOnly'},ones(height(Trials),1),varargin);
    
    [ExcludeIndicators, outArg] = ExtractNameVali({'Exclude','ExcludeOnly'},zeros(height(Trials),1),outArg);

    [sortOrder, outArg] = ExtractNameVali('sortOrder',[],outArg);
    sortOrderDefault = numel(sortOrder) == 0;
        
    if numel(CondSpecs)==0
        % Include all selected trials in a single condition called 'All'.
        NConds = 1;
        outIndices = cell(NConds,1);
        outIndices{1} = find(IncludeIndicators&~ExcludeIndicators);
        tempoutCondLabels.All = ones(NConds,1);
        outCondLabels = struct2table(tempoutCondLabels);
        return
    end
    
    [CondSpecs, NCondSpecs] = EnsureCell(CondSpecs);
    
    WantTrials = IncludeIndicators & ~ExcludeIndicators;
    
    SpecLabels = cell(NCondSpecs,1);  % Each cell will hold a list of the unique values of one CondSpec in sorted or stable order
    SpecTypes = zeros(NCondSpecs,1);  % Each value is one of the comparison types, eEquals, eStrcmp, etc
    NLabelsInSpec = zeros(NCondSpecs,1);  % The number of unique values of each label.
    IdxList = cell(NCondSpecs,1); % Each cell will be 1:NLabelsInSpec to pass to ndgrid
    sortOrder = cell(NCondSpecs,1); % Each cell will be 'sorted' or 'stable' to pass to unique
    for iSpec=1:NCondSpecs
        firstWantedLoc = find(WantTrials,1);
        checkdata = Trials.(CondSpecs{iSpec})(firstWantedLoc);
        if iscell(checkdata)
            checkdata = checkdata{1};
        end
        if islogical(checkdata) || isinteger(checkdata) || iscategorical(checkdata)
            SpecTypes(iSpec) = eEquals;
            if sortOrderDefault
                sortOrder{iSpec} = 'sorted';
            end
        elseif isnumeric(checkdata)
            SpecTypes(iSpec) = eFloat;
            if sortOrderDefault
                sortOrder{iSpec} = 'sorted';
            end
        elseif ischar(checkdata)
            SpecTypes(iSpec) = eStrcmp;
            if sortOrderDefault
                sortOrder{iSpec} = 'stable';
            end
        else
            error(['Unrecognized type of data in ' CondSpecs{iSpec}]);
        end
        SpecLabels{iSpec} = unique(Trials.(CondSpecs{iSpec})(WantTrials),sortOrder{iSpec});
        NLabelsInSpec(iSpec) = numel(SpecLabels{iSpec});
        IdxList{iSpec} = 1:NLabelsInSpec(iSpec);
    end
    
    IdxGrid = allcomb(IdxList{:});
    NConds = size(IdxGrid,1);
    CondCombos = cell(NConds,NCondSpecs);
    for iCond = 1:NConds
        for iSpec=1:NCondSpecs
            CondCombos{iCond,iSpec} = SpecLabels{iSpec}(IdxGrid(iCond,iSpec));
        end
    end
    
%     [NConds, NSpecs, ~, ~, CondCombos, ~ ] = CondList(Trials(IncludeIndicators&~ExcludeIndicators,:),CondSpecs);
    
    % Make columns to hold the condition labels:
%    for iSpec=1:NCondSpecs
%        tempoutCondLabels.(CondSpecs{iSpec}) = zeros(NConds,1);
%    end
%      tempoutCondLabels = cell(NConds,NCondSpecs);
    
    % Make a cell array to hold the outIndices:
    outIndices = cell(NConds,1);
    
    for iCond=1:NConds
        
        % Identify this condition in terms of its combination of CondSpecs, and save the values
        % of these specifications as named fields in the tempoutCondLabels structure.
        WantTrials = IncludeIndicators & ~ExcludeIndicators;
        for iSpec=1:NCondSpecs
            switch SpecTypes(iSpec)
                case eEquals
                    ThisSpecOK = Trials.(CondSpecs{iSpec}) == CondCombos{iCond,iSpec};
                case eStrcmp
                    ThisSpecOK = strcmp(Trials.(CondSpecs{iSpec}),CondCombos{iCond,iSpec});
                case eFloat
                    ThisSpecOK = abs(Trials.(CondSpecs{iSpec}) - CondCombos{iCond,iSpec}) <= eps;
                otherwise
                    error('Unrecognized CondSpec variable comparison type');
            end % switch
            WantTrials = WantTrials & ThisSpecOK;
%             tempoutCondLabels.(CondSpecs{iSpec})(iCond) = CondCombos(iCond,iSpec);
        end
        outIndices{iCond} = find(WantTrials);
    end
    
%     outCondLabels = struct2table(tempoutCondLabels);
outCondLabels = cell2table(CondCombos);
outCondLabels.Properties.VariableNames = CondSpecs;
    
end
