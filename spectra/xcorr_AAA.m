function [ra,lags] = xcorr_AAA(x,y,varargin) 
% Calculates lagged cross-correlation ra between two variables with the
% ability to form overlapping segments
%
% Alex Andriatis
% 2024-07-15
ra=[];
lags=[];

P=inputParser;
addRequired(P,'x',@isnumeric);
addRequired(P,'y',@isnumeric);

if length(x)~=length(y)
    error('Data must be of the same length');
end

defaultSegLength = length(x);
addParameter(P,'seglength',defaultSegLength,@isnumeric);

defaultNumSeg = 1;
addParameter(P,'numseg',defaultNumSeg,@isnumeric);

defaultWindow = 'none';
checkString=@(s) any(strcmp(s,{'none','hanning','triangle'}));
addParameter(P,'window',defaultWindow,checkString);

defaultOverlap=0;
addParameter(P,'overlap',defaultOverlap,@isnumeric);

defaultMakePlot=false;
addParameter(P,'makeplot',defaultMakePlot,@islogical);

defaultZeroPad = 0;
addParameter(P,'padding',defaultZeroPad,@isnumeric);

defaultRescale = false;
addParameter(P,'rescale',defaultRescale,@islogical);

defaultIncludeMean = false;
addParameter(P,'includemean',defaultIncludeMean,@islogical);

defaultDiagnostics = false;
addParameter(P,'diagnostics',defaultDiagnostics,@islogical);

defaultDT = 1;
addParameter(P,'dt',defaultDT,@isnumeric);

defaultScaleopt = 'none';
checkString=@(s) any(strcmp(s,{'none','biased','unbiased','normalized','coeff'}));
addParameter(P,'scaleopt',defaultScaleopt,checkString);

parse(P,x,y,varargin{:});
x = P.Results.x;
y = P.Results.y;
seglength = P.Results.seglength;
numseg = P.Results.numseg;
window = P.Results.window;
overlap = P.Results.overlap;
makeplot = P.Results.makeplot;
padding = P.Results.padding;
rescale = P.Results.rescale;
includemean = P.Results.includemean;
diagnostics = P.Results.diagnostics;
dt = P.Results.dt;
scaleopt=P.Results.scaleopt;

if seglength == length(x) && numseg==1
    X = x;
    if size(X,1)==1
        X = X';
        if diagnostics; disp('Flipping input vector'); end
    end
    Y = y;
    if size(Y,1)==1
        Y = Y';
        if diagnostics; disp('Flipping input vector'); end
    end
    if diagnostics; disp('Full timeseries spectrum'); end

elseif seglength ~= length(x) && numseg ==1
    X = buffer(x,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    Y = buffer(y,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(X(:,end)) || ~all(Y(:,end))
        X(:,end)=[]; % Removes the last vector since it might be partially empty
        Y(:,end)=[];
    end
    if diagnostics; disp('Segmenting according to seglength'); end
    seglength = size(X,1);
    numseg = size(X,2);

elseif seglength == length(x) && numseg ~=1
    seglength = ceil(length(x)/(numseg*(1-overlap)+overlap));
    X = buffer(x,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    Y = buffer(y,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(X(:,end)) || ~all(Y(:,end))
        X(:,end)=[]; % Removes the last vector since it might be partially empty
        Y(:,end)=[]; % Removes the last vector since it might be partially empty
    end
    if diagnostics; disp('Segmenting according to numseg'); end
    seglength = size(X,1);
    numseg = size(X,2);

elseif seglength ~=length(x) && numseg ~=1
    X = buffer(x,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    Y = buffer(y,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    X = X(:,1:numseg);
    Y = Y(:,1:numseg);
    if diagnostics; disp('Segmenting according to seglength and numseg'); end
    seglength = size(X,1);
    numseg = size(X,2);
end

X = detrend(X,1);
Y = detrend(Y,1);

varx = mean(sum(X.^2)/size(X,1)); 
vary = mean(sum(Y.^2)/size(Y,1)); 

if strcmp(window,'hanning')
    hannwin = hanning(seglength)*ones(1,size(X,2)); %Hanning window, a data analysis tool to emphasize central values, reducing spectral noise from mismatched segments
    X = X.*hannwin; %Scales the data by the hanning window
    Y = Y.*hannwin; %Scales the data by the hanning window
    if diagnostics; disp('Hanning window applied'); end
elseif ~strcmp(window,'none')
    error('Window not recognized');
else
    if diagnostics; disp('No windowing'); end
end

NX=size(X,1);
lags=-(NX-1):1:(NX-1);
R=NaN(length(lags),size(X,2));

for t=1:size(X,2)
    r=xcorr(X(:,t),Y(:,t),scaleopt);
    R(:,t)=r;
end

ra=mean(R,2);

ra=row_AAA(ra); % For now convert it to a row, can adjust 



% if mod(p,2)==0
%     k=0:p/2; %Use only half of the fourier transform since it's symmetric about its middle value
% else
%     k=0:(p-1)/2;
% end

% Old code from spectral stuff to use as an example

% if padding>0
%     npad=2^(ceil(log2(seglength))+padding-1); % Pad data with approx an equal number of zeros, but make it a power of 2
% else
%     npad=seglength;
% end
% 
% S = fft(s,npad,1); %Fourier transform of data
% p = size(S,1); %Vector of points in the frequency space
% N = size(S,2); %Size
% 
% dt = mean(diff(time)); % Sampling interval
% Fs = 1/dt; % Sampling frequency
% T = seglength*dt; % Total length of record
% df = Fs/npad; % Frequency increment
% Ffun = 1/T; % Fundamental frequency
% 
% % Construct the frequency vector
% if mod(p,2)==0
%     k=0:p/2; %Use only half of the fourier transform since it's symmetric about its middle value
% else
%     k=0:(p-1)/2;
% end
% f = df*k; % Frequency axis;
% 
% % Construct the amplitude equared
% if mod(p,2)==0
%    a2=abs(S(1:p/2+1,:)).^2; %Magnitude squared of coefficient
%    a2(2:end-1,:)=2*a2(2:end-1,:); % Double energy except at mean and central value
% else
%    a2=abs(S(1:(p+1)/2,:)).^2; %Magnitude squared of coefficient
%    a2(2:end,:)=2*a2(2:end,:); % Double energy except at mean value
% end
% 
% a2 = a2/(seglength*Fs); %Normalize by record length and sampling frequency
% 
% % Normalize the resulting spectra by accounting for the amplitude reduction
% % from the window
% if strcmp(window,'hanning')
%     a2 = a2*8/3; %Normalize by the degree of freedom contribution due to the hanning window
%     if diagnostics; disp('Normalizing by hanning window'); end
% end
% 
% if strcmp(window,'hanning')
%     nu = dof_calculator(seglength,numseg,window,overlap);
%     if diagnostics; disp('Hanning window dof'); end
% elseif strcmp(window,'none') && overlap~=0
%     nu = dof_calculator(seglength,numseg,'boxcar',overlap);
%     if diagnostics; disp('Degrees of freedom for overlaping square segments'); end
% elseif overlap==0
%     nu = N*2; %for no overlap
%     if diagnostics; disp('Degrees of freedom for non-overlaping square segments'); end
% end
% ma = mean(a2,2,'omitnan'); %Mean across all segments
% 
% %Parseval's theorem
% 
% varf = sum(ma)*df;
% pars = abs(varf - vart)/vart;
% pars_rat = vart/varf; %should be 1
% pars_str = 'Parsevals theorem: Timeseries variance is %0.5f; Spectral sum is %0.5f; Fraction difference is %0.5f; Ratio is %0.5f \n';
% if diagnostics; fprintf(pars_str,vart, varf, pars, pars_rat); end
% 
% if rescale
%     ma = ma*pars_rat;
%     if diagnostics; disp('Rescaling to preserve variance'); end
% end
% 
% % Truncate data at the fundamental frequency, to remove unreal zero-padded
% % values
% Ifun=find(f>=Ffun-eps,1);
% if ~includemean
%     f=f(Ifun:end);
%     ma=ma(Ifun:end);
%     if diagnostics; disp('Cutting output to fundamental frequency'); end
% end
% 
% % Calculating error bars
% err_high = nu/chi2inv(.05/2,nu); %Lower 5% confidence limit based on a chi2 distribution with nu degrees of freedom
% err_low = nu/chi2inv(1-.05/2,nu); %Upper 95% confidence limit
% ratio = err_high/err_low; %Ratio of errors, not used in the rest of the calculation
% 
% if makeplot
%     colors; %This is a function of pretty colors I made
%     figure('Name','Spectrum'); %Plot spectra with confidence intervals
%         plot(f(2:end),ma(2:end),'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
%         hold on;
%             patch([f(2:end) flip(f(2:end))],[err_high*ma(2:end)' ...  
%             err_low*flip(ma(2:end))'],color.lr,'FaceAlpha',.3, ...
%             'EdgeColor','none'); %Plots the confidence limits in a lighter color
%         title('Amplitude Spectrum');
%         %ylabel('||T||^2/N \Delta f [\circ C^2 day^{-1}]');
%         ylabel('$\frac{||A||^2}{N \Delta f} ~ [[A]^2*s]$','Interpreter','latex','FontSize',16);
%         xlabel('f [Hz]'); 
%         xlim([f(1) f(end)]);
%         hold off;
%         set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
%         %close
% end
