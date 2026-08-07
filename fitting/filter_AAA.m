function yfilt = filter_AAA(ydata,filtfreq,sfreq,ftype,order)
% filter_AAA implements a butterworth filter on a timeseries. 
% examples: 
%   yfilt = filter_AAA(ydata,[0.2,0.8],1,'bandpass',4);
%   yfilt = filter_AAA(ydata,[0.2 0.8];
%
% Inputs:
%   ydata:      A column vector. Didn't design this to handle matrices
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

if ~iscolumn(ydata)
    error('Filter input must be a column vector');
end
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

% For some reason, bandpass filtering doesn't work well
% Instead, I can hack this by recursively calling this function in high and
% low configuration
if strcmp(ftype,'bandpass')
    yfilt=filter_AAA(ydata,filtfreq(2),sfreq,'low',order);
    yfilt=filter_AAA(yfilt,filtfreq(1),sfreq,'high',order);

elseif strcmp(ftype,'stop')
    yfilt_l=filter_AAA(ydata,filtfreq(1),sfreq,'low',order);
    yfilt_h=filter_AAA(ydata,filtfreq(2),sfreq,'high',order);
    yfilt=yfilt_l+yfilt_h;
else

fNy = 0.5*sfreq;
if filtfreq./fNy >= 1
    error('filtering doesnt handle frequencies bigger than nyquist');
end
[b,a] = butter(order,filtfreq./fNy,ftype);

trend = trend_AAA([],ydata,1); % Detrend data before filtering
tmp = ydata-trend;
% To handle edge artifacts, pad the start and end of the data with half
% of the cutoff frequency number of points
edgepoints=round(sfreq/filtfreq(1)/2);
tmp2 = [flipud(tmp(1:edgepoints)); tmp; flipud(tmp(end-edgepoints+1:end))];
tmpfilt = filtfilt(b,a,tmp2);
yfilt = tmpfilt(edgepoints+1:end-edgepoints);
if strcmp(ftype,'low')
    yfilt = yfilt+trend;
end
end