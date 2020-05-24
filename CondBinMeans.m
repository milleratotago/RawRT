function [outResultTable, sBinLabel] = CondBinMeans(Trials,sDV,CondSpecs,NBins,varargin)
    % Compute the mean scores on the indicated DVs with bins defined by trials rank ordered
    %  on the first (or only DV).  Use the method of Ratcliff (1979, p. 449) to handle
    %  numbers of trials that are not an even multiple of the number of bins.
    % Required arguments
    %   Trials: data table
    %   sDV      : name or cell array of DVs for which means should be computed.
    %              If multiple DVs are specified, the first is the one used to assign trials to bins.
    %   CondSpecs: Label(s) defining the conditions to be kept separate during computation.
    %              For example, one CondSpec would be 'SubNo' if the computations were to be done separately for each subject.
    %   NBins: The number of bins to use in dividing up RT values.
    % Optional arguments:
    %   Include/Exclude: passed through to CondBinLabels and CondMeans
    %   'NoStack': Don't stack the output table--that is, output table variables will be vectors of bin means.
    %              If this is not specified, the output table will be 'stacked'--i.e., different bins on different lines.
    %
    % Outputs:
    %   BinMeans  : A table of the mean values of the DV and the RT, separately for each combination of CondSpecs, sDiffSpec, & Bin.
    
    [NoStack, varargin] = ExtractNamei({'NoStack','SkipStack'},varargin);
    WantStack = ~NoStack;
    [sDV, NDVs] = EnsureCell(sDV);
    
    [mySubTableIndices, outResultTable] = SubTableIndices(Trials,CondSpecs,varargin{:});
    
    NConds = height(outResultTable);
    
    for iDV=1:NDVs
        outResultTable.(sDV{iDV}) = zeros(NConds,NBins);
    end
    
    sAssign = sDV{1};

    ValsDVs = cell(NDVs,1);

    for iCond = 1:NConds
        
        Indices = mySubTableIndices{iCond};
        NTrials = numel(Indices);
        
        if NTrials<NBins
            error(['Cannot distinguish ' num2str(NBins) ' bins with only ' num2str(NTrials) ' trials.']);
        end

        for iDV = 1:NDVs
            ValsDVs{iDV} = Trials.(sDV{iDV})(Indices);
            % Make NBins copies of the values so that the full lists are even multiples of NBins.
            ValsDVs{iDV}  = repmat(ValsDVs{iDV},NBins,1);
        end

        [ValsDVs{1}, oldIndices] = sort(ValsDVs{1});

        for iDV = 2:NDVs
            ValsDVs{iDV} = ValsDVs{iDV}(oldIndices);   % Carry along the computed values in the same pattern as for the DV 1.
        end
        
        % ValsDVs array(s) are now NTrials*NBins in length & sorted according to DV 1.
        
        % Average the first NTrials scores as the bin 1 average,
        %  the next NTrials scores as the bin 2 average, etc.
        Upper = 0;
        for iBin = 1:NBins
            Lower = Upper + 1;
            Upper = Lower + NTrials - 1;
            for iDV=1:NDVs
                outResultTable.(sDV{iDV})(iCond,iBin)  = mean(ValsDVs{iDV}(Lower:Upper));
            end
        end
        
    end  % for iCond
    
    if WantStack
        outResultTable = stackvec(outResultTable,sDV);
        sBinLabel = [sAssign '_Bin'];
        outResultTable.Properties.VariableNames{[sAssign '_N']} = sBinLabel;
    else
        sBinLabel = '';  % Define a null return value.
    end

end  % CondBinMeans
