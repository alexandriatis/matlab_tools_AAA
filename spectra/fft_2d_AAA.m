function [S,kx,ky] = fft_2d_AAA(variable,xdim,ydim,varargin)
% spectrum_2d computes the two dimensional power spectrum
%
% Inputs data, x, and y dimensions
% Outputs the spectrum, and two frequency dimensions, along with the
% degrees of freedom and the ratio of the deviation away from Parseval's
% theorem
%
% Examples:
% [ma,kx,ky] = spectrum_2d_test(zdata,xdata,ydata);
% Outputs the 2D PSD of zdata, with positive and negative frequencies in
% both directions
%
% [ma,kx,ky] = spectrum_2d_test(zdata,xdata,ydata,'window','hanning','segsize',floor(size(zdata)/3),'rescale',true,'overlap',0.5,'padding',2,'includemean',false);
% Applies hanning windows to each segment, makes segments that are 1/3 the
% size of the input matrix zdata, matches the total variance to the
% variance of the input submatrices, applies 50% overlap to segments - each
% point is sampled twice except the edes, zero-pads to the next highest
% power of two, NaNs central values that are lower frequency than the
% fundamental, and the mean.
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

defaultDiagnostics = false;
addParameter(P,'diagnostics',defaultDiagnostics,@islogical);

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
diagnostics = P.Results.diagnostics;

% Segmenting and overlap

if all(segsize == size(variable)) && numseg==0
    s = variable;
    if diagnostics; disp('Full matrix spectrum'); end
    numseg = 1;
else
    s = get_submatrix_AAA(variable,'segsize',segsize,'numseg',numseg,'overlap',overlap);
    if diagnostics; disp('Subsampling matrix'); end
    numseg = size(s,3);
end
segsize=size(s,[1 2]);
% Ok now s is potentially a NYxNXxNS matrix

% Detrend each entry in s
if diagnostics; disp(['Detrending ' num2str(numseg) ' slices']); end
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
    if diagnostics; disp('Hanning window applied'); end
elseif ~strcmp(window,'none')
    error('Window not recognized');
else
    if diagnostics; disp('No windowing'); end
end

if padding>0
    npad_y=2^(ceil(log2(size(s,1)))+padding-1); % Pad data to the next (padding-1)th power of 2
    npad_x=2^(ceil(log2(size(s,2)))+padding-1); % Pad data to the next (padding-1)th power of 2
    if diagnostics; disp(['Padding to ' num2str(npad_y) ' x ' num2str(npad_x)]); end
else
	npad_y = size(s,1);
    npad_x = size(s,2);
    if diagnostics; disp('No padding'); end
end


% 2D Fourier Transform
S=fftshift(fft2(squeeze(s(:,:,1)),npad_y,npad_x)); % Zero-centered 2D fft
S=zeros(size(S,1),size(S,2),numseg);
if diagnostics; disp(['Transforming ' num2str(numseg) ' slices']); end
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
end
