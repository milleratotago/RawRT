function [outResultTable, outDVName] = CondMetaFisher(inTrials,sDV,CondSpecs,varargin)
    % Compute meta-analyses using Fisher's test.
    % Each row in the input table is assumed to correspond to one independent
    %  one-tailed test of a H0 (e.g., for separate participants).
    % sDV is the name of a variable that holds the one-tailed attained p values
    %  resulting from these tests.
    % CondSpecs defines different combinations of conditions whose H0 testing
    %  results are to be meta-analyzed separately.
    
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
    end
    
    outDVName = {'FisherSum', 'Ttldf', 'AttainedP'};
    
end % CondMetaFisher

