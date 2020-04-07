function out = minNAN4empty(data)
    if numel(data)>0
        out = min(data);
    else
        out = NaN;
    end
end
