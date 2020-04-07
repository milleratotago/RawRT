classdef FPRtools
    % Tools for deriving LaTex & tab-delimited output from MrF output *.fpr files.
    % Main use cases:
    %  o Add \myFeta macros & \newcommands & tab-delimited tables to the FPR file.
    %  o Derive \myFeta macros from ANOVA tables
    %  o Define \newcommands with \myFeta macros from ANOVA tables
    %  o Make summary tables comparing results across multiple FPR files (function FPRs2table).
    %  o Format ANOVA tables into LaTex.
    % For examples, see data/rt/2018/M1801040507/*.m

    % Main functions:
    %   FPRs2table         Read the FPR files whose names are in inFiles and recast them into a MATLAB table.
    %   NewcommandFile     Read the FPR files whose names are in inFiles & write an output file with Newcommands for all of them.
    %   ExpandFPR          Read FPR output file and add myFeta, myFetaNewcommand, & TabDelim lines to it at the end of each ANOVA table.
    %   AnovaTbl2myFetas   Convert MrF lines to myFeta lines.
    %   AnovaTbl2TabDelim  Convert MrF lines to tab-delimited lines.
    %   FPRANOVAs2Latex    Read an FPR file and recast each ANOVA table into a LaTex table.

    properties (Constant)
        
        NullString = {''};
        
        % The following structure is a cluge to be used to replace source names
        % as soon as they are read in from the FPR file (by SplitFPRAnovaLine).
        % Use the next line if you don't want any replacements;
        %  if you do want replacements, use something like the example below.
        % SourceReplacements = {};
        SourceReplacements = { ... %  Each row has one source; old name in col 1, new in col 2.
            'D' 'Dist'; ...
            'S' 'Soa';  ...
            'SOA' 'Soa'; ...
            'RespTask' 'Resp'; ...
            'BCE' 'Bce'; ...
            'B' 'Bce'; ...
            'FCE' 'Fce'; ...
            'F' 'Fce'; ...
            'G' 'Group'; ...
            'P' 'Prob'; ...
            'E' 'Expt'; ...
            };
        
    end % properties (Constant)
    
    methods (Static)
        
        function outTbl = FPRs2table(inFiles)
            % Read all of the FPR files whose names are listed in the cell array inFiles
            %  and recast them into a MATLAB table.
            % If there are multiple inFiles, the cell array inFiles must be structured
            %  correctly into rows and columns.
            % All of the files in the same row of inFiles must have the same Anova sources,
            %  and all of the files in the same inFiles column of inFiles must have the same DV names.
            % So, the output table will be organized like this example:
            % File1 Source  RT_df RT_MS RT_dfe RT_MSe RT_F RT_pEtaSqr RT_p  File2 Source   PC_df PC_MS PC_dfe PC_MSe PC_F PC_pEtaSqr PC_p
            %  RT1   Mn     ---------------- inFiles{1,1} ----------------    PC1   Mn     ---------------- inFiles{1,2} ----------------
            %  RT1   A      ---------------- inFiles{1,1} ----------------    PC1   A      ---------------- inFiles{1,2} ----------------
            %  RT1   B      ---------------- inFiles{1,1} ----------------    PC1   B      ---------------- inFiles{1,2} ----------------
            %  RT1   AB     ---------------- inFiles{1,1} ----------------    PC1   AB     ---------------- inFiles{1,2} ----------------
            %  RT2   Mn     ---------------- inFiles{2,1} ----------------    PC2   Mn     ---------------- inFiles{2,2} ----------------
            %  RT2   Prac   ---------------- inFiles{2,1} ----------------    PC2   Prac   ---------------- inFiles{2,2} ----------------
            %  RT2   ...    ---------------- inFiles{2,1} ----------------    PC2   ...    ---------------- inFiles{2,2} ----------------
            %  RT3   Mn     ---------------- inFiles{3,1} ----------------    PC3   Mn     ---------------- inFiles{3,2} ----------------
            %  RT3   ...    ---------------- inFiles{3,1} ----------------    PC3   ...    ---------------- inFiles{3,2} ----------------
            % To generate this example, infiles would be something like:
            %   inFiles = {'RT1.FPR', 'PC1.FPR';'RT2.FPR', 'PC2.FPR';'RT3.FPR', 'PC3.FPR'};
            % If there are multiple Anovas within the individual FPR files, all ANOVA tables must have the same sources,
            %  and their column names are distinguished with a DV name prefix.  For example, in the diagram above,
            %  suppose the FPR files for RT had separate Anovas for RT1 and RT2. Then, there would be a set of
            % RT1_ columns followed by a set of RT2_ columns.
            inFiles = EnsureCell(inFiles);
            [nrows, ncols] = size(inFiles);
            outTbl = table;
            for irow=1:nrows
                RowAnovas = table;
                % For each row, assemble all of the columns in the output table;
                for icol=1:ncols
                    % Extract the Anovas from one file:
                    [AnovaSegments, ~, nAnovaTables, DVNames] = FPRtools.ReadAndSegmentFPRfile(inFiles{irow,icol});
                    % Pack those Anovas into successive columns of a table with one row per source:
                    DVNames = matlab.lang.makeValidName(DVNames);
                    FileAnovas = table;
                    for iTbl=1:nAnovaTables
                        SingleAnova = FPRtools.AnovaTbl2table(AnovaSegments{iTbl});
                        SingleAnova.Properties.VariableNames = strcat('Col',num2str(icol),'_',DVNames{iTbl},'_',SingleAnova.Properties.VariableNames);
                        try
                            FileAnovas = [FileAnovas SingleAnova]; %#ok<AGROW>
                        catch
                            FileAnovas %#ok<NOPRT>
                            SingleAnova %#ok<NOPRT>
                            error('ERROR concatenating columns of the above two tables!');
                        end
                    end
                    try
                        RowAnovas = [RowAnovas FileAnovas]; %#ok<AGROW>
                    catch
                        RowAnovas %#ok<NOPRT>
                        FileAnovas %#ok<NOPRT>
                        error('ERROR concatenating columns of the above two tables!');
                    end
                    
                end % icol
                try
                    outTbl = [outTbl; RowAnovas]; %#ok<AGROW>
                catch
                    outTbl %#ok<NOPRT>
                    RowAnovas %#ok<NOPRT>
                    error('ERROR concatenating rows of the above two tables; probably different variable names!');
                end
            end % irow
        end
        
        function [] = NewcommandFile(inPath,inFiles,outFileName,varargin)
            % Read all the FPR files listed in the cell array inFiles within the path inPath.
            % Write an output file outFileName.tex with Newcommands for all of them.
            % Optional arguments:
            %   'append': append to outFileName rather than overwriting it.
            [WantAppend, varargin] = ExtractNamei('Append',varargin);
            if numel(varargin)>0
                varargin{:} %#ok<NOPRT>
                error('Unrecognized parameters: ');
            end
            inFiles = EnsureCell(inFiles);
            outFileName = MaybeAddExtension(outFileName,'.tex');
            if WantAppend && exist(outFileName,'file')
                WriteType = 'a';
            else
                WriteType = 'w';
            end
            outf = fopen(outFileName,WriteType);
            nFiles = numel(inFiles);
            for iFile = 1:nFiles
                [AnovaSegments, ~, nAnovaTables, DVNames] = FPRtools.ReadAndSegmentFPRfile([inPath inFiles{iFile}]);
                Descriptors = FPRtools.Descriptor(inFiles{iFile},DVNames);
                myFetaNewcommands = cell(nAnovaTables,1);
                for iTable=1:nAnovaTables
                    myFetaNewcommands{iTable} = FPRtools.AnovaTbl2myFetaNewcommands(AnovaSegments{iTable},Descriptors{iTable});
                end
                for iTable = 1:nAnovaTables
                    WriteTextFile(outf,myFetaNewcommands{iTable});
                    fprintf(outf,'\n');
                end
            end
            fclose(outf);
        end

        function cDescriptors = Descriptor(sFileName,DVNames)
            % Compute a cell array of descriptor prefixes that is used in labelling both myFetas and newcommands.
            % If there is only 1 DV, the descriptor is just the file name.
            % Otherwise it is sFileName.DVName for each DV.
            if numel(DVNames)==1
                cDescriptors = {sFileName};
            else
                cDescriptors = strcat(sFileName,'.',DVNames);
            end
        end

            
        function [AnovaSegments, NonAnovaSegments, nAnovaTables, DVNames] = ReadAndSegmentFPRfile(sFPRFileNameRoot)
            sFPRFileName = MaybeAddExtension(sFPRFileNameRoot,'.FPR');
            % sDescriptor = sFPRFileNameRoot;
            
            % Read the file into one big cell array.
            FPRLines = ReadTextFile(sFPRFileName);
            
            % Break up the FPRLines into segments (i.e., groups of lines),
            % where the even-numbered segments are lines in Anova tables.
            [AnovaSegments, NonAnovaSegments, nAnovaTables, DVNames] = FPRtools.SegmentFPR(FPRLines);
            
        end
        
        function [myFetas, myFetaNewcommands] = ExpandFPR(sFPRFileNameRoot)
            % Read a MrF *.FPR output file and add myFeta, myFetaNewcommand, & TabDelim
            %  lines at the end of each ANOVA table.
            % sFPRFileNameRoot is included in the initial ID field of \myFeta, and its
            %  characters plus the ANOVA source provide the newcommand name.
            
            [AnovaAnovaSegments, NonAnovaAnovaSegments, nAnovaTables, DVNames] = FPRtools.ReadAndSegmentFPRfile(sFPRFileNameRoot);
            Descriptors = FPRtools.Descriptor(sFPRFileNameRoot,DVNames);
            
            myFetas = cell(nAnovaTables,1);
            for iTable=1:nAnovaTables
                myFetas{iTable} = FPRtools.AnovaTbl2myFetas(AnovaAnovaSegments{iTable},Descriptors{iTable});
            end
            
            myFetaNewcommands = cell(nAnovaTables,1);
            for iTable=1:nAnovaTables
                myFetaNewcommands{iTable} = FPRtools.AnovaTbl2myFetaNewcommands(AnovaAnovaSegments{iTable},Descriptors{iTable});
            end
            
            myTabDelims = cell(nAnovaTables,1);
            for iTable=1:nAnovaTables
                myTabDelims{iTable} = FPRtools.AnovaTbl2TabDelim(AnovaAnovaSegments{iTable},Descriptors{iTable});
            end
            
            % Assemble strings for output file:
            outStrings = NonAnovaAnovaSegments{1};
            for iTable = 1:nAnovaTables
                outStrings = [outStrings; AnovaAnovaSegments{iTable}]; %#ok<AGROW>  % The original Mrf table
                outStrings = [outStrings; FPRtools.NullString; myFetas{iTable}]; %#ok<AGROW>
                outStrings = [outStrings; FPRtools.NullString; myFetaNewcommands{iTable}]; %#ok<AGROW>
                outStrings = [outStrings; FPRtools.NullString; myTabDelims{iTable}]; %#ok<AGROW>
                outStrings = [outStrings; NonAnovaAnovaSegments{iTable+1}]; %#ok<AGROW>  % What followed the original Mrf table
            end
            
            % Write the output file
            WriteTextFile(sFPRFileName,outStrings);
        end
        
        function [sOut, sSource] = AnovaLine2myFeta(sIn,Descriptors)
            % Convert one line of a MrF ANOVA file into a Latex \myFeta string, sOut, also reporting the sSource.
            % Assumed MrF line format:
            %   Source        df             MS    dfe        MSe          F     pEta^2      P    G-G P **??
            % Assumed myFeta pattern:
            %  \myFeta{1=Source}{2=dfeff}{3=dferr}{4=MSerr}{5=Fobs}{6=pEta^2}{7=GGP or p}
            %  \newcommand{\myFeta}[7]{$F(#2,#3)$ = #5, $#7$, $\petasqr=#6$}
            [sSource, sdf1, ~, sdf2, sMSe, sF, spEtaSqr, sp] = FPRtools.SplitFPRAnovaLine(sIn);    % Ignoring sMSeff
            sF = FPRtools.FReformat(sF);
            sp = FPRtools.pReformat(sp);
            sOut = sprintf('\\myFeta{%s.%s}{%s}{%s}{%s}{%s}{%s}{%s}', ...
                Descriptors,sSource,sdf1,sdf2,sMSe,sF,spEtaSqr,sp);
        end
        
        function [sOut] = AnovaTbl2myFetas(inAnovaLines,Descriptors)
            % inAnovaLines is a cell array holding the lines of a MrF ANOVA table.
            % sOut is a cell array holding the corresponding myFeta lines.
            nLines = numel(inAnovaLines);
            sOut = cell(nLines,1);
            for iLine=1:nLines
                sOut{iLine} = FPRtools.AnovaLine2myFeta(inAnovaLines{iLine},Descriptors);
            end
        end
        
        function sOut = AnovaLine2myFetaNewcommand(sIn,Descriptors)
            % Convert one line of a MrF ANOVA file into a Latex \newcommand for a \myFeta string.
            % The command name for each line is [Descriptors sSource]
            [sOut, sSource] = FPRtools.AnovaLine2myFeta(sIn,Descriptors);
            sOut = ['\newcommand{\' Descriptors(isletter(Descriptors)) sSource '}{' sOut '}'];
        end
        
        function [sOut] = AnovaTbl2myFetaNewcommands(inAnovaLines, Descriptors)
            % Create a set of Latex newcommand statements to define a newcommand
            % for each line in the input inAnovaLines table.
            nLines = numel(inAnovaLines);
            sOut = cell(nLines,1);
            for iLine=1:nLines
                sOut{iLine} = FPRtools.AnovaLine2myFetaNewcommand(inAnovaLines{iLine},Descriptors);
            end
            sOut = [{['%%% myFetaNewcommands start: ' Descriptors]}; ...
                sOut(:); {['%%% myFetaNewcommands stop: ' Descriptors]}];
        end
        
        function newSource = MaybeReplaceSource(oldSource)
            % Check to see whether the input oldSource is in col 1 of FPRtools.SourceReplacements.
            % If not, return it. If so, return the corresponding string in col 2.
            newSource = oldSource;
            [rows, cols] = size(FPRtools.SourceReplacements);
            for i=1:rows
                if strcmp(oldSource,FPRtools.SourceReplacements{i,1})
                    newSource = FPRtools.SourceReplacements{i,2};
                    return;
                end
            end
        end
        
        function outS = MaybeInsertCommas(inS)
            % Insert comma separators in large numbers e.g. 1,000
            outS = inS;
            % Just return input unless inS has exactly one decimal place
            decplaces = strfind(inS,'.');
            if ~(numel(decplaces)==1)
                return
            end
            % Just return input if there are 3 or fewer digits ahead of the decimal place.
            if decplaces<=4
                return
            end
            insertpos = decplaces - 4;
            while insertpos>=1
                outS = [outS(1:insertpos) ',' outS(insertpos+1:end)];
                insertpos = insertpos - 3;
            end
        end
        
        function [sSource, sdf, sMS, sdfe, sMSe, sF, spEtaSqr, sp, rp] = SplitFPRAnovaLine(sIn)
            % Split one line of an FPR file into its string components, returning GGP if available & p if not.
            % Assumed MrF line format:
            %   Source        df             MS    dfe        MSe          F     pEta^2      P    G-G P **??
            % Return strings or reals depending on ReturnReals boolean (sSource always a string).
            Words = strsplit(sIn);
            nWords = numel(Words);
            if (nWords<8) || (nWords>10)
                error(['Unrecognized MrF line format: ' sIn]);
            end
            [sSource, sdf, sMS, sdfe, sMSe, sF, spEtaSqr, sp] = Words{1:8};  % All strings at this point
            sSource = FPRtools.MaybeReplaceSource(sSource);
            sdf = FPRtools.MaybeInsertCommas(sdf);
            sMS = FPRtools.MaybeInsertCommas(sMS);
            sdfe = FPRtools.MaybeInsertCommas(sdfe);
            sMSe = FPRtools.MaybeInsertCommas(sMSe);
            sF = FPRtools.MaybeInsertCommas(sF);
            switch numel(Words)
                case 8
                    % Nothing further needed.
                case {9, 10}
                    % The 9th word could be either GGP or the ** / ?? marker.
                    % To distinguish, check whether it contains a decimal point,
                    % in which case it must be a GGP.
                    if numel( strfind(Words{9},'.') ) > 0
                        sp = Words{9};
                    end
%                 case 10  % This didn't work where I added a comment after ***
%                     % There must be a GGP followed by a ** / ?? marker.
%                     sp = Words{9};
                otherwise
                    error(['Unrecognized FPR Anova line format: ' sIn]);
            end
            rp = str2double(sp);
            %             return
            %             rp = str2double(sp);
            %             if (nWords > 8)  % check for G-G P
            %                 rGGp = str2double(Words{9});
            %                 if ~isnan(rGGp) %  && (numel(rGGp)>0) str2num returns empty array but str2double returns nan
            %                     rp = rGGp;
            %                 end
            %             end
            %             if ReturnReals
            %                 df = round(str2double(df));
            %                 MS = str2double(sMS);
            %                 dfe = round(str2double(dfe));
            %                 MSe = str2double(MSe);
            %                 F = str2double(F);
            %                 pEtaSqr = str2double(pEtaSqr);
            %                 p = rp;
            %             else
            %                 sp = ['p=' num2str(rp,'%5.3f')];
            %                 if strcmp(sp,'p=0.000')
            %                     sp = 'p<0.001';
            %                 end
            %             end
        end
        
        function spOut = pReformat(spIn)
            % Take a string p value and return either 'p=that p',
            % but return 'p<.001' instead of 'p=.000'
            rp = str2double(spIn);
            spOut = ['p=' num2str(rp,'%5.3f')];
            if strcmp(spOut,'p=0.000')
                spOut = 'p<0.001';
            end
        end
        
        function sFOut = FReformat(sFIn)
            % Take a string F value and return it with an appropriate number of decimal places.
            rF = str2double(sFIn);
            if rF >= 10000
                sFOut = num2str(rF,'%5.1f');
            elseif rF >= 1000
                sFOut = num2str(rF,'%5.2f');
            else
                sFOut = num2str(rF,'%5.3f');
            end
        end
        
        function sOut = AnovaLine2TabDelim(sIn)
            [sSource, sdf1, sMS, sdf2, sMSe, sF, spEtaSqr, sp] = FPRtools.SplitFPRAnovaLine(sIn);
            sOut = sprintf(['%s' repmat('\t%s',1,7)],sSource,sdf1,sMS,sdf2,sMSe,sF,spEtaSqr,sp);
        end
        
        function sOut = AnovaTbl2TabDelim(inAnovaLines,Descriptors)
            % inAnovaLines is a cell array holding the lines of a MrF ANOVA table.
            % sOut is a cell array holding the corresponding tab-delimited lines.
            nHeaderLines = 2; % Descriptors
            nLines = numel(inAnovaLines);
            sOut = cell(nLines+nHeaderLines,1);
            sOut{1} = Descriptors;
            sOut{2} = sprintf('Source\tdf\tMS\tdfe\tMSe\tF\tpEtaSqr\tp');
            for iLine=1:nLines
                sOut{iLine+nHeaderLines} = FPRtools.AnovaLine2TabDelim(inAnovaLines{iLine});
            end
        end
        
        function [sSource, rdf1, rMS, rdf2, rMSe, rF, rpEtaSqr, rp] = AnovaLine2Vars(sIn)
            [sSource, sdf1, sMS, sdf2, sMSe, sF, spEtaSqr, sp] = FPRtools.SplitFPRAnovaLine(sIn);
            rdf1 = round(str2double(sdf1));
            rMS = str2double(sMS);
            rdf2 = round(str2double(sdf2));
            rMSe = str2double(sMSe);
            rF = str2double(sF);
            rpEtaSqr = str2double(spEtaSqr);
            rp = str2double(sp);
        end
        
        function tblOut = AnovaTbl2table(inAnovaLines)
            % inAnovaLines is a cell array holding the lines of a MrF ANOVA table.
            % tblOut is a table of the corresponding variables.
            nLines = numel(inAnovaLines);
            Source = cell(nLines,1);
            df = zeros(nLines,1);
            MS = zeros(nLines,1);
            dfe = zeros(nLines,1);
            MSe = zeros(nLines,1);
            F = zeros(nLines,1);
            pEtaSqr = zeros(nLines,1);
            p = zeros(nLines,1);
            for iLine=1:nLines
                [Source{iLine}, df(iLine), MS(iLine), dfe(iLine), MSe(iLine), F(iLine), pEtaSqr(iLine), p(iLine)] = FPRtools.AnovaLine2Vars(inAnovaLines{iLine});
            end
            tblOut = table(Source,df,MS,dfe,MSe,F,pEtaSqr,p);
        end
        
        function [AnovaSegments, NonAnovaSegments, nAnovaTables, DVNames] = SegmentFPR(inLines)
            % inLines is a cell array of strings from a MrF output *.FPR file.
            % AnovaSegments and NonAnovaSegments are cell arrays, where each cell is itself a cell array of strings.
            % AnovaSegments has an ODD NUMBER of cell arrays:
            %   NonAnovaSegments{1} is the cell array of strings up to the first ANOVA table,
            %   AnovaSegments{1} is the cell array of strings inside the first ANOVA table,
            %   NonAnovaSegments{2} is the cell array of strings from the end of the first ANOVA table to the start of the second ANOVA table
            %   AnovaSegments{2} is the cell array of strings inside the second ANOVA table,
            %   ...
            %   NonAnovaSegments{end} is the cell array of strings after the end of the last ANOVA table.
            
            AnovaTitleMarker = 'ANOVA For ';  % 1st part of Mrf's title line for each ANOVA, followed by Source df ... line
            nAnovaHeaderLines = 2;
            
            % Make a cell array with the position of the marker in each line.
            AnovaTitleLines = strfind(inLines,AnovaTitleMarker);
            
            % make a list of the line numbers of the AnovaTitle lines
            AnovaStartIndex = find(not(cellfun('isempty',AnovaTitleLines))) + nAnovaHeaderLines;
            nAnovaTables = numel(AnovaStartIndex);
            
            % Copy DVNames associated with each table.
            DVNames = cell(nAnovaTables,1);
            PosFirstCharInName = length(AnovaTitleMarker) + 1;  % DV name starts right after the title
            for iTable = 1:nAnovaTables
                LineNo = AnovaStartIndex(iTable) - nAnovaHeaderLines;
                DVNames{iTable} = inLines{LineNo}(PosFirstCharInName:end);
            end
            
            % Find the indices of the last lines of each Anova Table:
            AnovaEndIndex = AnovaStartIndex;
            for iTable=1:nAnovaTables
                i = AnovaEndIndex(iTable);
                while ~strcmp(inLines(i),'')
                    i = i + 1;
                end
                AnovaEndIndex(iTable) = i - 1;
            end
            
            % Make a cell array to hold the blocks of output lines.
            % Each cell will be a cell array of strings.
            AnovaSegments = cell(nAnovaTables,1);
            NonAnovaSegments = cell(nAnovaTables+1,1);
            
            iUsedLines = 0;
            for iTable=1:nAnovaTables
                NonAnovaSegments{iTable} = CopyRangeOfLines(inLines,iUsedLines+1,AnovaStartIndex(iTable)-1);
                AnovaSegments{iTable} = CopyRangeOfLines(inLines,AnovaStartIndex(iTable),AnovaEndIndex(iTable));
                iUsedLines = AnovaEndIndex(iTable);
            end
            NonAnovaSegments{nAnovaTables+1} = CopyRangeOfLines(inLines,AnovaEndIndex(nAnovaTables)+1,numel(inLines));
            
        end

        %%% Start code to convert MrF ANOVA tables to LaTex ANOVA tables

        function sOut = AnovaLine2Latex(sIn,varargin)
            % Convert one line of a MrF ANOVA file into one line of a Latex-formatted ANOVA output table.
            % Assumed MrF line format:
            %   Source        df             MS    dfe        MSe          F     pEta^2      P    G-G P **??
            % Assumed LaTex output:
            %  Source  & dfeff & MSeff & dferr & MSerr & Fobs & p & pEta \\
            %  \newcommand{\myFeta}[7]{$F(#2,#3)$ = #5, $#7$, $\petasqr=#6$}
            [maxP, varargin] = ExtractNameVali('MaxP',2,varargin);
            [sSource, sdf1, sMSeff, sdf2, sMSe, sF, spEtaSqr, sp, rp] = FPRtools.SplitFPRAnovaLine(sIn);
            if rp > maxP
                sOut = '';
            else
               sF = FPRtools.FReformat(sF);
               sp = FPRtools.pReformatLaTbl(sp);
               sOut = sprintf('%s & %s & %s & %s & %s & %s & %s & %s \\\\', ...
                sSource,sdf1,sMSeff,sdf2,sMSe,sF,sp,spEtaSqr);
            end
        end
        
        function sOut = AnovaTbl2Latex(inAnovaLines,varargin)
            % inAnovaLines is a cell array holding the lines of a MrF ANOVA table.
            % sOut is a cell array holding the corresponding LaTex lines.
            % varargin is provided just to pass maxP for dropping lines with large p.
            nHeaderLines = 2;  % begin{supertabular} & Source/df/etc
            FirstTableLine = 2;  % skip mean line
            nLines = numel(inAnovaLines);
            sOut = cell(nLines+nHeaderLines-FirstTableLine+1,1);
            % It would more flexible to let the LaTex user define the environment,
            % but an \input command cannot occur inside a (super)tabular environment.
            sOut{1} = '\begin{supertabular}{lrrrrrrr}';
            sOut{2} = sprintf(['Source & df & \\multicolumn{1}{c}{MS} & ${\\rm df}_{\\rm err}$ & ' ...
             '\\multicolumn{1}{c}{${\\rm MS}_{\\rm err}$} & \\multicolumn{1}{c}{$F$} & ' ...
             '\\multicolumn{1}{c}{$p$} & \\multicolumn{1}{c}{$\\petasqr$} \\\\ \\hline']);
            UsedLines = nHeaderLines;
            for iLine=FirstTableLine:nLines
                s = FPRtools.AnovaLine2Latex(inAnovaLines{iLine},varargin{:});
                % AnovaLine2Latex may return empty line if p > maxP
                if numel(s) > 0
                    UsedLines = UsedLines + 1;
                    sOut{UsedLines} = s;
                end
            end
            sOut{UsedLines+1} = '\end{supertabular}';
            sOut(UsedLines+2:end) = [];
        end
        
        function outTbls = MrFAnovas2Latex(inFilename,varargin)
            % varargin is provided just to pass maxP for dropping lines with large p.
            [AnovaSegments, ~, nAnovaTables] = FPRtools.ReadAndSegmentFPRfile(inFilename);
            outTbls = cell(nAnovaTables,1);
            for iTbl=1:nAnovaTables
                outTbls{iTbl} = FPRtools.AnovaTbl2Latex(AnovaSegments{iTbl},varargin{:});
            end
        end
        
        function spOut = pReformatLaTbl(spIn)
            % Take a string p value and return it,
            % but return 'p<.001' instead of '0.000'
            if strcmp(spIn,'0.000') || strcmp(spIn,'.000')
                spOut = '<0.001';
            else
                spOut = spIn;
            end
        end
        
        %%% End code to convert MrF ANOVA table to LaTex


        
    end % methods (Static)
    
end % classdef
