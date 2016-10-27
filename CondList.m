function [NConds, NDistinguished, Sizes, Values, CondCombos, Indices] = CondList(Trials,CondSpecs)
% Define the _combinations_ of conditions to be examined, as determined by the
%   to-be-distinguished labels.
% Inputs:
%   Trials: a "table" data set
%   CondSpecs: the names of the variables in the data set whose unique values are to be distinguished.
%     The different possible combinations of these unique values (some of which may be empty)
%     define the set of combinations to be examined.
% Outputs:
%   NConds: The total number of combinations.
%   NDistinguished: The number of variables on which distinctions are made.
%   Sizes: A 1-D array listing the number of different values found for each of the to-be-distinguished variables.
%   Values: 
%   CondCombos: A 2-D array of (NConds, NDistinguished).
%               CondCombos(iCond,:) is a list of the values of the distinguished variable associated with each combination.
%               That is, values of CondCombos(:,iDistinguished) are actual values in Trials of each variable.
%   Indices: Also a 2-D array of (NConds, NDistinguished).
%            Indices(iCond,:) is a list of the sequential numbers of values of the distinguished variable associated with each combination.
%            That is, values of Indices(:,iDistinguished) always go from 1...Sizes(iDistinguished)

[Sizes, Values] = GetCondCombos(Trials,CondSpecs);
% whos('Values')
% Drop missing conditions from Values list & reduce Sizes accordingly.
for iIdx=1:numel(Values)
    % if isnumeric(Values{iIdx})  % Can only eliminate unwanted values of numeric Values types--not strings
    a =  Values{iIdx};
    if numel(a) < numel( Values{iIdx} )
        Sizes(iIdx) = Sizes(iIdx) - 1;
        Values{iIdx} = a;
        % end  % end of if isnumeric()
    end
end
CondCombos = allcomb(Values{:});   % This has all combinations of the unique values for the different specifiers
[NConds, NDistinguished] = size(CondCombos);

Values2 = Values;   % Make a copy so I can overwrite each dimension with 1:NLevels
for iIdx=1:numel(Values2)
    Values2{iIdx} = 1:numel(Values2{iIdx});   % Overwrite the arbitrary values with 1:NLevels
end

Indices = allcomb(Values2{:});    % This has all combinations of the indices 1:NLevels
end

function [Sizes, Values]=GetCondCombos(Trials,ConditionDistinguished)
% Compute a list of the number of possible values for each condition spec.
% Trials is a structure
% ConditionDistinguished is a cell array of field names within the structure.
% The output Sizes(i) = number of different values of field ConditionDistinguished{i} within trials.
% Values(i) is a cell array containing a list of the unique values.
ndims = numel(ConditionDistinguished);
Sizes=zeros(1,ndims);
Values=cell(1,ndims);
for i=1:ndims
%    ConditionDistinguished{i}
%    Trials.Properties.VariableNames
    Values{i}=unique(Trials.(ConditionDistinguished{i}));
    Sizes(i)=numel(Values{i});
end
end
