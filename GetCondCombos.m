function [Sizes, Values]=GetCondCombos(Trials,ConditionDistinguished)
% Compute a list of the number of possible values for each condition spec.
% Trials is a structure
% ConditionDistinguished is a cell array of field names within the structure.
% The output Sizes(i) = number of different values of field ConditionDistinguished{i} within trials.
% Values(i) is a cell array containing a list of the unique values.
ConditionDistinguished = EnsureCell(ConditionDistinguished);
ndims = numel(ConditionDistinguished);
Sizes=zeros(1,ndims);
Values=cell(1,ndims);
for i=1:ndims
%    ConditionDistinguished{i}
%    Trials.Properties.VariableNames
    try
       Values{i}=unique(Trials.(ConditionDistinguished{i}));
    catch
        NameNotFound = ConditionDistinguished{i}
        NameClass = class(NameNotFound)
        assert(false,[NameNotFound ' is not a legal variable name string.']);
    end
    Sizes(i)=numel(Values{i});
end
end
