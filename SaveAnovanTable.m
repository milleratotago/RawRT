function SaveAnovanTable(outfile,tabletosave,varargin)
% Save an anovan output table to an output text file,
% based on http://www.mathworks.com/matlabcentral/newsreader/view_thread/102314
% outfile should be either:
%    a string, in which case it is treated as a file name & the file is opened & closed, or
%    an open file, in which the table is appended and the file is left open.

if ischar(outfile)
   outfilewasstring = true;
   outfile = fopen(outfile,'w');
else
   % NewJeff: If outfile is not a string, assume without check that it is a valid file id.
   outfilewasstring = false;
end

%tabletosave(:,4)= [];
%[nrows,ncols]= size(tabletosave);
%fprintf(outfile, '%s\t %s\t %s\t %s\t %s\t %s\n', tabletosave{1,:});
%for row = 2:nrows-2
%    fprintf(outfile, '%s\t %0.5f\t %i\t %0.5f\t %0.2f\t %0.4f\n', tabletosave{row,:});
%end
%fprintf(outfile, '%s\t %0.5f\t %i\t %0.5f\n', tabletosave{nrows-1,1:4});
%fprintf(outfile, '%s\t %0.5f\t %i\n', tabletosave{nrows,1:3});

fmttable = FormatAnovanTable(tabletosave,varargin{:});

for iRow=1:numel(fmttable)
    fprintf(outfile,'%s\n', fmttable{iRow});
end

if outfilewasstring
   fclose(outfile);
end

end
