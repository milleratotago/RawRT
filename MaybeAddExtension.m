function sFName = MaybeAddExtension(sFName,sExt)
    % if the file name sFName has no extension,
    % then add the extension sExt.
    if numel( strfind(sFName,'.') ) == 0
       sFName = [sFName sExt];
    end
end
