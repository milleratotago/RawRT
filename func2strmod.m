function s = func2strmod(f)
    % Return the function as a string with some replacements for special functions
    % that I would like to rename.
    s = func2str(f);
    if strcmp(s,'minNAN4empty')
        s = 'min';
    elseif strcmp(s,'maxNAN4empty')
        s = 'max';
    end
end
