function outtbl = stackvec(intbl,sDV)
% sDV is a string name of column of intbl that contains a vector of N elements for each row.
% outtbl has N times as many rows.
% in outtbl, the sDV column has a single number.
% outtbl also has an additional column called sDV_N with values of 1, 2, 3, .. N
% indicating each sDV's position within the intbl vector.

%[sDV, NDVs] = EnsureCell(sDV);
%sDV = sDV{1};

tmp = intbl.(sDV);  % hold the value of vec
intbl.(sDV) = [];

N = size(tmp,2);

outtbl = table;
for iRow=1:height(intbl)
    for j=1:N
        outtbl = [outtbl; intbl(iRow,:)];
    end
end

sDVlbl = [sDV '_N'];
labels = (1:N);
labels = repmat(labels,1,height(intbl));
outtbl.(sDVlbl) = labels';

tmp = tmp';  % reorder so that vector element changes faster than row.
outtbl.(sDV) = tmp(:);

end
