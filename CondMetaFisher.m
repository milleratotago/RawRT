function [outResultTable, outDVName] = CondMetaFisher(inTrials,sDV,CondSpecs,varargin)
    % Compute meta-analyses using Fisher's test.
    % Each row in the input table is assumed to correspond to one independent
    %  one-tailed test of a H0 (e.g., for separate participants).
    % sDV is the name of a variable that holds the one-tailed attained p values
    %  resulting from these tests.
    % CondSpecs defines different combinations of conditions whose H0 testing
    %  results are to be meta-analyzed separately.
    %
    % Optional argument e.g. 'alpha',0.025 gives significance level for checking proportion
    % of single results that are significant.
    % 
    % Output table has rows for CondSpecs combinations and columns for:
    %   meta-analysis summaries: 'FisherSum', 'Ttldf', 'AttainedP', and
    %   'PrSig' = proportion of individual-test results significant at alpha level
    
    
    [alpha, varargin] = ExtractNameVali('alpha',0.05,varargin);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(outResultTable);
    
    old_df = 1;
    chisq = ChiSq(old_df);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        ps = inTrials.(sDV)(Indices);
        F = -2*sum(log(ps));
        df = 2*numel(ps);
        if df ~= old_df
            chisq.ResetParms(df);
            old_df = df;
        end
        AttainedP = 1 - chisq.CDF(F);
        outResultTable.FisherSum(iCond) = F;
        outResultTable.Ttldf(iCond) = df;
        outResultTable.AttainedP(iCond) = AttainedP;
        outResultTable.PrSig(iCond) = mean(ps<alpha);
    end
    
    outDVName = {'FisherSum', 'Ttldf', 'AttainedP', 'PrSig'};
    
end % CondMetaFisher

