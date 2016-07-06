function figout = CondPlot(Trials, DVs, CondSpecs, varargin)
% Plot the indicated yDV as a function of the indicated xDV for each of the combinations
%  of indicated specifications.
% If only one DV is listed, it is the yDV and the xDV is the first of the CondSpecs.
% If two DVs are listed, they are the xDV and yDV, respectively.
% CondSpecs is a string or cell array containing up to 3 strings.
%    The first Spec indicates the values to be used on the X-axis.
%    The 2nd and 3rd CondSpecs indicate the values to be used across rows and columns of the subplots.
% Optional input arguments that can appear in any order:
%   Include/Exclude selection criteria
%   ThisFun: A function handle indicating what function to compute, if not the mean.
%   'Figure',FigParms:  FigParms is a cell array of parameters passed to the figure command. e.g., {'Position',[10 10 200 200]}
% The output is a figure handle
% The plotted x & y values are averaged over any specifications NOT listed in CondSpecs (this is done in ExtractAsArray).

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

[ThisFun, varargin] = ExtractNameVali('Function',@mean,varargin);
[FigParms, varargin] = ExtractNameVali('Figure',{},varargin);

[CondSpecs, nDim] = EnsureCell(CondSpecs);

if iscell(DVs)
    if (numel(DVs)>1)
        xDV = DVs{1};
        yDV = DVs{2};
    else
        xDV = CondSpecs{1};
        yDV = DVs{1};
    end
else
    xDV = CondSpecs{1};
    yDV = DVs;
end

[~, NSpecs, Sizes, Values, ~, ~ ] = CondList(Trials,CondSpecs);

assert(NSpecs>0&&NSpecs<=4,'CondPlot must have 1-4 condition specifications.');

LineDim = 2;
RowDim = 3;
ColDim = 4;

if NSpecs>=LineDim
    NLines = Sizes(LineDim);
else
    NLines = 1;
end
if NSpecs>=RowDim
    NRows = Sizes(RowDim);
else
    NRows = 1;
end
if NSpecs>=ColDim
    NCols = Sizes(ColDim);
else
    NCols = 1;
end

sFunc = func2str(ThisFun);

figout = figure(FigParms{:});
TheseX = ExtractAsArray(Trials,{xDV},CondSpecs);  % This array can have more than 2 dimensions, which plot cannot handle.
TheseY = ExtractAsArray(Trials,{yDV},CondSpecs,'Function',ThisFun,varargin{:});  % This array can have more than 2 dimensions, which plot cannot handle.
iPlot = 0;
for iRow=1:NRows
    for iCol=1:NCols
        iPlot = iPlot + 1;
        subplot(NRows,NCols,iPlot);
        for iLine=1:NLines
            if nDim >= LineDim
                sLineName = [CondSpecs{LineDim} ' ' num2str(Values{LineDim}(iLine))];
            else
                sLineName = '';
            end
            switch NSpecs
                case {1}
                    plot(TheseX(:),TheseY(:),'-o','DisplayName',sLineName);  % NewJeff: Use different symbols & line types
                 case {2}
                    plot(TheseX(:,iLine),TheseY(:,iLine),'-o','DisplayName',sLineName);  % NewJeff: Use different symbols & line types
               case 3
                    plot(TheseX(:,iLine,iRow),TheseY(:,iLine,iRow),'-o','DisplayName',sLineName);  % NewJeff: Use different symbols & line types
                case 4
                    plot(TheseX(:,iLine,iRow,iCol),TheseY(:,iLine,iRow,iCol),'-o','DisplayName',sLineName);  % NewJeff: Use different symbols & line types
            end
            if iLine==1
                hold on;
            end
        end
        ylabel([sFunc '(' yDV ')']);
        xlabel(xDV);
        if NLines > 1
            legend('Location','Best'); % Auto
            legend('boxoff');
        end
        % Maybe add a title to the panel if there are multiple subplots
        if NCols > 1
            sTitle = [CondSpecs{ColDim} ' ' num2str(Values{ColDim}(iCol))];
        else
            sTitle = '';
        end
        if NRows > 1
            if numel(sTitle) > 0
                sTitle = [sTitle '; '];%#ok<AGROW>
            end
            sTitle = [sTitle CondSpecs{RowDim} ' ' num2str(Values{RowDim}(iRow))];%#ok<AGROW>
        end
        if numel(sTitle) > 0
            title(sTitle);
        end
    end
end
drawnow;



end
