function outTable = AddTableVars(inTable,initval,varargin)
% Add additional variables with the indicated names, all initialized
% to initval.

outTable = inTable;
nrows = height(inTable);
initvar = repmat(initval,nrows,1);

for inewcol=1:numel(varargin)
    varname = varargin{inewcol};
    outTable.(varname) = initvar;
end

end
