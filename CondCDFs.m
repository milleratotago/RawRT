function figout = CondPlotCDFs(Trials, DVs, CondSpecs, Prctiles, varargin)
% Plot the CDF of the indicated DV at the indicated Prctile points (0-1)
%  separately for each combination of indicated conditions.
% The vertical axis is cumulative probability (0-1) and the horizontal axis is the value of the DV.
% If 2+ DVs are listed, a separate figure is made for each DV.
% CondSpecs is a string or cell array containing up to 3 strings.
%    The first Spec indicates different conditions to be superimposed within a single panel.
%    The 2nd and 3rd CondSpecs indicate the values to be used across rows and columns of the subplots.
% Optional input arguments that can appear in any order:
%   Include/Exclude selection criteria
%   'Figure',FigParms:  FigParms is a cell array of parameters passed to the figure command. e.g., {'Position',[10 10 200 200]}
% The output is a figure handle
% The plotted CDF values are computed pooling over any specifications NOT listed in CondSpecs (this is done in ExtractAsArray).

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

[FigParms, varargin] = ExtractNameVali('Figure',{},varargin);

[CondSpecs, nDim] = EnsureCell(CondSpecs);

[DVs, nDVs] = EnsureCell(DVs);

[~, NSpecs, Sizes, Values, ~, ~ ] = CondList(Trials,CondSpecs);

assert(NSpecs>=0&&NSpecs<=3,'CondPlotCDFs must have 0-3 condition specifications.');

LineDim = 1;
RowDim = 2;
ColDim = 3;

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

for iFig=1:NDVs
figout(iFig) = figure(FigParms{:});
NEWJEFF: I AM HERE.  Can I USE ExtractAsArray with prctiles???
TheseX = ExtractAsArray(Trials,{xDV},CondSpecs);  % This array can have more than 2 dimensions, which plot cannot handle.
TheseY = Prctiles;
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
end % iFig loop

end
