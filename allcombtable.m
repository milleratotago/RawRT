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
    % For input types 2 & 3, the optional parameter 'unique' specifies
    % that only unique values of the fields/variables should be considered.
    
    [WantUnique, varargin] = ExtractNamei('unique',varargin);
    structortable = isstruct(varargin{1}) || istable(varargin{1});
    
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
        
    else
        a = allcomb(varargin{:});
        theTable = array2table(a);
        
        varnames = cell(1,nargin);
        for ivar=1:nargin
            varnames{ivar} = inputname(ivar);
            if numel(varnames{ivar})==0
                varnames{ivar} = ['var' num2str(ivar)];  % a default name
            end
        end
        theTable.Properties.VariableNames = varnames;
        
    end % if
    
end

