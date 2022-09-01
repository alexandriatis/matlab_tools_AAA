function [gridded] = fill_interp_2d_gridded_AAA(x,y,data,interp,extrap)

[X,Y]=meshgrid(x,y);
I=~isnan(data);
xI = X(I);
yI = Y(I);
dataI = data(I);
F = scatteredInterpolant(xI,yI,dataI,interp,extrap);
gridded = F(X,Y);