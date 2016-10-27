function varargout = ExtractAsArray(Trials,sDV,CondSpecs,varargin)
% Extract each indicated sDV to a separate matrix with dimensions indicated by the CondSpecs,
% averaging over all values fitting any combination of the designated CondSpecs.
% Optional arguments:
%   Include/Exclude
%   Function: A function handle indicating what function to compute, if not the mean.
% Problem: If each value of sDV is itself a vector (e.g., Prctiles), then only the first element is returned.

[Trials, varargin] = MaybeSelect(Trials,varargin{:});

[ThisFun, varargin] = ExtractNameVali('Function',@mean,varargin);

assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

[sDV, nDVs] = EnsureCell(sDV);
[CondSpecs, nDim] = EnsureCell(CondSpecs);

[NConds, ~, Sizes, ~, CondCombos, Indices] = CondList(Trials,CondSpecs);

if nDim==1
    Result = zeros(1,Sizes);
else
    Result = zeros(Sizes);
end

for iDV = 1:nDVs
    
    for iCond=1:NConds
        for iDim=1:nDim
            ThisSpec = ['Trials.' CondSpecs{iDim} '==' num2str(CondCombos(iCond,iDim))];
            if iDim == 1
                sTarg = ThisSpec;
            else
                sTarg = [sTarg '&' ThisSpec];%#ok<AGROW>
            end
        end
        if nDim==1
            RsltIndx = iCond;
        else
            RsltIndx = subv2ind(size(Result),Indices(iCond,:));
        end
        Result(RsltIndx) = ThisFun(Trials.(sDV{iDV})(eval(sTarg)));   % Summarize over ignored specs if multiple values are returned.
        %     Result(Indices(iCond,:)) = Trials.(sDV{iDV})(eval(sTarg));
    end
    
    varargout{iDV} = Result;%#ok<AGROW>
    
end

end
