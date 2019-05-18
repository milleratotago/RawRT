function [outResultTable, outDVNames] = CondFitEZDiff(inTrials,sRT,CondSpecs,varargin)
    % For each combination of CondSpecs, fit the EZ-Diffusion model using all rows with that combination.
    % Note that CORRECT RESPONSES & ERRORS should be included when fitting this model.
    %
    % Optional arguments:
    %   Include/Exclude options passed through to SubTableIndices.
    %   sCor: name of a 0/1 variable coding correct responses (1 = correct). Default is 'Cor'
    %   UnitsPerSec: time scaling factor on sRT variable; Default is 1000, for RTs in milliseconds.
    %                Example: If times were measured in seconds, use:   'UnitsPerSec',1
    %
    %
    
    [sCor, varargin] = ExtractNameVali('sCor','Cor',varargin);  % Get the name of the 0/1 variable holding PC
    [UnitsPerSec, varargin] = ExtractNameVali('UnitsPerSec',1000,varargin);  % Number of sRT units per second. Default sRT unit is msec.
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);
    
    NOutDVs = 4;
    
    outDVNames = cell(NOutDVs,1);
    outDVNames{1} = UniqueVarname(outResultTable,'EZDiff_v');
    outDVNames{2} = UniqueVarname(outResultTable,'EZDiff_a');
    outDVNames{3} = UniqueVarname(outResultTable,'EZDiff_Ter');
    outDVNames{4} = UniqueVarname(outResultTable,'EZDiff_DT');

    for iDV=1:NOutDVs
        outResultTable.(outDVNames{iDV}) = zeros(NConds,1);
    end
    
    for iCond = 1:NConds
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        Pc = mean(OneSubTable.(sCor));
        % Edge correction for Pc:
        if Pc == 1
            Pc = 1 - 1/height(OneSubTable);
        elseif Pc == 0
            Pc = 1/height(OneSubTable);
        elseif Pc == 0.5
            assert(false,'Unknown "edge correction" needed here.'); % NWJEFF
        end
        Correct = OneSubTable.(sCor)==1;
        VRT = var(OneSubTable.(sRT)(Correct)/UnitsPerSec);
        MRT = mean(OneSubTable.(sRT)(Correct)/UnitsPerSec);
        [v,a,Ter,DT] = EZDiff(Pc, VRT, MRT);
        outResultTable.(outDVNames{1})(iCond) = v;
        outResultTable.(outDVNames{2})(iCond) = a;
        outResultTable.(outDVNames{3})(iCond) = Ter;
        outResultTable.(outDVNames{4})(iCond) = DT;
    end
    
end


