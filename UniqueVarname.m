function s = UniqueVarname(inNames,varargin)
% This function returns a name that is _not_ already present in inNames.
%
% inNames can be either a table or a cell array of strings.  If it is a table,
%  its VariableNames are considered to be the inNames
%
% If varargin is included, it is taken as the initial part of the
% unique name.  It is extended (if necessary) until it does not match any
% variable name string already in the input list.

if istable(inNames)
    inNames = inNames.Properties.VariableNames;
end

if numel(varargin) > 0
   s = varargin{1};
else
   s = 'tmp';
end
ctr = 1;
while any(strcmp(s,inNames))
  ctr = ctr+1;
  s = [s num2str(ctr)];
end
