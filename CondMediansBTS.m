function [outResultTable, outDVNames] = CondMediansBTS(inTrials,sDVs,CondSpecs,nBoot,varargin)
    % Bootstrap-corrected median
    % Include/Exclude options passed through to SubTableIndices.
    % Note that bootstrapping uses its own separate random number stream, so it is not replicable.
    
    % [outResultTable, outDVNames] = CondFunsOfDVs(inTrials,sDVs,CondSpecs,@median,varargin{:});
    
    [sDVs, NDVs] = EnsureCell(sDVs);
    
    [ShortNames, varargin] = ExtractNamei('ShortNames',varargin);
    
    [outDVNames, varargin] = ExtractNameVali('outDVNames',{},varargin);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    % Make names for computed columns in output table if they were not already specified:
    if numel(outDVNames)==0
        outDVNames = cell(NDVs,1);
        for iDV=1:NDVs
            siDV = sDVs{iDV};
            if ~ShortNames
                siDVj = [siDV '_median'];
            else
                siDVj = siDV;
            end
            outDVNames{iDV} = UniqueVarname(outResultTable,siDVj);
        end
    end
    
    BootOptions = statset('Streams',RandStream('mt19937ar'));
    
    for iDV=1:NDVs
        outResultTable.(outDVNames{iDV}) = NaN(NConds,1);
    end

    for iCond = 1:NConds
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        for iDV=1:NDVs
            OneDV = OneSubTable.(sDVs{iDV});
            OneResult = mediancorrected(OneDV,nBoot,BootOptions);
            outResultTable.(outDVNames{iDV})(iCond) = OneResult;
        end
    end
    
    outDVNames = strcat(outDVNames,'BTS');
    
end  % CondMediansBTS

function final = mediancorrected(obs,nBoot,BootOptions)
    initial = median(obs);
    BootMedians = bootstrp(nBoot,@median,obs,'Options',BootOptions);
    BootMean = mean(BootMedians);
    final = 2 * initial - BootMean;
end
