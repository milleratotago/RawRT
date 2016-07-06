function tf = isTableVarname(s,inTable)
% Return true iff s is the name of a variable in inTable.

tf = true;

for iVar = 1:width(inTable)
   if strcmp(s,inTable.Properties.VariableNames{iVar})
      return;
   end
end

tf = false;

end

