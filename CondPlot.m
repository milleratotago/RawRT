function figout = CondPlot(Trials, DVs, CondSpecs, varargin)
% Plot the indicated yDV as a function of the indicated xDV for each of the combinations
%  of indicated specifications.
% If only one DV is listed, it is the yDV and the xDV is the first of the CondSpecs.
% If two DVs are listed, they are the xDV and yDV, respectively.
% CondSpecs is a string or cell array containing up to 3 strings.
%    The first Spec indicates the values to be used on the X-axis.
%    The 2nd and 3rd CondSpecs indicate the values to be used across rows and columns of the subplots.
%
% Optional input arguments that can appear in any order:
%
%   Include/Exclude selection criteria as usual
%
%   'DefaultAxesFontSize',DefaultAxesFontSize: Standard MATLAB figure parameter (default value shown in ExtractNameVali)
%
%   'DefaultTextFontsize',DefaultTextFontsize: Standard MATLAB figure parameter (default value shown in ExtractNameVali)
%
%   'DefaultLineLineWidth',DefaultLineLineWidth: Standard MATLAB figure parameter (default value shown in ExtractNameVali)
%
%   'DefaultAxesLineWidth',DefaultAxesLineWidth: Standard MATLAB figure parameter (default value shown in ExtractNameVali)
%
%   'Figure',FigParms:  FigParms is a cell array of parameters passed to the figure command. e.g., {'Position',[10 10 200 200]}
%
%   'Function',ThisFun: A function handle indicating what function to compute, if not the mean.
%       The plotted x & y values are summarized with this function over any specifications NOT listed in CondSpecs (this is done in ExtractAsArray).
%       The default function is the mean, if no function is specified.
%
%   'Labels',Struc: Struc is a structure with one field for each CondSpec. Each field is a cell array of k positions,
%             where k is the number of unique values for that CondSpec. Struc.CondNameArray{i} is the name for that
%             level of the CondSpec.
%             Example: Suppose one of the CondSpecs is 'Practice', with 3 levels.
%             Then the structure would have a field like Struc.Practice = {'Early', 'Middle', 'Late'} naming the three levels of practice.
%
%   'LineTypes',CellArray: CellArray is a list of strings indicating the line types for the successive lines within a plot
%                          (see sLineTypes for the default examples).
%
%   'NoLinkAxes' : By default the axes of multiple subplots are linked (i.e., have the same ranges).
%                  Use this option to let each subplot have its own range.
%
%   'SaveFile',FileName:  Name of a file name to save the plot (e.g., 'ThisPlot.jpg').
%
%   'XEdge',Proportion: Proportion is the proportion of the X axis that is unused at each side of the graph.
%             Note that the default proportion is >0 because I like gaps at the left & right edges of the plots.
%
%   'YLabel',sYLabel: sYLabel is a string used to label the Y axis.  Otherwise, it is labelled 'function(yDV)'
%
% The output is a figure handle

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

sLineTypes = {'-ok', '--ok', ':ok', '-.ok', '-sk', '--sk', ':sk', '-.sk'};  % NewJeff: Crude default

[DefaultAxesFontSize, varargin] = ExtractNameVali('DefaultAxesFontSize',14,varargin);
[DefaultTextFontsize, varargin] = ExtractNameVali('DefaultTextFontsize',12,varargin);
[DefaultLineLineWidth, varargin] = ExtractNameVali('DefaultLineLineWidth',1.5,varargin);
[DefaultAxesLineWidth, varargin] = ExtractNameVali('DefaultAxesLineWidth',1.25,varargin);
[FigParms, varargin] = ExtractNameVali('Figure',{},varargin);
[ThisFun, varargin] = ExtractNameVali('Function',@mean,varargin);
[Labels, varargin] = ExtractNameVali('Labels',0,varargin);
[sLineTypes, varargin] = ExtractNameVali('LineTypes',sLineTypes,varargin);
[NoLinkAxes, varargin] = ExtractNamei('NoLinkAxes',varargin);
[FigName, varargin] = ExtractNameVali('SaveFile','',varargin);
[XEdge, varargin] = ExtractNameVali('XEdge',0.15,varargin);
[sYLabel, varargin] = ExtractNameVali('YLabel','',varargin);

LinkAxes = ~NoLinkAxes;

assert((XEdge>=0)&(XEdge<=0.4),'XEdge must be between 0 and 0.4');  % 0.5 would allocate the whole axis to the gaps!


UseLabels = isstruct(Labels);
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

if numel(sYLabel)==0
   sFunc = func2str(ThisFun);
   sYLabel = [sFunc '(' yDV ')'];
end

figout = figure(FigParms{:});
set(figout,'DefaultAxesFontSize',DefaultAxesFontSize);
set(figout,'DefaultTextFontsize',DefaultTextFontsize);
set(figout,'DefaultLineLineWidth',DefaultLineLineWidth);
set(figout,'DefaultAxesLineWidth',DefaultAxesLineWidth);

TheseX = ExtractAsArray(Trials,{xDV},CondSpecs);  % This array can have more than 2 dimensions, which plot cannot handle.
TheseY = ExtractAsArray(Trials,{yDV},CondSpecs,'Function',ThisFun,varargin{:});  % This array can have more than 2 dimensions, which plot cannot handle.
iPlot = 0;
xmins = zeros(NLines,1);  % Keep track of min & max X's across all lines
xmaxs = zeros(NLines,1);
for iRow=1:NRows
    for iCol=1:NCols
        iPlot = iPlot + 1;
        oneplot(iPlot) = subplot(NRows,NCols,iPlot);%#ok<AGROW>
        for iLine=1:NLines
            if nDim >= LineDim
                if UseLabels && isfield(Labels,CondSpecs{LineDim})
                    sLineName = Labels.(CondSpecs{LineDim}){iLine};
                else
                    sLineName = [CondSpecs{LineDim} ' ' num2str(Values{LineDim}(iLine))];
                end
            else
                sLineName = '';
            end
            switch NSpecs
                case {1}
                    Xs = TheseX(:);
                    Ys = TheseY(:);
                case {2}
                    Xs = TheseX(:,iLine);
                    Ys = TheseY(:,iLine);
                case 3
                    Xs = TheseX(:,iLine,iRow);
                    Ys = TheseY(:,iLine,iRow);
                case 4
                    Xs = TheseX(:,iLine,iRow,iCol);
                    Ys = TheseY(:,iLine,iRow,iCol);
            end
            plot(Xs,Ys,sLineTypes{iLine},'DisplayName',sLineName);
            if iLine==1
                hold on;
            end
            xmins(iLine) = min(Xs);
            xmaxs(iLine) = max(Xs);
        end  % iLine
        ax = gca;  % Get the axis info
        if XEdge>0
            xlims = [min(xmins) max(xmaxs)];
            xwidth = xlims(2) - xlims(1);
            ax.XLim(1) = xlims(1) - XEdge*xwidth;
            ax.XLim(2) = xlims(2) + XEdge*xwidth;
        end
        % ax.XTick = Xs;  % This just uses the Xs from the last line.
        if UseLabels && isfield(Labels,CondSpecs{1})
            ax.XTickLabel = Labels.(CondSpecs{1});
        end
        ylabel(sYLabel);
        if iRow==NRows
            xlabel(strrep(xDV,'_',' '));
        end
        if NLines > 1
            legend('Location','Best'); % Auto
            legend('boxoff');
        end
        % Maybe add a title to the panel if there are multiple subplots
        if NCols > 1
            if UseLabels && isfield(Labels,CondSpecs{ColDim})
                sTitle = Labels.(CondSpecs{ColDim}){iCol};
            else
                sTitle = [CondSpecs{ColDim} ' ' num2str(Values{ColDim}(iCol))];
            end
        else
            sTitle = '';
        end
        if NRows > 1
            if numel(sTitle) > 0
                sTitle = [sTitle '; '];%#ok<AGROW>
            end
            if UseLabels && isfield(Labels,CondSpecs{RowDim})
                sTitle2 = Labels.(CondSpecs{RowDim}){iRow};
            else
                sTitle2 = [CondSpecs{RowDim} ' ' num2str(Values{RowDim}(iRow))];
            end
            sTitle = [sTitle sTitle2];%#ok<AGROW>
        end
        if numel(sTitle) > 0
            title(sTitle);
        end
    end
end
if LinkAxes
    linkaxes(oneplot(:),'xy');
end
drawnow;

if numel(FigName)>0
    saveas(figout,FigName);
end

end
