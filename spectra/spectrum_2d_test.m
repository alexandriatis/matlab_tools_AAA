function [k,f,ma,nu] = spectrum_2d_test(variable,xdim,ydim,varargin)
% spectrum_2d computes the two dimensional power spectrum
%
% Inputs data, x, and y dimensions
% Outputs the spectrum, and two frequency dimensions, along with the
% degrees of freedom and the ration of the deviation away from Parseval's
% theorem
%
% Alex Andriatis
% 2023-04-02

f=[];k=[];ma =[]; nu=[];

P=inputParser;
addRequired(P,'variable',@isnumeric);
addRequired(P,'xdim',@isnumeric);

if size(variable,2)~=length(xdim)
    if size(variable',2)~=length(xdim)
        error('Data and x-dim vector must be same length');
    end
    variable = variable';
end

addRequired(P,'ydim',@isnumeric);
if size(variable,1)~=length(ydim)
   error('Data and y-dim vector must be same length');
end

defaultSegSize = size(variable);
addParameter(P,'segsize',defaultSegSize,@isnumeric);

defaultNumSeg = 0;
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

defaultMakePlot=false;
addParameter(P,'makeplot',defaultMakePlot,@islogical);

defaultPortion='all';
checkString=@(s) any(strcmp(s,{'all','right','top'}));
addParameter(P,'portion',defaultPortion,checkString);

parse(P,variable,xdim,ydim,varargin{:});
variable = P.Results.variable;
xdim = P.Results.xdim;
ydim = P.Results.ydim;
segsize = P.Results.segsize;
numseg = P.Results.numseg;
window = P.Results.window;
overlap = P.Results.overlap;
makeplot = P.Results.makeplot;
padding = P.Results.padding;
rescale = P.Results.rescale;
portion = P.Results.portion;


% Segmenting and overlap

if all(segsize == size(variable)) && numseg==0
    s = variable;
    disp('Full matrix spectrum');
    numseg = 1;
else
    s = get_submatrix_AAA(variable,'segsize',segsize,'numseg',numseg,'overlap',0.5);
    disp('Subsampling matrix');
    numseg = size(s,3);
end

% Ok now s is potentially a NYxNXxNS matrix

% Detrend each entry in s
for n=1:numseg
    s(:,:,n)=detrend_2d(squeeze(s(:,:,n)));%Removes linear plane fit as described in https://www.mathworks.com/matlabcentral/fileexchange/33192-flatten-a-data-in-2d
end

% Compute variance before windowing

vart = var(s,0,[1 2]);

% Skipping windowing for now
% if strcmp(window,'hanning')
%     hannwin = hanning(seglength)*ones(1,size(s,2)); %Hanning window, a data analysis tool to emphasize central values, reducing spectral noise from mismatched segments
%     s = s.*hannwin; %Scales the data by the hanning window
%     %disp('Hanning window applied');
% elseif ~strcmp(window,'none')
%     error('Window not recognized');
% else
%     %disp('No windowing');
% end

S = fft2(s); %2D Fourier transform of data
S = fftshift(S); %Zero-centered fft

l = size(S,1);
g = size(S,2);
deltax = mode(diff(xdim));
deltay = mode(diff(ydim)); % Size of interval between consecutive measurements

if strcmp(portion,'all')
    if mod(l,2)==0
        m=-l/2:l/2-1; %Use only half of the fourier transform since it's symetric about its middle value
    else
        m=-(l-1)/2:(l-1)/2;
    end
    X = l*deltay; % Total length of record
    k = m/X; % Wavenumber axis

    if mod(g,2)==0
        h=-g/2:g/2-1; %Use only half of the fourier transform since it's symetric about its middle value
    else
        h=-(g-1)/2:(g-1)/2;
    end
    T = g*deltax; % Total length of record
    f = h/T; % Frequency axis
    
    a2 = abs(S).^2/(l^2*g^2)*(X*T); % Normalize by number of points and frequency increment
 
elseif strcmp(portion,'right')
    if mod(l,2)==0
        m=-l/2:l/2; %Use only half of the fourier transform since it's symetric about its middle value
    else
        m=-(l-1)/2:(l-1)/2;
    end
    X = l*deltay; % Total length of record
    k = m/X; % Wavenumber axis
    
    T = g*deltax; % Total length of record
    if mod(g,2)==0
        h=0:g/2; %Use only half of the fourier transform since it's symetric about its middle value
        a2 = abs(S(:,g/2+1:end)).^2/(l^2*g^2)*(X*T); % Normalize by number of points and frequency increment
    else
        h=0:(g-1)/2;
        a2 = abs(S(:,(g+1)/2:end)).^2/(l^2*g^2)*(X*T); % Normalize by number of points and frequency increment
    end
    f = h/T; % Frequency axis
    a2(:,2:end-1) = 2*a2(:,2:end-1);
elseif strcmp(portion,'top')
    X = l*deltay; % Total length of record
    T = g*deltax; % Total length of record
    if mod(l,2)==0
        m=0:l/2; %Use only half of the fourier transform since it's symetric about its middle value
        a2 = abs(S(l/2+1:end,:)).^2/(l^2*g^2)*(X*T); % Normalize by number of points and frequency increment
    else
        m=0:(l-1)/2;
        a2 = abs(S((l+1)/2:end,:)).^2/(l^2*g^2)*(X*T); % Normalize by number of points and frequency increment
    end
    k = m/X; % Wavenumber axis

    if mod(g,2)==0
        h=-g/2:g/2; %Use only half of the fourier transform since it's symetric about its middle value
    else
        h=-(g-1)/2:(g-1)/2;
    end
    f = h/T; % Frequency axis
    a2(:,2:end) = 2*a2(:,2:end);
else
    error('You didnt handle other quadrants');
end

ma = a2;
    
%a2(2:end-1,:)=2*a2(2:end-1,:); %Except at mean and central, energy gets doubled because that's how spectra work

% if strcmp(window,'hanning')
%     a2 = a2*8/3; %Normalize by the degree of freedom contribution due to the hanning window
%     nu = dof_calculator(seglength,numseg,window,overlap);
%     %disp('Hanning window normalization')
% elseif strcmp(window,'none') && overlap~=0
%     nu = dof_calculator(seglength,numseg,'boxcar',overlap);
%     %disp('Degrees of freedom for overlaping square segments')
% elseif overlap==0
%     nu = N*2; %for no overlap
%     %disp('Degrees of freedom for non-overlaping square segments')
% end
%ma = mean(a2,2); %Mean across all segments

%Parseval's theorem

varf = sum(sum(ma))/(X*T);
pars = abs(varf - vart)/vart;
pars_rat = vart/varf; %should be 1
pars_str = 'Parsevals theorem: Timeseries variance is %0.5f; Spectral sum is %0.5f; Fraction difference is %0.5f; Ratio is %0.5f \n';
fprintf(pars_str,vart, varf, pars, pars_rat);
nu = 0; %dont' know how to calculate nu yet

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
%         ylabel('$\frac{||A||^2}{N^2 \Delta f} ~ [[A]^2*s]$','Interpreter','latex','FontSize',16);
%         xlabel('f [Hz]'); 
%         xlim([f(1) f(end)]);
%         hold off;
%         set(gca, 'XScale', 'log', 'YScale','log'); % Sets log scale
%         %close
% end
