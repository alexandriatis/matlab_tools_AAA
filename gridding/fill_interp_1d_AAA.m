function [filled] = fill_interp_1d_AAA(x,data,extrap)
% This function fills over nans in the data with linear interpolation
dor = orientation_1d_AAA(data);
I=~isnan(data);
xI = x(I);
dataI = data(I);
if exist('extrap','var') && strcmp(extrap,'extrap')
    filled = interp1(xI,dataI,x,'linear','extrap');
else
    filled = interp1(xI,dataI,x,'linear');
end
filled = orient_1d_AAA(filled,dor);
end