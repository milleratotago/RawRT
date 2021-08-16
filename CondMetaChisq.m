function [outResultTable, outDVName] = CondMetaChisq(inTrials,sChisqVal,sdfVal,CondSpecs,varargin)
    % Compute meta-analyses by combining independent observed values of Chi-square tests.
    % Each row in the input table is assumed to correspond to one independent
    %  one-tailed test of a H0 (e.g., for separate participants).
    % sChisqVal and sdfVal are the names of variables that hold the chi-square values
    %  resulting from these tests and their associated df's.
    % CondSpecs defines different combinations of conditions whose H0 testing
    %  results are to be meta-analyzed separately.
    %
    % Optional argument e.g. 'alpha',0.025 gives significance level for checking proportion
    % of single results that are significant.
    % 
    % Output table has rows for CondSpecs combinations and columns for:
    %   meta-analysis summaries: 'TtlChisq', 'Ttldf', 'AttainedP', and
    %   'PrSig' = proportion of individual-test results significant at alpha level
    
    [alpha, varargin] = ExtractNameVali('alpha',0.05,varargin);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    
    NConds = height(outResultTable);
    
    old_df = 1;
    chisq = ChiSq(old_df);
    
    for iCond = 1:NConds
        Indices = mySubTableIndices{iCond};
        TtlChisq = sum( inTrials.(sChisqVal)(Indices) );
        Ttldf = sum( inTrials.(sdfVal)(Indices) );
        if Ttldf ~= old_df
            chisq.ResetParms(Ttldf);
            old_df = Ttldf;
        end
        AttainedP = 1 - chisq.CDF(TtlChisq);
        outResultTable.TtlChisq(iCond) = TtlChisq;
        outResultTable.Ttldf(iCond) = Ttldf;
        outResultTable.AttainedP(iCond) = AttainedP;
        
        % Get attained p values for individual results and
        % see what proportion were significant.
        obschisqs = inTrials.(sChisqVal)(Indices);
        dfs = inTrials.(sdfVal)(Indices);
        attainedps = zeros(size(dfs));
        for i=1:numel(Indices)
            thisdf = dfs(i);
            if thisdf ~= old_df
                chisq.ResetParms(thisdf);
                old_df = thisdf;
            end
            attainedps(i) = 1 - chisq.CDF(obschisqs(i));
        end
        outResultTable.PrSig(iCond) = mean(attainedps<alpha);
    
    end % for iCond
    
    outDVName = {'TtlChisq', 'Ttldf', 'AttainedP', 'PrSig'};
    
end % CondMetaChisq

