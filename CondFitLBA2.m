function [outResultTable, outDVNames] = CondFitLBA2(inTrials,sRT,CondSpecs,pArray,varargin)
    % For each combination of CondSpecs, fit the 2-choice Linear Ballistic Accumulator model
    % using all rows with that combination.  Fitting is done with the routines
    % downloaded on 22 June 2018 from https://github.com/smfleming/LBA.
    % 
    % pArray is the vector of starting points for parameters to be estimated
    % pArray = [v A b-A t0 sv]
    % e.g., pArray = [0.8 300 150 0.4 200];
    %
    % Trials with both correct responses & errors should be included when fitting this model.
    %
    % Optional arguments:
    %   Include/Exclude options passed through to SubTableIndices.
    %   sCor: name of a 0/1 variable coding correct responses (1 = correct). Default is 'Cor'
    %   'SearchOptions',SO: SO is a MATLAB optimset structure passed through to fmincon
    
    [sCor, varargin] = ExtractNameVali('sCor','Cor',varargin);  % Get the name of the 0/1 variable holding PC
    [SearchOptions, varargin] = ExtractNameVali('SearchOptions',nan,varargin);
    if isnan(SearchOptions)
        SearchOptions = optimset('Display','none');  % Default search options.
    end
    SearchOptions = EnsureCell(SearchOptions);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(inTrials,CondSpecs,varargin{:});
    NConds = height(outResultTable);

    outDVNames = cell(6,1);
    outDVNames{1} = UniqueVarname(outResultTable,'LBA_v');
    outDVNames{2} = UniqueVarname(outResultTable,'LBA_A');
    outDVNames{3} = UniqueVarname(outResultTable,'LBA_bminusA');
    outDVNames{4} = UniqueVarname(outResultTable,'LBA_sv');
    outDVNames{5} = UniqueVarname(outResultTable,'LBA_t0');
    outDVNames{6} = UniqueVarname(outResultTable,'LBA_Best');
    NDVs = numel(outDVNames);

    for iDV = 1:NDVs
        outResultTable.(outDVNames{iDV}) = zeros(NConds,1);
    end;
    
    % Set up model --> structure containing information on which parameters to
    % share between conditions.  Here fit each condition separately, so:
    model.v = 1; model.A = 1; model.b = 1; model.sv = 1; model.t0 = 1;

    for iCond = 1:NConds

        OneSubTable = inTrials(mySubTableIndices{iCond},:);

        NTrials = height(OneSubTable);

        data.rt = OneSubTable.(sRT);  % RT in milliseconds
        data.cond = ones(1,NTrials);  % data.cond - condition vector (e.g. 1=easy, 2=hard)
        data.stim = ones(1,NTrials);  % Dummy stimulus code; must be 1's to match correct/error response codes.
        data.response = OneSubTable.(sCor); % response code 1=correct, 0 = error

        % Estimate:
        [params, LL] = LBA.mle(data, model, pArray, SearchOptions{:});

        % Save the parameter estimates & maximum likelihood value:
        for iParm=1:numel(params)
            outResultTable.(outDVNames{iParm})(iCond) = params(iParm);
        end
        outResultTable.(outDVNames{NDVs})(iCond) = -LL;  % LBA_Best

    end % for iCond
    
end


