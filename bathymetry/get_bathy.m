
function [XC,YC,Depth] = get_bathy(bathyfile,lon,lat)
% This function loads the bathymetry file for the desired lat,lon bounding region
% Gives a matrix of depths from the GMRT bathymetry data
%
%
% Input 
%   bathyfile = 'string_to_bathyfile.mat'
%	lon = [lon_min lon_max] (-90 to 90)
%	lat = [lat_min lat_max] (-180 to 180)
%
% Output
%   XC = 1xm vector of grid lon
%   YC = 1xn vector of grid lat
%   Depth = mxn matrix of depths
%
% Alex Andriatis
% 2020-10-30

  bathyobject = matfile(bathyfile);

  % Find closest model lat, lon
  [~,Ilats]=closest(bathyobject.YC,lat);
  [~,Ilons]=closest(bathyobject.XC,lon);

  % Save correct subset of bathymetry file
  XC = bathyobject.XC(1,Ilons(1):Ilons(end));
  YC = bathyobject.YC(1,Ilats(1):Ilats(end));
  Depth = bathyobject.Depth(Ilons(1):Ilons(end),Ilats(1):Ilats(end));
end
