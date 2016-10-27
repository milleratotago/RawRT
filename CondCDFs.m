function [CDFs, CDFsNames, figout] = CondCDFs(Trials, DVs, CondSpecs, VincentSpecs, Prctiles, varargin)
% Compute & optionally plot the CDF of the indicated DV at the indicated Prctile points (0-1),
%  separately for each combination of conditions indicated by CondSpecs.
% In addition, compute Vincentized averages across the labels shown in VincentSpecs (e.g., SubNo).
% The vertical axis is cumulative probability (0-1) and the horizontal axis is the value of the DV.
% If 2+ DVs are listed, a separate figure is made for each DV.
% CondSpecs is a string or cell array containing up to 3 strings.
%    The first Spec indicates different conditions to be superimposed within a single panel.
%    The 2nd and 3rd CondSpecs indicate the values to be used across rows and columns of the subplots.
% Optional input arguments that can appear in any order:
%   Include/Exclude selection criteria
%   'Plot': Make a plot
%   'FigParms',FigParms:  FigParms is a cell array of parameters passed to the figure command. e.g., {'Position',[10 10 200 200]}
% The computed CDF values are computed pooling over any specifications NOT listed in CondSpecs (this is done in ExtractAsArray).
% Output:
%    CDFs is a cell array.  Each cell is an array of Vincentized CDF values for one DV.
%    figout is a cell array of figure handles, one per DV

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

[FigParms, varargin] = ExtractNameVali('FigParms',{},varargin);

[WantPlot, varargin] = ExtractNamei('Plot',varargin);

[CondSpecs, nDim] = EnsureCell(CondSpecs);

[DVs, NDVs] = EnsureCell(DVs);

CDFs = cell(1,NDVs);
CDFsNames = cell(1,NDVs);

% [~, NSpecs, Sizes, Values, ~, ~ ] = CondList(Trials,CondSpecs);
if nDim > 0
    [NConds, NSpecs, Sizes, Values, CondCombos, ~ ] = CondList(Trials,CondSpecs);
else
    NConds = 1;
    NSpecs = 0;
end


assert(NSpecs>=0&&NSpecs<=3,'CondCDFs must have 0-3 condition specifications.');

if WantPlot
    figout = cell(1,NDVs);
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
else
    figout = [];
end;


for iDV=1:NDVs
    [PrctVals, PrctNames] = CondPrctiles(Trials,DVs{iDV},[CondSpecs VincentSpecs],Prctiles);
    [Vctiles, VctNames] = CondMeans(PrctVals,PrctNames,CondSpecs);
    CDFs{iDV} = Vctiles;
    CDFNames{iDV} = VctNames;
    if WantPlot
        figout{iDV} = figure(FigParms{:});
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
                        case {0}
                            TheseX = Vctiles.(VctNames{iDV})(:);
                            plot(TheseX,TheseY,'-o','DisplayName',sLineName);
                        case {1}
                            TheseX = Vctiles.(VctNames{iDV})(Vctiles.(CondSpecs{1})==Values{1}(iLine),:);
                            plot(TheseX,TheseY,'-o','DisplayName',sLineName);
                        case {2}
                            TheseX = Vctiles.(VctNames{iDV})(Vctiles.(CondSpecs{1})==Values{1}(iLine)&Vctiles.(CondSpecs{2})==Values{2}(iRow),:);
                            plot(TheseX,TheseY,'-o','DisplayName',sLineName);
                        case 3
                            TheseX = Vctiles.(VctNames{iDV})(Vctiles.(CondSpecs{1})==Values{1}(iLine)&Vctiles.(CondSpecs{2})==Values{2}(iRow)&Vctiles.(CondSpecs{3})==Values{3}(iCol),:);
                            plot(TheseX,TheseY,'-o','DisplayName',sLineName);
                    end
                    if iLine==1
                        hold on;
                    end
                end
                ylabel('Percentile');
                xlabel(DVs{iDV});
                if NLines > 1
                    legend('Location','SE'); % Auto
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
    end  % WantPlot
end % iDV loop

end
