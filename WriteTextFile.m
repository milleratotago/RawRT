function WriteTextFile( FileID, CellArrayOfStrings, varargin )
    % Write the strings to the file FileID.
    % FileID can be an open file or it can be a string;
    %  In the latter case the file is created & then closed at the end.
    % By default, overwrite when creating; use optional parameter ['append'] to append.
    
    FileIDisString = ischar(FileID);
    
    if FileIDisString
        if numel(varargin)==0
            writetype = 'w';
        elseif strcmpi(varargin{1},'append')
            writetype = 'a';
        else
            warning('Illegal parameter in WriteTextFile: appending');
            writetype = 'a';
        end
        
        fid = fopen(FileID,writetype);
    else
        fid = FileID;
    end
    
    for iLine=1:numel(CellArrayOfStrings)
        fprintf(fid,'%s\n',CellArrayOfStrings{iLine});
    end
    
    if FileIDisString
        fclose(fid);
    end
    
end

