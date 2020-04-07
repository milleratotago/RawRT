function [ theTable ] = allcombtable( varargin )
    % Create a table with one row for each combination of the input variables.
    %
    % Input type 1: a list of variables:
    % The number of variables in the table is the same as the number of input variables,
    % and the names of the table variables are the same as the names of the input variables.
    %
    % Example:
    %   V1=[1:3];
    %   V2=[1:2];
    %   tbl = allcombtable(V1,V2)
    % tbl =
    %     V1    V2
    %     __    __
    %     1     1
    %     1     2
    %     2     1
    %     2     2
    %     3     1
    %     3     2
    %
    %
    % Input type 2: a structure and a cell array of field names:
    %
    % Example:
    %   parms is a structure with fields .N and .P (among others)
    %   tbl = allcombtable(parms,{'N','P'})
    % tbl will have columns N and P and rows with all possible combinations
    %   of the values of N and P
    %
    %
    % Input type 3: a table and a cell array of variable names:
    %
    % Example:
    %   parms is a table with variables N and P (among others)
    %   tbl = allcombtable(parms,{'N','P'})
    % tbl will have columns N and P and rows with all possible combinations
    %   of the values of N and P
    %
    % For input types 2 & 3, the optional parameter 'unique' specifies that
    % only unique values of the fields/variables should be considered.
    %
    % Input type 4: a list of tables:
    %   Limitation: The tables must have distinct variable names.
    %
    % Example:
    %   t1 is a table with 2 rows & 4 columns.
    %   t2 is a table with 5 rows & 3 columns.
    %   tbl = allcombtable(t1,t2)
    % tbl will have 2*5=10 rows and 4+3= 7 columns.
    %   The first 5 rows of tbl will have values from t1, row 1 in the first 4 columns
    %   and it will have values from t2, rows 1-5 in the next 3 columns.
    %   The next 5 rows of tbl will have values from t1, row 2 in cols 1-4
    %   followed by values from t2 rows 1-5 in the next 3 columns.
    
    [WantUnique, varargin] = ExtractNamei('unique',varargin);
    [NewVariableNames, varargin] = ExtractNameVali('VariableNames',{},varargin);
    structortable = (isstruct(varargin{1}) || istable(varargin{1})) && iscell(varargin{2});

    % Check for case 4
    alltables = true;
    for iarg=1:numel(varargin)
        alltables = alltables && istable(varargin{iarg});
    end
    
    if (numel(varargin)==2) && structortable
        % Case 2 or 3
        instruct = varargin{1};
        fields = varargin{2};
        vars = cell(numel(fields),1);
        for i=1:numel(fields)
           vars{i} = deal(instruct.(fields{i}));
           if WantUnique
               vars{i} = unique(vars{i});
           end
        end
        a = allcomb(vars{:});
        theTable = array2table(a);
        theTable.Properties.VariableNames = fields;
        
    elseif alltables
        % Case 4: all arguments are tables.
        % Create a new table with all combinations of their rows.
        nInputTbls = numel(varargin);
        inRowCounts = zeros(nInputTbls,1);
        inColCounts = zeros(nInputTbls,1);
        inPtrs = cell(nInputTbls,1);
%         AllvarTypes = cell(1,0);
        AllVarNames = cell(1,0);
        for iInput=1:nInputTbls
            inRowCounts(iInput) = height(varargin{iInput});
            inColCounts(iInput) = width(varargin{iInput});
            inPtrs{iInput} = 1:inRowCounts(iInput);
            AllVarNames = [AllVarNames varargin{iInput}.Properties.VariableNames]; %#ok<AGROW>
%             AllvarTypes = [AllvarTypes varfun(@class,varargin{iInput},'OutputFormat','cell')]; %#ok<AGROW>
        end
        NoutCols = sum(inColCounts);
        NoutRows = prod(inRowCounts);
        a = allcomb(inPtrs{:});
        % The next line doesn't work until R2019b, so cluge
        % with a cell array converted at the end (see below).
        % theTable = table('Size',[NoutRows NoutCols],'VariableTypes',AllvarTypes);
        theTable = cell(NoutRows,NoutCols);
        UsedCols = 0;
        for iInput=1:nInputTbls
            t = varargin{iInput};
            for iInCol=1:inColCounts(iInput)
                iOutCol = iInCol + UsedCols;
                iInRows = a(:,iInput);
                iOutRows = (1:NoutRows)';
                if iscell(t.(iInCol)(1))
                    tmp = t.(iInCol)(iInRows);
                else
                    tmp = num2cell(t.(iInCol)(iInRows));
                end
                [theTable{iOutRows,iOutCol}] = tmp{:};
%                for iOutRow=1:NoutRows
%                    iInRow = a(iOutRow,iInput);
%%                    theTable{iOutRow,iOutCol} = t{iInRow,iInCol};
%                    theTable{iOutRow,iOutCol} = t.(iInCol)(iInRow);
%%                    theTable.(iOutCol)(iOutRow) = t.(iInCol)(iInRow);  % This doesn't work because theTable is not really a table yet.
%                end
            end
            UsedCols = UsedCols + inColCounts(iInput);
        end
        theTable = cell2table(theTable);  % Cluge
        theTable.Properties.VariableNames = AllVarNames;

    else
        % Case 1
        a = allcomb(varargin{:});
        theTable = array2table(a);
        nvars = width(theTable);
        varnames = cell(1,nvars);
        for ivar=1:nvars
            varnames{ivar} = inputname(ivar);
            if numel(varnames{ivar})==0
                varnames{ivar} = ['var' num2str(ivar)];  % a default name
            end
        end
        theTable.Properties.VariableNames = varnames;
        
    end % if

if numel(NewVariableNames) > 0
    theTable.Properties.VariableNames = NewVariableNames;
end
    
end

