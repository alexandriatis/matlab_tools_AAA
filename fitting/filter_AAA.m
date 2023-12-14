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
    tmp = ydata(i,:);
    trend = trend_AAA(1:length(tmp),tmp,1); % Detrend data before filtering
    tmp = tmp-trend;
    % To handle edge artifacts, pad the start and end of the data with half
    % of the cutoff frequency number of points
    edgepoints=round(sfreq/filtfreq(1)/2);
    tmp2 = [fliplr(tmp(1:edgepoints)) tmp fliplr(tmp(end-edgepoints+1:end))];
    tmpfilt = filtfilt(b,a,double(tmp2));
    yfilt(i,:)=tmpfilt(edgepoints+1:end-edgepoints);
    if strcmp(ftype,'low')
        yfilt(i,:) = yfilt(i,:)+trend;
    end
end