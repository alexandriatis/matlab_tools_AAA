%% This script turns a GMRTv3 file into a gridded bathymetry
% Get the file from here: https://www.gmrt.org/GMRTMapTool/
%
% 
% Alex Andriatis
% 2020-12-09

addpath(genpath('~/Documents/MATLAB'));
ccc;

%% Variables to change:

bathypath = '/Volumes/Andriatis_T7/DATA/TFO/BATHY';
bathyname = 'GMRTv3_8_20201018topo.grd';

griddedname = 'bathy_TFO_GMRTv3.mat';

%% Load bathymetry

fname = fullfile(bathypath,bathyname);
ncdisp(fname);

x_range = ncread(fname,'x_range');
y_range = ncread(fname,'y_range');
z_range = ncread(fname,'z_range');
spacing = ncread(fname,'spacing');
dimension = ncread(fname,'dimension');
z = ncread(fname,'z');

lon = x_range(1):spacing(1):x_range(2);
lat = y_range(1):spacing(2):y_range(2);

if length(lon)~= dimension(1)
    error('Length of longitude vector does not match dimension');
end
if length(lat)~= dimension(2)
    error('Length of latitude vector does not match dimension');
end

depth = reshape(z,dimension(1),dimension(2));
depth = fliplr(depth);

%% Save variables
XC = lon;
YC = lat;
Depth = depth;
save(fullfile(bathypath,griddedname),'XC','YC','Depth','-v7.3');

%% Plot bathymetry to test
figure;
  imagescnan(XC,YC,Depth'); axis xy; cmocean('topo','pivot',0); map_aspectratio; colorbar;
  figname = 'bathy_TFO_GMRTv3';
  saveas(gcf,fullfile(bathypath,figname),'png');
  close;


