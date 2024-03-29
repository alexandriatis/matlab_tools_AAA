function [ma,kx,ky,nu,npad] = spectrum_2d_test(variable,xdim,ydim,varargin)
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

defaultPortion='all';
checkString=@(s) any(strcmp(s,{'all','right','top'}));
addParameter(P,'portion',defaultPortion,checkString);

defaultIncludeMean = false;
addParameter(P,'includemean',defaultIncludeMean,@islogical);

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
includemean = P.Results.includemean;


% Segmenting and overlap

if all(segsize == size(variable)) && numseg==0
    s = variable;
    disp('Full matrix spectrum');
    numseg = 1;
else
    s = get_submatrix_AAA(variable,'segsize',segsize,'numseg',numseg,'overlap',overlap);
    disp('Subsampling matrix');
    numseg = size(s,3);
end
segsize=size(s,[1 2]);
% Ok now s is potentially a NYxNXxNS matrix

% Detrend each entry in s
disp(['Detrending ' num2str(numseg) ' slices']);
for n=1:numseg
    s(:,:,n)=detrend_2d(squeeze(s(:,:,n)));%Removes linear plane fit as described in https://www.mathworks.com/matlabcentral/fileexchange/33192-flatten-a-data-in-2d
    %disp(['Detrending Slice ' num2str(n)]);
end

% Compute variance before windowing
vart = var(s,0,'all','omitnan');

% Windowing
if strcmp(window,'hanning')
    %Hanning window, a data analysis tool to emphasize central values, reducing spectral noise from mismatched segments
    hannwin_2d = hanning(size(s,1))*hanning(size(s,2))';
    s=s.*repmat(hannwin_2d,[1 1 numseg]);
    disp('Hanning window applied');
elseif ~strcmp(window,'none')
    error('Window not recognized');
else
    disp('No windowing');
end

if padding>0
    npad_y=2^(ceil(log2(size(s,1)))+padding-1); % Pad data to the next (padding-1)th power of 2
    npad_x=2^(ceil(log2(size(s,2)))+padding-1); % Pad data to the next (padding-1)th power of 2
    disp(['Padding to ' num2str(npad_y) ' x ' num2str(npad_x)]);
else
	npad_y = size(s,1);
    npad_x = size(s,2);
    disp('No padding');
end


% 2D Fourier Transform
S=fftshift(fft2(squeeze(s(:,:,1)),npad_y,npad_x)); % Zero-centered 2D fft
S=zeros(size(S,1),size(S,2),numseg);
disp(['Transforming ' num2str(numseg) ' slices']);
for n=1:numseg
    S(:,:,n)=fftshift(fft2(squeeze(s(:,:,n)),npad_y,npad_x)); % Zero-centered 2D fft
    %disp(['Transforming Slice ' num2str(n)]);
end

l = size(S,1);
g = size(S,2);
dx = mean(diff(xdim));
dy = mean(diff(ydim)); % Size of interval between consecutive measurements

Fx = 1/dx; % Sampling frequency
Fy = 1/dy;

dfx = Fx/npad_x; % Frequency increment
dfy = Fy/npad_y;

Tx = segsize(2)*dx; % Total length of record
Ty = segsize(1)*dy;
Ffunx = 1/Tx; % Fundamental frequency
Ffuny = 1/Ty; % Fundamental frequency

% Construct the frequecny vector

if mod(l,2)==0
    m=-l/2:l/2-1; %Use only half of the fourier transform since it's symetric about its middle value
else
    m=-(l-1)/2:(l-1)/2;
end
if mod(g,2)==0
    h=-g/2:g/2-1; %Use only half of the fourier transform since it's symetric about its middle value
else
    h=-(g-1)/2:(g-1)/2;
end

kx=dfx*h;
ky=dfy*m;

a2=abs(S).^2/(segsize(1)*Fx*segsize(2)*Fy);
 
if strcmp(portion,'all')
    
elseif strcmp(portion,'right')
    if mod(g,2)==0
        kx=kx(g/2+1:end);
        a2=a2(:,g/2+1:end,:);
        a2(:,2:end-1,:)=2*a2(:,2:end-1,:);
    else
        kx=kx((g+1)/2:end);
        a2=a2(:,(g+1)/2:end,:);
        a2(:,2:end,:)=2*a2(:,2:end,:);
    end
elseif strcmp(portion,'top')
    if mod(l,2)==0
        ky=ky(l/2+1:end);
        a2=a2(l/2+1:end,:,:);
        a2(2:end-1,:,:)=2*a2(2:end-1,:,:);
    else
        ky=ky((l+1)/2:end);
        a2=a2((g+1)/2:end,:,:);
        a2(2:end,:,:)=2*a2(2:end,:,:);
    end
else
    error('You didnt handle other quadrants');
end

% Normalize the resulting spectra by accounting for the amplitude reduction
% from the window
if strcmp(window,'hanning')
    a2 = a2*(8/3).^2; %Normalize by the degree of freedom contribution due to the hanning window
    disp(['Rescaling for hanning window']);
end

ma = mean(a2,3,'omitnan'); %Mean across all segments

% No idea what to do about degrees of freedom
nu = 0; %dont' know how to calculate nu yet

%Parseval's theorem

varf = sum(ma,'all')*dfx*dfy;
pars = abs(varf - vart)/vart;
pars_rat = vart/varf; %should be 1
pars_str = 'Parsevals theorem: Timeseries variance is %0.5f; Spectral sum is %0.5f; Fraction difference is %0.5f; Ratio is %0.5f \n';
fprintf(pars_str,vart, varf, pars, pars_rat);

if rescale
    ma = ma*pars_rat;
    disp('Rescaling to preserve variance');
end

% Truncate data at the fundamental frequency, to remove unreal zero-padded
% values
if ~includemean
    [KX,KY]=meshgrid(ky,ky);
    ksq=(KY.^2+KX.^2).^(1/2);
    ma(ksq<max(Ffuny,Ffunx))=NaN;
end
npad=[npad_y npad_x];
end
