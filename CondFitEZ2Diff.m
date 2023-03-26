function [outResultTable, outDVNames] = CondFitEZ2Diff(inTrials,sRT,CondSpecs,varargin)
    % For each combination of CondSpecs, fit the EZ2-Diffusion model using all rows with that combination.
    % This function fits the version of Grasman, Wagenmakers, & van der Maas (2009). doi: 10.1016/j.jmp.2009.01.006
    % Note that CORRECT RESPONSES & ERRORS should be included when fitting this model.
    %
    % Optional arguments:
    %   Include/Exclude options passed through to SubTableIndices.
    %   sCor: name of a 0/1 variable coding correct responses (1 = correct). Default is 'Cor'
    %   UnitsPerSec: time scaling factor on sRT variable; Default is 1000, for RTs in milliseconds.
    %                Example: If times were measured in seconds, use:   'UnitsPerSec',1
    %
    
    [sCor, varargin] = ExtractNameVali('sCor','Cor',varargin);  % Get the name of the 0/1 variable holding PC
    [UnitsPerSec, varargin] = ExtractNameVali('UnitsPerSec',1000,varargin);  % Number of sRT units per second. Default sRT unit is msec.
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);

    NOutDVs = 4;
    
    outDVNames = cell(NOutDVs,1);
    outDVNames{1} = UniqueVarname(outResultTable,'EZ2Diff_v');
    outDVNames{2} = UniqueVarname(outResultTable,'EZ2Diff_z');
    outDVNames{3} = UniqueVarname(outResultTable,'EZ2Diff_a');
    outDVNames{4} = UniqueVarname(outResultTable,'EZ2Diff_Ter');

    for iDV=1:NOutDVs
        outResultTable.(outDVNames{iDV}) = zeros(NConds,1);
    end
    
    for iCond = 1:NConds
        OneSubTable = inTrials(mySubTableIndices{iCond},:);
        OneSubTable.(sRT) = OneSubTable.(sRT) / UnitsPerSec;   % convert to secs as assumed by EZ2.Fit.
        Pc = mean(OneSubTable.(sCor));
        % Edge correction for Pc:
        if Pc == 1
            Pc = 1 - 1/height(OneSubTable);
        elseif Pc == 0
            Pc = 1/height(OneSubTable);
%         elseif Pc == 0.5
%             assert(false,'Unknown "edge correction" needed here.'); % NWJEFF
        end
        VRT = var(OneSubTable.(sRT));
        MRT = mean(OneSubTable.(sRT));
        Correct = OneSubTable.(sCor)==1;
        CorVRT = var(OneSubTable.(sRT)(Correct));
        CorMRT = mean(OneSubTable.(sRT)(Correct));
        [v,z,a,Ter] = EZ2.Fit(CorMRT, CorVRT, MRT, VRT, 1-Pc);
        outResultTable.(outDVNames{1})(iCond) = v;
        outResultTable.(outDVNames{2})(iCond) = z;
        outResultTable.(outDVNames{3})(iCond) = a;
        outResultTable.(outDVNames{4})(iCond) = Ter;
    end
    
end


