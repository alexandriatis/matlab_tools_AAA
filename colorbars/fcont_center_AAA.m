function fcont_lev = fcont_center_AAA(fcont_lev,fcenter)
% fcont_center_AAA centers the target contour levels aroudn a mean
% Most useful for plotting velocity where you want white to be in the
% midddle
%
% Usage: 
%   fcont_lev=fcont_per_AAA(zdata);
%   fcont_lev = fcont_center_AAA(fcont_lev,0);
%   % Using the 99% range of velocity data, centers the colorbar range to
%   include the fullrange around a given mean
%
% Examples:
%   fcont_per_AAA(fcont_lev) centers color bounds on 0
%   fcont_per_AAA(fcont_lev,3) bounds the central 2 sigma
%
% Inputs:
%   zdata: A matrix or vector of data, typically used for a countour plot
%   nper:  A fraction giving the central % of data to include in the color limits 
if ~exist('fcenter','var')
    fcenter=0;
end
fcont_lev=[fcenter-max(abs(fcont_lev-fcenter)) fcenter+max(abs(fcont_lev-fcenter))];