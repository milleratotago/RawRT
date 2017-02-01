function outDV = CondRand(inTrials,CondSpecs,RV,varargin)  % NEWJEFF: Not working--I think autocenter should happen elsehwere
% Generates a new random value of RV for each combination of CondSpecs
% and return the result as the output DV.
% This function can be used to build up simulated scores for ANOVA; you must
% call it once for each component going into the score.
% If the optional parameter AutoCenter is specified, the random values are
% shifted by an additive constant to make sure they sum to zero for
% each subset of all-but-one of the CondSpecs.

[AutoCenter, varargin] = ExtractNamei('AutoCenter',varargin);

[mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
NConds = height(outResultTable);

outDV = NaN(height(inTrials),1);

for iCond = 1:NConds
    outDV(mySubTableIndices{iCond}) = RV.Random;
end

if AutoCenter
    sUniqueName = UniqueVarname(inTrials,'uahjf');
    if iCond==1
        newjeff = outDV(mySubTableIndices{iCond})'
    end
    if AutoCenter
        SubTbl = inTrials(mySubTableIndices{iCond},:);
        SubTbl.(sUniqueName) = outDV(mySubTableIndices{iCond});
        for iDrop = 1:numel(CondSpecs)
            SubConds = {CondSpecs{1:iDrop-1} CondSpecs{iDrop+1:end}};
            SubTbl.(sUniqueName) = CondCenter(SubTbl,sUniqueName,SubConds);
        end
        outDV(mySubTableIndices{iCond}) = SubTbl.(sUniqueName);
        if iCond==NConds
            newjeff = outDV'
        end
    end  % AutoCenter
    
end

end
