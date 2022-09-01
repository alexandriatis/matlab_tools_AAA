function data = adcp_shear_AAA(data,dz_shear)
% function data = adcp_shear_AAA(data,dz_shear)
%
% This function is made for calculating the shear from an ADCP record. The
% function smooths the data using a low-pass fiter for a cutoff wavenumber
% specified by dz_shear, with a default value of 8 meters.
%
% Loosely based on Matthew's AddSheartoCTD.m
%
% Inputs:
%   data: a structure with fields "u","v" and "depth", where u and v can
%   be matrices or vectors with the first dimension depth.
%   Depth must be unfiormly-gridded in space
%
%   Optional:
%       dz_shear: The vertical smoothing distance for shear calculations
%
% Outputs:
%   data: a structure that has fields "dudz", "dvdz" and "shear2"
%
% Alex Andriatis
% 2021-03-23
%
% 
if ~exist('dz_shear','var') % Default smoothing of 8 meters
    dz_shear = 8;
end

%% 1. Check that depth data is uniformly-gridded.
if var(diff(data.depth))~=0
    error('Data is not uniformly-gridded in depth');
end
dz = abs(mean(diff(data.depth))); % Depth step

%% 2. Design a filter 
fcutoff = 1/(dz_shear); % Cutoff wavenumber for low-pass filter
fNy = 1/(2*dz); % Nyquist frequency of the data

if fcutoff>=fNy
    tofilter=0;
else
    Wn = fcutoff/fNy; % Scaled cutoff
    [b,a] = butter(4,Wn,'low'); % A 4th-order lowpass butterworth filter
    tofilter=1;
end

%% 3. Loop over each timestep in both the u and v directions
% Check for NaNs, fill in missing data, smooth data, calculate shear
varnames={'u','v'};
shearnames={'dudz','dvdz'};
% Loop over both u and v directions
for n=1:length(varnames)
    varname = varnames{n};
    disp(['Calculating shear for variable ' varname]);
    vel = data.(varname);
    dveldz = NaN(size(vel));
    % Loop over time
    for t=1:size(vel,2)
        tmp = vel(:,t);
        % Remove nans from the data
        I = ~isnan(tmp);
        if sum(I)<2
            continue
        end
        tmpz = data.depth(I);
        tmp = tmp(I);
        % If points have been removed in the interior, linearly interpolate over them
        if var(diff(tmpz))~=0 
           zgrid = tmpz(1):dz:tmpz(end);
           tmp = interp1(tmpz,tmp,zgrid);
           tmpz = zgrid;
        end
        if tofilter
            % Low-pass the data
            tmp = filtfilt(b,a,tmp);
        end
        % Calculate the vertical gradients
        dtmpdz = gradient(tmp)./gradient(tmpz);
        % Add the nans back into the data 
        dtmpdz = interp1(tmpz,dtmpdz,data.depth);
        dtmpdz(~I)=NaN;
        dveldz(:,t) = dtmpdz;
    end
    data.(shearnames{n})=dveldz;
end
data.shear2 = data.dudz.^2 + data.dvdz.^2;