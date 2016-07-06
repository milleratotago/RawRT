function [figout, hist] = FreqDist(Trials, sDV, varargin)

[figout, hist] = CondFreqDist(Trials, sDV, {}, varargin{:});

end

