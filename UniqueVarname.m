function s = UniqueVarname(inTable,varargin)
% Extend the input string in varargin (if necessary) until it does not match any
% variable name string already in the input table.

if numel(varargin) > 0
   s = varargin{1};
else
   s = 'tmp';
end
ctr = 1;
while isTableVarname(s,inTable)
  ctr = ctr+1;
  s = [s num2str(ctr)];
end
