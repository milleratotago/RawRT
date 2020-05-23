function [outResultTable, sBinLabel] = CondBinMeans(Trials,sAssign,sCompute,CondSpecs,NBins,varargin)
    % Compute the mean scores on the DV sCompute with bins defined by trials rank order
    %  on the DV sAssign.  Use the method of Ratcliff (1979) to handle numbers of trials that are
    %  not an even multiple of the number of bins.
    % Required arguments
    %   Trials: data table
    %   sAssign  : name of the RT variable used to assign trials to bins
    %   sCompute : name of the dependent variable used to measure the condition effect (usually RT or Cor)
    %   CondSpecs: Label(s) defining the conditions to be kept separate during computation.
    %              For example, one CondSpec would be 'SubNo' if the computations were to be done separately for each subject.
    %   NBins: The number of bins to use in dividing up RT values.
    % Optional arguments:
    %   Include/Exclude: passed through to CondBinLabels and CondMeans
    %   'NoStack': Don't stack the output table--that is, output table variables will be vectors of bin means.
    %
    % Outputs:
    %   BinMeans  : A table of the mean values of the DV and the RT, separately for each combination of CondSpecs, sDiffSpec, & Bin.
    
    [NoStack, varargin] = ExtractNamei({'NoStack','SkipStack'},varargin);
    WantStack = ~NoStack;
    
    [mySubTableIndices, outResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});
    
    NConds = height(outResultTable);
    
    TwoOutputScores = ~strcmp(sAssign,sCompute);
    
    outResultTable.(sAssign) = zeros(NConds,NBins);
    if TwoOutputScores
        outResultTable.(sCompute) = zeros(NConds,NBins);
    end
    
    for iCond = 1:NConds
        
        Indices = mySubTableIndices{iCond};
        NTrials = numel(Indices);
        
        if NTrials<NBins
            error(['Cannot distinguish ' num2str(NBins) ' bins with only ' num2str(NTrials) ' trials.']);
        end
        
        AssignVals = Trials.(sAssign)(Indices);
        % Make NBins copies of the values so that the full lists are even multiples of NBins
        AssignVals  = repmat(AssignVals,NBins,1);
        [AssignVals, oldIndices] = sort(AssignVals);

        if TwoOutputScores
            ComputeVals = Trials.(sCompute)(Indices);
            ComputeVals = repmat(ComputeVals,NBins,1);
            ComputeVals = ComputeVals(oldIndices);   % Carry along the computed values in the same pattern as for the sort.
        end
        
        % Vals array(s) now NTrials*NBins in length & sorted.
        
        % Average the first NTrials scores as the bin 1 average,
        %  the next NTrials scores as the bin 2 average, etc.
        Upper = 0;
        for iBin = 1:NBins
            Lower = Upper + 1;
            Upper = Lower + NTrials - 1;
            outResultTable.(sAssign)(iCond,iBin)  = mean(AssignVals(Lower:Upper));
            if TwoOutputScores
                outResultTable.(sCompute)(iCond,iBin) = mean(ComputeVals(Lower:Upper));
            end
        end
        
    end  % for iCond
    
    if WantStack
        if TwoOutputScores
            outResultTable = stackvec(outResultTable,{sAssign, sCompute});
        else
            outResultTable = stackvec(outResultTable,sAssign);
        end
        sBinLabel = [sAssign '_Bin'];
        outResultTable.Properties.VariableNames{[sAssign '_N']} = sBinLabel;
    else
        sBinLabel = '';
    end

end  % CondBinMeans
