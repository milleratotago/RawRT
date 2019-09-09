function Trials = ReadCSVTrialsTable(FNamePat,varargin)
    % Function to read the trials from a set of CSV data files, one file per subject.
    %
    % Required input variables:
    %   FNamePat: a string pattern used with dir to get the names of the csv files, e.g. 'Expt*.csv'.
    %
    % Optional input variables:
    %   'AddSubNo' : Add a subject number variable
    %
    % Other optional input variables are all passed to MATLAB's readtable function. E.g.:
    %  'ReadVariableNames',true: First line of each file has the variable names.
    %  'HeaderLines',N: Number of header lines to skip at the beginning of each file.
    %
    % PROBLEMS: Path name must not contain spaces.
    
    [AddSubNo, varargin] = ExtractNamei('AddSubNo',varargin);
    csvFiles = dir(FNamePat);
    
    Trials = table;
    nSubs = 0;
    for iSub=1:numel(csvFiles)
        fileName = [csvFiles(iSub).folder '\' csvFiles(iSub).name];
        try
            T1 = readtable(fileName,varargin{:}); % 'ReadVariableNames',true,'HeaderLines',NHeaderLines);
            if AddSubNo
                T1.SubNo = iSub*ones(height(T1),1);
            end
            try
                Trials = [Trials; T1]; %#ok<AGROW>
                nSubs = nSubs + 1;
            catch
                fprintf('Mismatching variable names for subject %d.\n',iSub);
                fprintf('Previous variable names:');
                fprintf(' %s',Trials.Properties.VariableNames{:});
                fprintf('\n');
                fprintf('Variable names for subject %d:',iSub);
                fprintf(' %s',T1.Properties.VariableNames{:});
                fprintf('\n');
            end
        catch
            fprintf('Unable to read data for subject %d.\n',iSub);
        end
    end
    
    fprintf('Found %d trials for %d subjects.\n',height(Trials),nSubs);
    
end
