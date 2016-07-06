function [figout, hist] = CondFreqDist(Trials, sDV, CondSpecs, varargin)
% Make frequency distribution plot(s) of the indicated DV(s)
% for each combination of the indicated specifications.
% CondSpecs is a string or cell array containing up to 2 strings
%    that define the rows and cols of the subplots.
% The plotted frequency distributions are pooled over any specifications NOT
% listed in CondSpecs (this is done in ExtractAsArray).
% Optional input argument:
%   Include/Exclude selection criteria
% The output is an array of figure handles

[SelectedTrials, varargin] = MaybeSelect(Trials,varargin{:});

[sDV, NDVs] = EnsureCell(sDV);

[CondSpecs, nDim] = EnsureCell(CondSpecs);

if nDim > 0
    [NConds, NSpecs, Sizes, Values, CondCombos, ~ ] = CondList(SelectedTrials,CondSpecs);
else
    NConds = 1;
    NSpecs = 0;
end

assert(NSpecs>=0&&NSpecs<=2,'FreqDistByCond must have 0-2 condition specifications.');

RowDim = 1;
ColDim = 2;

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

hist = cell(NRows,NCols,NDVs);

for iDV=1:NDVs
    figout(iDV) = figure;
    hold on;
    ThisDV = sDV{iDV};
    iPlot = 0;
    for iRow=1:NRows
        for iCol=1:NCols
            iPlot = iPlot + 1;
            subplot(NRows,NCols,iPlot);
            if NSpecs>=RowDim
                sSelect = ['SelectedTrials.' CondSpecs{1} '==' num2str(CondCombos(iPlot,1))];
            else
                sSelect = '1:height(SelectedTrials)';
            end
            if NSpecs>=ColDim
                sSelect = [sSelect '&' 'SelectedTrials.' CondSpecs{2} '==' num2str(CondCombos(iPlot,2))];
            end
            hist{iRow,iCol,iDV} = histogram(SelectedTrials.(ThisDV)(eval(sSelect)));
%             ylabel(yDV);
             xlabel(ThisDV);
            % Maybe add a title to the panel if there are multiple subplots
            if NCols > 1
                sTitle = [CondSpecs{ColDim} ' ' num2str(Values{ColDim}(iCol))];
            else
                sTitle = '';
            end
            if NRows > 1
                if numel(sTitle) > 0
                    sTitle = [sTitle '; '];
                end
                sTitle = [sTitle CondSpecs{RowDim} ' ' num2str(Values{RowDim}(iRow))];
            end
            if numel(sTitle) > 0
                title(sTitle);
            end
        end
    end
    drawnow;
end

end
