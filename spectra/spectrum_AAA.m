function [ma,f,nu,pars] = spectrum_AAA(variable,time,varargin) 
% Calculates spectra with error bars for a variable
% Calculates normalized spectra (squared magnitude of the FFT) using
% segments of 50% overlaping data with a hanning window (the standard 
% practice of 221A (Data I))
%
% For variable Y and timeseries T call 
%[f,S,nu,pars] = spectrum(Y,T) which returns the spectrum S and frequency
%axis f with degrees of freedom nu and the fraction deviation from
%paerseval's theorm pars
%
%The length of f will depend on the size of M, the number of points per
%segment, and the timestep used in the timeseries T. 
%
% 2023-04-01
% Added a zero-padding option, padding the end of a timeseries with zeros
% to the next nth power of 2. In principle this also speeds up the fft.
%
% Alex Andriatis
% 2023-04-01

f=[];ma =[]; nu=[];

P=inputParser;
addRequired(P,'variable',@isnumeric);
addRequired(P,'time',@isnumeric);
if length(variable)~=length(time)
    error('Data and time vector must be same length');
end

defaultSegLength = length(time);
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

parse(P,variable,time,varargin{:});
variable = P.Results.variable;
time = P.Results.time;
seglength = P.Results.seglength;
numseg = P.Results.numseg;
window = P.Results.window;
overlap = P.Results.overlap;
makeplot = P.Results.makeplot;
padding = P.Results.padding;
rescale = P.Results.rescale;
includemean = P.Results.includemean;
diagnostics = P.Results.diagnostics;

if seglength == length(time) && numseg==1
    s = variable;
    if size(s,1)==1
        s = s';
        if diagnostics; disp('Flipping input vector'); end
    end
    if diagnostics; disp('Full timeseries spectrum'); end
elseif seglength ~= length(time) && numseg ==1
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(s(:,end))
        s(:,end)=[]; % Removes the last vector since it might be partially empty
    end
    if diagnostics; disp('Segmenting according to seglength'); end
    seglength = size(s,1);
    numseg = size(s,2);
elseif seglength == length(time) && numseg ~=1
    seglength = ceil(length(time)/(numseg*(1-overlap)+overlap));
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    if ~all(s(:,end))
        s(:,end)=[]; % Removes the last vector since it might be partially empty
    end
    if diagnostics; disp('Segmenting according to numseg'); end
    seglength = size(s,1);
    numseg = size(s,2);
elseif seglength ~=length(time) && numseg ~=1
    s = buffer(variable,seglength,round(seglength*overlap),'nodelay'); %Partitions data into vectors of length seglength, with some overlap
    s = s(:,1:numseg);
    if diagnostics; disp('Segmenting according to seglength and numseg'); end
    seglength = size(s,1);
    numseg = size(s,2);
end

s = detrend(s,1);
vart = mean(sum(s.^2)/size(s,1)); 

if strcmp(window,'hanning')
    hannwin = hanning(seglength)*ones(1,size(s,2)); %Hanning window, a data analysis tool to emphasize central values, reducing spectral noise from mismatched segments
    s = s.*hannwin; %Scales the data by the hanning window
    if diagnostics; disp('Hanning window applied'); end
elseif ~strcmp(window,'none')
    error('Window not recognized');
else
    if diagnostics; disp('No windowing'); end
end

if padding>0
    npad=2^(ceil(log2(seglength))+padding-1); % Pad data with approx an equal number of zeros, but make it a power of 2
else
    npad=seglength;
end

S = fft(s,npad,1); %Fourier transform of data
p = size(S,1); %Vector of points in the frequency space
N = size(S,2); %Size

dt = mean(diff(time)); % Sampling interval
Fs = 1/dt; % Sampling frequency
T = seglength*dt; % Total length of record
df = Fs/npad; % Frequency increment
Ffun = 1/T; % Fundamental frequency

% Construct the frequency vector
if mod(p,2)==0
    k=0:p/2; %Use only half of the fourier transform since it's symmetric about its middle value
else
    k=0:(p-1)/2;
end
f = df*k; % Frequency axis;

% Construct the amplitude equared
if mod(p,2)==0
   a2=abs(S(1:p/2+1,:)).^2; %Magnitude squared of coefficient
   a2(2:end-1,:)=2*a2(2:end-1,:); % Double energy except at mean and central value
else
   a2=abs(S(1:(p+1)/2,:)).^2; %Magnitude squared of coefficient
   a2(2:end,:)=2*a2(2:end,:); % Double energy except at mean value
end

a2 = a2/(seglength*Fs); %Normalize by record length and sampling frequency

% Normalize the resulting spectra by accounting for the amplitude reduction
% from the window
if strcmp(window,'hanning')
    a2 = a2*8/3; %Normalize by the degree of freedom contribution due to the hanning window
    if diagnostics; disp('Normalizing by hanning window'); end
end

if strcmp(window,'hanning')
    nu = dof_calculator(seglength,numseg,window,overlap);
    if diagnostics; disp('Hanning window dof'); end
elseif strcmp(window,'none') && overlap~=0
    nu = dof_calculator(seglength,numseg,'boxcar',overlap);
    if diagnostics; disp('Degrees of freedom for overlaping square segments'); end
elseif overlap==0
    nu = N*2; %for no overlap
    if diagnostics; disp('Degrees of freedom for non-overlaping square segments'); end
end
ma = mean(a2,2,'omitnan'); %Mean across all segments

%Parseval's theorem

varf = sum(ma)*df;
pars = abs(varf - vart)/vart;
pars_rat = vart/varf; %should be 1
pars_str = 'Parsevals theorem: Timeseries variance is %0.5f; Spectral sum is %0.5f; Fraction difference is %0.5f; Ratio is %0.5f \n';
if diagnostics; fprintf(pars_str,vart, varf, pars, pars_rat); end

if rescale
    ma = ma*pars_rat;
    if diagnostics; disp('Rescaling to preserve variance'); end
end

% Truncate data at the fundamental frequency, to remove unreal zero-padded
% values
Ifun=find(f>=Ffun-eps,1);
if ~includemean
    f=f(Ifun:end);
    ma=ma(Ifun:end);
    if diagnostics; disp('Cutting output to fundamental frequency'); end
end

% Calculating error bars
err_high = nu/chi2inv(.05/2,nu); %Lower 5% confidence limit based on a chi2 distribution with nu degrees of freedom
err_low = nu/chi2inv(1-.05/2,nu); %Upper 95% confidence limit
ratio = err_high/err_low; %Ratio of errors, not used in the rest of the calculation

if makeplot
    colors; %This is a function of pretty colors I made
    figure('Name','Spectrum'); %Plot spectra with confidence intervals
        plot(f(2:end),ma(2:end),'Color',color.r); %Ignores the first value since it's the mean at frequency zero and won't show up in a log plot
        hold on;
            patch([f(2:end) flip(f(2:end))],[err_high*ma(2:end)' ...  
            err_low*flip(ma(2:end))'],color.lr,'FaceAlpha',.3, ...
            'EdgeColor','none'); %Plots the confidence limits in a lighter color
        title('Amplitude Spectrum');
        %ylabel('||T||^2/N \Delta f [\circ C^2 day^{-1}]');
        ylabel('$\frac{||A||^2}{N \Delta f} ~ [[A]^2*s]$','Interpreter','latex','FontSize',16);
        xlabel('f [Hz]'); 
        xlim([f(1) f(end)]);
        hold off;
        set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
        %close
end
