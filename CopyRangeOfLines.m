function outLines = CopyRangeOfLines(inLines,FirstLineToCopy,LastLineToCopy)
    % Copy lines FirstLineToCopy:LastLineToCopy from the input cell array of
    % strings, inLines, into a new cell array of strings, outLines.
    nLines = LastLineToCopy - FirstLineToCopy + 1;
    outLines = cell(nLines,1);
    for iLine = 1:nLines
        outLines{iLine} = inLines{FirstLineToCopy+iLine-1};
    end
end

