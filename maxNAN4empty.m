function out = maxNAN4empty(data)
    if numel(data)>0
        out = max(data);
    else
        out = NaN;
    end
end
