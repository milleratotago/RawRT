function Trials = ReadTrialsTable(SubList,FNamePat,varargin)
% Function to read the trials from a set of data files, one file per subject.
%
% Required input variables:
%   SubList: a list of integers corresponding to the subject numbers (e.g., 1:20).
%   FNamePat: a string pattern used with sprintf to specify how to generate the file name from the subject number
%      Example: FNamePat='M1701-%03d.txt' will generate file names like M1701-001.txt,  M1701-012.txt,  M1701-103.txt
%               for subject numbers 1-999.
%
% Optional input variables are all passed to MATLAB's readtable function. E.g.:
%  'ReadVariableNames',true: First line of each file has the variable names.
%  'HeaderLines',N: Number of header lines to skip at the beginning of each file.

Trials = table;
nSubs = 0;
for iSub=SubList
   % SubStr = num2str(iSub,'%03d');
   % fileName = ['M1701-' SubStr '.txt'];
   fileName = sprintf(FNamePat,iSub);
   try
       T1 = readtable(fileName,varargin{:}); % 'ReadVariableNames',true,'HeaderLines',NHeaderLines);
       Trials = [Trials; T1];
       nSubs = nSubs + 1;
   catch
       fprintf('Unable to read data for subject %d.\n',iSub);
   end
end

fprintf('Found %d trials for %d subjects.\n',height(Trials),nSubs);

end
