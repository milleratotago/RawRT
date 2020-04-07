function stable2 = FormatAnovanTable(tabletosave,varargin)
% Format an anovan output table to a cell array of strings.
% Optional inputs:
%   'DPs',[3 2 3 3]    Set n of decimal places for SS, MS, F, p

[DPs, varargin] = ExtractNameVali('DPs',[2 3 3 3],varargin);

% Omit the singular column
tabletosave(:,4)= [];
[nrows,ncols]= size(tabletosave);

ColFormat = cell(6,1);
ColFormat{1} = '';        % Unused
ColFormat{2} = ['%0.' num2str(DPs(1)) 'f'];   % Sum Sq uses DPs(1)
ColFormat{3} = '%i';      % df
ColFormat{4} = ['%0.' num2str(DPs(2)) 'f'];   % Mean Sq uses DPs(2)
ColFormat{5} = ['%0.' num2str(DPs(3)) 'f'];   % F uses DPs(3)
ColFormat{6} = ['%0.' num2str(DPs(4)) 'f'];   % p uses DPs(4)

% stable will be a 2D cell array whose cells are all strings.
stable=cell(size(tabletosave));

% Copy the first row and column strings from the input table.
stable(1,:) = tabletosave(1,:);
stable(:,1) = tabletosave(:,1);

% Copy SS's and MS's as strings with 5 dps.
for iCol=2:6
   for iRow=2:nrows
       if numel(tabletosave{iRow,iCol}) == 1
          stable{iRow,iCol} = sprintf(ColFormat{iCol},tabletosave{iRow,iCol});
       else
          stable{iRow,iCol} = '';
       end
   end
end

% Find the longest item in each column:
CellWidths = cellfun(@length,stable);
ColMax = max(CellWidths,[],1);

% Pad each cell out to the max width for its column.
for iCol=1:ncols
    if iCol == 1
        sDirec = 'right';
    else
        sDirec = 'left';
    end
    for iRow=1:nrows
        stable{iRow,iCol} = pad(stable{iRow,iCol},ColMax(iCol),sDirec);
    end
end

% Concatenate the strings within each single row.
stable2 = cell(nrows,1);
for iRow=1:nrows
    stable2{iRow} = sprintf('%s  ',stable{iRow,:});
end

% Make a separator line of dashes and insert it
dashline = blanks(length(stable2{1}));
dashline(:) = '-';
stable2 = [stable2(1); dashline; stable2(2:end)];

end


% The pad function will be added by MATLAB in 2016b but I need it in 2015b :(
% So here is a budget version:
function news = pad(s,wantlen,direc)
slen = length(s);
if slen>=wantlen
    news = s;
    return;
end
pads = blanks(wantlen-slen);
if strcmpi(direc,'left')
    news = [pads s];
else
    news = [s pads];
end
end
