function [trend,b]=loglinfit_AAA(xdata,ydata,m)
% This function is for performing a linear fit in log space with a
% perscribed spectral slope
b = mean(log10(ydata)-m*log10(xdata));
trend=logline_AAA(xdata,m,b);