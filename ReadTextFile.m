function inLines =  ReadTextFile(sFileName)
    % Read a text file into a cell array of lines
    str = fileread(sFileName);
    inLines = regexp(str, '\r\n|\r|\n', 'split');
    inLines = reshape(inLines,[],1);
end
