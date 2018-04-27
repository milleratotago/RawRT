function [ theTable ] = allcombtable( varargin )
% Create a table with one row for each combination of the input variables.
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

end

