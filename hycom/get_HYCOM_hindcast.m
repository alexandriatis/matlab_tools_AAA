function [D] = get_HYCOM_hindcast(time,lon,lat,depth,fname,sourcepath)
% This function grabs most recently available HYCOM hindcast
%  function [D] = get_HYCOM_hindcast(time,lon,lat,depth,fname,sourcepath);
% Inputs:
%   time, lon, lat, and depth can all be points or vectors
%   Time in matlab datenum. Code works better if you just give it one time.
%   Lon in -180:180 decimal degrees
%   Lat in -90:90 decimal degrees
%   Depth in meters, positive down from zero at surface
%     if Depth is a point, average will be from surface down
%     if Depth is a vector, average within depth range (nearest grid cell)
%   fname is a path where hycom fields are dumped after being read, ending
%   in the time of the file
%   sourcepath is the url link to the HYCOM data in case you want to use
%   something other than the default
%  
% Outputs:
%   D is a structure containing the following fields
%     D.Date: time closest to the requested time at which data is available (datenum)
%     D.Longitude: vector spanning the requested longitudes (-180:180 decimal degrees)
%     D.Latitude: vector spanning the requested latitudes (-90:90 decimal degrees)
%     D.Depth: vector spanning the requested depths (m), positive downwards
%     D.ssh: sea surface heigth (m), positive upwards
%     D.temperature: potential temperature (deg C)
%     D.salinity: absolute salinity (g/kg)
%     D.u: east-west velocity (m/s, positive east)
%     D.v: north-south velocity (m/s, positive north)
%
% Alex Andriatis
% 10-03-2020

uvswitch = 0; % Turn on 1 to just save u and v

 % load HYCOM grid
 if exist('sourcepath','var')
    OpenDAP_URL = sourcepath;
 else
    OpenDAP_URL = 'http://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0'; % Best hindcast reanalysis file
 end

 % Time
 param = 'time';
  time_origin = ncreadatt(OpenDAP_URL,param,'units');
  time_origin = time_origin(13:31);
  time_origin = datenum(time_origin,'yyyy-mm-dd HH:MM:SS');
  hycom_time = ncread(OpenDAP_URL,param);
  hycom_time = datenum(hycom_time./24) + time_origin;
  % Find HYCOM time index corresponding closest to the time of interest
  if length(time)>1
    [closestval,I] = closest(hycom_time,[time(1) time(end)],1);
  else
    [closestval,I] = closest(hycom_time,[time time],1);
  end
  tmin = I(1); tmax = I(2); nt = tmax-tmin+1;
  hycom_time = ncread(OpenDAP_URL,param,tmin,nt);
  D.time = datenum(hycom_time./24) + time_origin;

  % The closest available time might not match the requested time - check if the corresponding file exists already, skip the rest of the code if it does 
  savename = [fname datestr(D.time(1),'yyyymmddTHHMMSS') '.mat'];
  if exist(savename,'file')
	  disp(['The requested start time is ' datestr(time(1)) ' but the closest HYCOM time is ' datestr(D.time(1)) ' and a file already exists with that start time.']);
	  D=[];
	  return
  end
 
  
 % Latitude
  param = 'lat';
  hycom_lat = ncread(OpenDAP_URL,param);
  % Find range of HYCOM indices corresponding to the region
  [closestval,I] = closest(hycom_lat,[lat(1) lat(end)],1);
  if length(lat)>1
    if closestval(1)>lat(1)
      I(1)=I(1)-1;
    end
    if closestval(2)<lat(end)
      I(2) = I(2)+1;
    end
    ymin = I(1); ymax = I(2); ny = ymax-ymin+1;
  else
    ymin = I(1); ny=1;
  end  
  D.latitude = ncread(OpenDAP_URL,param,ymin,ny);
  
 % Longitude
 param = 'lon';
  hycom_lon = ncread(OpenDAP_URL,param);
  lon(lon<0)=lon(lon<0)+360;
  [closestval,I] = closest(hycom_lon,[lon(1) lon(end)],1);
  if length(lon)>1
    if closestval(1)>lon(1)
      I(1)=I(1)-1;
    end
    if closestval(2)<lon(end)
      I(2) = I(2)+1;
    end
    xmin = I(1); xmax = I(2); nx = xmax-xmin+1;
  else
    xmin = I(1); nx=1;
  end
  D.longitude = ncread(OpenDAP_URL,param,xmin,nx);
  D.longitude(D.longitude>180) = D.longitude(D.longitude>180)-360;
  
 % Depth
 param = 'depth';
  hycom_z = ncread(OpenDAP_URL,param);
  depth(depth<0)=-depth(depth<0);
  % Find range of HYCOM indices corresponding to the region
  if length(depth)>1
    [closestval,I] = closest(hycom_z,[depth(1) depth(end)],1);
  else
    [closestval,I] = closest(hycom_z,[depth depth],1);
  end
  zmin = I(1); zmax = I(2); nz = zmax-zmin+1;
  D.depth = ncread(OpenDAP_URL,param,zmin,nz);

% 2D Fields: SSH
if ~uvswitch
    params = {'surf_el'};
      plab = {'ssh'};
      np = length(params);
      scale = [0.001];
      offset = [0];
      missvalue = -30000;
      for ip = 1:np
          param = params{ip};
          lab = plab{ip};
          
            param
            lab
            xmin
            ymin
            tmin
            nx
            ny
            nt
  
          tmp = ncread(OpenDAP_URL,param,[xmin,ymin,tmin],[nx,ny,nt]);
          tmp(tmp == missvalue) = nan;
          tmp = tmp.*scale(ip) + offset(ip);
          eval(['D.' lab ' = tmp;']);
          clear tmp param
      end
end

% 3D Fields: T, S, U, V
if uvswitch
  params = {'water_u','water_v'};
  plab = {'u','v'};
  np = length(params);
%  scale = [0.001, 0.001]; These are for old-style hycom data
  scale = [1, 1];
  offset = [0, 0];
  missvalue = -30000;
else
  params = {'water_temp', 'salinity', 'water_u', 'water_v'};
  plab = {'temperature','salinity','u','v'};
  np = length(params);
  % Scale and offset for old-style hycom data
  %scale = [0.001, 0.001, 0.001, 0.001];
  %offset = [20, 20, 0, 0];
  scale = [1,1,1,1];
  offset = [0,0,0,0];
  missvalue = -30000;
end
for ip = 1:np
  param = params{ip};
  lab = plab{ip};
  param
  lab
  xmin
  ymin
  zmin
  tmin
  nx
  ny
  nz
  nt
  tmp = ncread(OpenDAP_URL,param,[xmin,ymin,zmin,tmin],[nx,ny,nz,nt]);
  tmp(tmp == missvalue) = nan;
  tmp = tmp.*scale(ip) + offset(ip);
  eval(['D.' lab ' = tmp;']);
  clear tmp param
end
  
% Make sure missing values are NaN, based on where salinity is NaN or zero
if ~uvswitch
  D.salinity(D.salinity==0)=nan;
  I = isnan(D.salinity);
  D.temperature(I)=nan;
  D.u(I)=nan;
  D.v(I)=nan;
  D.ssh(squeeze(I(:,:,1,:)))=nan;

  D.ssh = squeeze(D.ssh);
  D.temperature = squeeze(D.temperature);
  D.salinity = squeeze(D.salinity);
else
  D.u = squeeze(D.u);
  D.v = squeeze(D.v);
end

% Save hycom data as matlab file with structure D 
  save(savename,'-struct','D','-v7.3');
  disp(['HYCOM data saved in ' savename]);
end
