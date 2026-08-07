function fcont_lev = fcont_per_AAA(zdata,nper)
% fcont_per_AAA gets the colorbar limits to the central nper percentile of the data range
%
% Usage: 
%   fcont_lev = fcont_per_AAA(zdata); % Get the limits of the central 99%
%   percent of data
%   clim(fcont_lev); % Set the colorbar to the central limits
%
% Examples:
%   fcont_per_AAA(zdata,1) bounds all the non-NaN data
%   fcont_per_AAA(zdata,0.9545) bounds the central 2 sigma
%
% Inputs:
%   zdata: A matrix or vector of data, typically used for a countour plot
%   nper:  A fraction giving the central % of data to include in the color limits 
if ~exist('nper','var')
    nper=0.99; % 99% of data
end
if nper<0 || nper>1
    error('nper must be a fraction between 0 and 1');
end
p=[0.5-nper/2 0.5+nper/2];
zdata=zdata(~isnan(zdata));
fcont_lev=prctile(zdata,p*100,'all');