function yfilt = filter_AAA(ydata,filtfreq,sfreq,ftype,order)
% filter_AAA implements a butterworth filter on a timeseries. 
% examples: 
%   yfilt = filter_AAA(ydata,[0.2,0.8],1,'bandpass',4);
%   yfilt = filter_AAA(ydata,[0.2 0.8];
%
% Inputs:
%   ydata:      Can be either a vector or a matrix, where the filtering acts along the 2nd dimension, looping over the 1st
%   filtfreq:   The cutoff frequency, either a number or a pair for bandpass / bandgap filters.
%   sfreq:      Sampling frequency = 1/dx. (default = 1 Hz)
%   ftype:      Filter type, either 'low','high','bandpass',or 'stop' (default = 'low' for single or 'bandpass' for double
%   order:      Butterworth filter order (default = 4).
%
% Outputs:
%   yfilt:      The vector or matrix, after filtering.
%
% Alex Andriatis
% 07-20-2022

yfilt = NaN(size(ydata));
if isempty(filtfreq) || length(filtfreq)>2
    error('filtfreq must be either one or two numbers');
end
    
if ~exist('sfreq','var')
    sfreq=1;
end

if ~exist('ftype','var')
    if length(filtfreq)==1
        ftype='low';
    else
        ftype='bandpass';
    end
end

if ~exist('order','var')
    order=4;
end

fNy = 0.5*sfreq;
[b,a] = butter(order,filtfreq./fNy,ftype);

for i=1:size(ydata,1)
    yfilt(i,:)=filtfilt(b,a,ydata(i,:));
end