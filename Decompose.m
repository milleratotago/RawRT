function tbl = Decompose(FacLevels, Means, varargin)
% GLM decomposition for a given set of means.
% FacLevels specifies a fully-crossed factorial design, slowest to fastest moving across cells.
% If FacLevels includes a subjects factor, it must be within-Ss
% Optional varargin parameter is varnames

% Estimates are the multipliers of the constant and the effects-code dummy variables.
% SSs and dfs are the sums of squares and dfs for each source, including intercept.
% Note that these are the sums of squares across the whole decomposition matrix
% and thus depend on the number of cells in the design--not just the current factor.

NFactors = numel(FacLevels);
NMeans = numel(Means);
assert(NMeans==prod(FacLevels),'The number of means should equal the product of the numbers of factor levels.');

% Generate a matrix to label the factorial combinations for all conditions, including Ss & blocks
LevelLists = cell(NFactors,1);
for iFac=1:NFactors
    LevelLists{iFac} = 1:FacLevels(iFac);
end
AllCombos = allcomb(LevelLists{:});   % This has all combinations of factor combinations.

if numel(varargin)>0
    varnames = varargin{1};
else
    varnames = cell(1,NFactors);
    for iName=1:NFactors
        varnames(iName) = cellstr(char('A'+iName-1));
    end
end

[~, tbl, ~] = anovan(Means(1:end),AllCombos,'Model','full','varnames',varnames,'display','off');

% Add a row for Mu
tbl = [tbl(1,:); tbl];
tbl(2,1) = cellstr('Mu');
tbl{2,2} = NMeans * mean(Means(1:end))^2;  % SS
tbl{2,3} = 1;  % df
tbl{2,4} = 0;
tbl{2,5} = tbl{2,2};  % MS
[~,cols] = size(tbl);
for iCol=6:cols
    tbl{2,iCol} = [];
end
tbl{end,2} = tbl{end,2} + tbl{2,2};
tbl{end,3} = tbl{end,3} + 1;

end

