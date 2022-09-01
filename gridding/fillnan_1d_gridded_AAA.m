function [x,y]=fillnan_1d_gridded_AAA(x,y,xgrid,xdif)
% This function fills in a timeseries with NaNs where previously there were
% missing time chunks. Useful for windowed spectral analysis where instead
% of linearly interpolating over gaps we just want to eliminate them.
%
% Alex Andriatis
% 02-15-2022

% First, fill gaps in the timeseries with NaNs.
[x,y] = interp_sort_AAA(x,y);
[y] = fill_interp_1d_AAA(x,y);
[x,y] = contour_gaps(x,y,xdif);
% Next, bin the data
[x,y]=binning_1d_AAA(x,y,xgrid,'InterpFill','none');
end