function [PSE_SK, Sigma_SK, DL_SK, BootstrapMeans, BootstrapSEMs, BootstrapCIs, f1] = SpearKar(stim,n1,n2,varargin)
% Function for Spearman-Kaerber analysis of psychometric functions.
% Based on code from Rolf Ulrich
%
% Input parameters:
%   stim: a sorted vector of the stimulus values
%   n1  : also a vector: the number of R1 responses at each stimulus value
%   n2  : also a vector: the number of R2 responses at each stimulus value
%   Convention: as the stim value increases, there should be more n2 responses.
%
% Optional input parameters:
%   'Bootstrap',nSamples:  Default is 0--no bootstrapping.
%   'Plot': Default is no plot.
%
% Outputs

% Get the optional arguments:
[nSamples, varargin] = ExtractNameVali({'Bootstrap','nSamples'},0,varargin);
[WantPlot, varargin] = ExtractNamei('Plot',varargin);
assert(numel(varargin)==0,['Unprocessed arguments: ' strjoin(varargin)]);

% Must remove any stims that were never tested.
% If this is not done, the routine produces NaN's.
totaln = n1 + n2;
n1 = n1(totaln>0);
n2 = n2(totaln>0);
stim = stim(totaln>0);

[nTrials, fi, fiMono] = monotonize(n1, n2);

%% Spearman-Kaerber estimate
DLc = 0.6745; %75th percentile of standard normal
fiMono2 = diff([0, fiMono, 1]);
SKstimLevels = [stim(1) - diff(stim(1:2)), stim, stim(end) + diff(stim(end-1:end))];

PSE_SK   = 1/2*sum(fiMono2.*diff(SKstimLevels.^2)./diff(SKstimLevels));
M_SK     = 1/3*sum(fiMono2.*diff(SKstimLevels.^3)./diff(SKstimLevels));
Sigma_SK = sqrt(M_SK - PSE_SK^2);
DL_SK    = Sigma_SK*DLc;
%CE_SK    = PSE_SK-s;

%% Bootstrap for estimating SE
if nSamples<=0
    BootstrapMeans = nan;
    BootstrapSEMs = nan;
    BootstrapCIs = nan;
else
    BSn1 = zeros(nSamples,length(fi));
    for j=1:length(fi)
        BSn1(:,j)=sum(rand(nSamples, nTrials(j)) > fi(j),2);
    end
    
    BS_PSE_SK = zeros(1,nSamples);
    BS_M_SK = zeros(1,nSamples);
    BS_Sigma_SK = zeros(1,nSamples);
    BS_DL_SK = zeros(1,nSamples);
    BSfiMono = zeros(nSamples,length(fi));
    BSfiMono2 = zeros(nSamples,length(fi)+1);
    for j=1:nSamples
        [~, ~, BSfiMono(j,:)] = monotonize(BSn1(j,:), nTrials-BSn1(j,:));
        BSfiMono2(j,:) = diff([0, BSfiMono(j,:), 1]);
        
        BS_PSE_SK(j) = 1/2*sum(BSfiMono2(j,:).*diff(SKstimLevels.^2)./diff(SKstimLevels));
        BS_M_SK(j)   = 1/3*sum(BSfiMono2(j,:).*diff(SKstimLevels.^3)./diff(SKstimLevels));
        BS_Sigma_SK(j) = sqrt(BS_M_SK(j) - BS_PSE_SK(j)^2);
        BS_DL_SK(j)  = BS_Sigma_SK(j)*DLc;
    end
    
    
    BootstrapMeans=[mean(BS_PSE_SK), mean(BS_Sigma_SK), mean(BS_DL_SK)];
    BootstrapSEMs=[std(BS_PSE_SK), std(BS_Sigma_SK), std(BS_DL_SK)];
    BootstrapCIs=[prctileTies(BS_PSE_SK, 2.5), prctileTies(BS_Sigma_SK, 2.5),prctileTies(BS_DL_SK, 2.5);...
        prctileTies(BS_PSE_SK, 97.5), prctileTies(BS_Sigma_SK, 97.5),prctileTies(BS_DL_SK, 97.5)];
    
    %% Output
    %RelFreq = [fi; fiMono]
    %SKEstimates_PSE_SD_DL_CE = [PSE_SK, Sigma_SK, DL_SK, CE_SK]
    %BootstrapEstimates_PSE_SD_DL_CE = [BootstrapMeans; BootstrapSEMs; BootstrapCIs]
    
end  % Bootstrapping

if WantPlot
    %% True and monotonized function and PSE estimate
    f1 = figure;
    plot(stim,fi,'blacko',stim,fiMono,'blackx-',[PSE_SK PSE_SK],get(gca, 'ylim'),'k:')
    xlabel(' Comparison Level stim'); ylabel(' Relative Frequency of R_2');
    ylim([-0.03 1.03])
    legend('Observed relative frequency of R_2',...
        'Monotonized relative frequency of R_2',...
        'SK estimate of PSE','Location','SouthEast')
else
    f1=nan;
end

    function [nTrials, fi, fiMono] = monotonize(n1, n2)
        % Monotonize data
        
        nTrials = n1+n2;    %number of trials per comparison duration
        fi = n2./nTrials;   %relative frequency of "S2" responses
        fiMono = fi;        %start value for monotonized data
        
        while any(fiMono(1:end-1) > fiMono(2:end))  %as long as there is any non-monotonicity
            i=1;
            while i <= length(fiMono) - 1      %check for all stim-levels until the second-to-last
                if fiMono(i) <= fiMono(i+1)    % if fi_c(i) <= fi_c(i+1)  (i.e., monotonous)
                    i=i+1;                              % do nothing but increase i
                else                           % but if not monotonous
                    k=1;                                % start a counter k
                    while true
                        tempfi = sum(fiMono(i:i+k) .* nTrials(i:i+k)) ...  % compute temporary fi for fi_c(i) to fi_c(i+k)
                            ./ sum(nTrials(i:i+k));
                        if i+k+1 > length(fiMono); break                   % stop if i+k+1 < nclev
                        elseif fiMono(i+k+1) > tempfi; break               % stop when next fi would be larger than temporary mean (i.e., monotonic)
                        else
                            k=k+1;                                         % otherwise increase counter and start again, averaging over one more level
                        end
                    end
                    fiMono(i:i+k) = repmat(tempfi,1,k+1);                  % after exit, replace the fis from i:k with the monotonized fi
                    i=i+k+1;                                               % and just proceed at clevel i+k+1
                end
            end
        end
        
    end  % monotonize

end  % SpearKar

