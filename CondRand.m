function outDV = CondRand(inTrials,CondSpecs,RV,varargin)
% Generates a new random value of RV for each combination of CondSpecs
% and return the result as the output DV.
% This function can be used to build up simulated scores for ANOVA; you must
% call it once for each component going into the score.

[AutoCenter, varargin] = ExtractNamei('AutoCenter',varargin);

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDV = NaN(height(inTrials),1);

for iCond = 1:NConds
    outDV(mySubTableIndices{iCond}) = RV.Random;
end

if AutoCenter
    sUniqueName = UniqueVarname(inTrials,'uahjf');
    inTrials.(sUniqueName) = outDV;
    outDV = CondCenter(inTrials,sUniqueName,CondSpecs,varargin);
end

end
