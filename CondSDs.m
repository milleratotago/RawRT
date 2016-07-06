function [outResultTable, outDVNames] = CondSDs(inTrials,sDVs,CondSpecs,varargin)

[outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@std,varargin{:});

end
