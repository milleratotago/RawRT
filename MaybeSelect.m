function [outTrials, outArg] = MaybeSelect(inTrials,varargin)
% Create a desired output set of trials from the input set of trials,
% with varargin's used to identify which trials should be included or excluded.
% If specified, the IncludeIndicators and ExcludeIndicators should be vectors
% of 1's and 0's, one per trial.
% IncludeIndictor: 0 = exclude, 1 = include
% ExcludeIndictor: 0 = include, 1 = exclude
% If both are specified, the trial must be indicated as include on both.

[IncludeIndicators, outArg] = ExtractNameVali('Include',ones(height(inTrials),1),varargin);

[ExcludeIndicators, outArg] = ExtractNameVali('Exclude',zeros(height(inTrials),1),outArg);

NRowsInTrials = height(inTrials);
NInclude = numel(IncludeIndicators);
NExclude = numel(ExcludeIndicators);

assert(NInclude == NRowsInTrials, ErrMsg('In',NInclude));
assert(NExclude == NRowsInTrials, ErrMsg('Ex',NExclude));

outTrials = inTrials(IncludeIndicators&~ExcludeIndicators,:);

    function outS = ErrMsg(inS,N)
        outS = sprintf('ERROR: Your input Trials table has %d rows,\nbut your %sclude selector variable has %d rows.\nThe numbers of rows must be equal.\n',NRowsInTrials,inS,N);
    end

end

