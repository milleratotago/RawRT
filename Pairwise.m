function [outResultTable, outDVNames] = Pairwise(inTable,sDV,sFactor,sSubNo)
    % Compute all possible pairwise t-tests comparing different levels of
    % the factor sFactor on the DV sDV.  sSubNo is the label of the
    % random "subjects" factor in inTable.
    % If there are multiple lines in inTable for a given combination of
    % sFactor & sSubNo, use the average value of sDV across those lines.
    
    Means2Use = CondMeans(inTable,sDV,{sFactor, sSubNo});
    FactorLevels = unique(Means2Use.(sFactor));
    AllPairs = nchoosek(FactorLevels,2);
    NPairs = size(AllPairs,1);
    
    % Make tables to hold the output;
    outResultTable = table(AllPairs(:,1),AllPairs(:,2));
    outResultTable.Properties.VariableNames = {[sFactor '1'] [sFactor '2']};
    
    NDVsOut = 7;
    outDVNames = cell(NDVsOut,1);
    outDVNames{1} = UniqueVarname(outResultTable,'h');
    outDVNames{2} = UniqueVarname(outResultTable,'p');
    outDVNames{3} = UniqueVarname(outResultTable,'LowerCI');
    outDVNames{4} = UniqueVarname(outResultTable,'UpperCI');
    outDVNames{5} = UniqueVarname(outResultTable,'t');
    outDVNames{6} = UniqueVarname(outResultTable,'df');
    outDVNames{7} = UniqueVarname(outResultTable,'sd');
    
    for iDV=1:NDVsOut
        outResultTable.(outDVNames{iDV}) = zeros(NPairs,1);
    end
    
    % Determine whether sFactor is between-Ss or within-Ss:
    counts = crosstab(Means2Use.(sSubNo),Means2Use.(sFactor));
    Between = sum(counts(:)==0)>0;
    
    for iPair = 1:NPairs
        x = Means2Use.(sDV)(Means2Use.(sFactor)==AllPairs(iPair,1));
        y = Means2Use.(sDV)(Means2Use.(sFactor)==AllPairs(iPair,2));
        if Between
            [h,p,ci,stats] = ttest2(x,y);
        else
            [h,p,ci,stats] = ttest(x,y);
        end
        outResultTable.(outDVNames{1})(iPair) = h;
        outResultTable.(outDVNames{2})(iPair) = p;
        outResultTable.(outDVNames{3})(iPair) = ci(1);
        outResultTable.(outDVNames{4})(iPair) = ci(2);
        outResultTable.(outDVNames{5})(iPair) = stats.tstat;
        outResultTable.(outDVNames{6})(iPair) = stats.df;
        outResultTable.(outDVNames{7})(iPair) = stats.sd;
    end
    
end
