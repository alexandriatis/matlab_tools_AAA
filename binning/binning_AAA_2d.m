function [V,X,Y,counts]=binning_AAA_2d(x,y,v,xbins,ybins,varargin)
% This fucntion is designed to bin data 
%
% Alex Andriatis
% 2021-08-13
%
% Improved to handle 2-d binning (just 1-d binning with a for loop)
% 2022-05-30
%
% Added the ability to use weighted binning
% 2023-03-23
%
% Created a code that takes a vector and bins into an x-y grid
% Useful for binning disparate, unordered lat-lon data
%
% Rewite this section:
%
% Example: data_binned = binning_AAA(x,data,bin_centers)
%          data_binned = binning_AAA(x,data,bin_edges,'BinCentering','edges') % Uses bins as defined by their edges
%          data_binned = binning_AAA(x,data,bin_centers,'InterpFill','interp') % If some bins are blank, fill in the missing data with linear interpolation
%          data_binned = binning_AAA(x,data,bin_edges,'BinCentering','edges','InterpFill','extrap') % Also extrapolate out to the edges of bins with linear extrapolation
%          data_binned = binning_AAA(x,data,bin_centers,'weights',weights) %Uses weighted mean for binning, with weights either 1D or 2D 
%
%
% Inputs:
%         x: the points that data in y is associated with, can either be the x or y axis of a 2-d data set
%         y: the data to be binned. Can either be a vector of length x or a matrix with one of the dimensions is length x
%         bins: the centerpoint of the bins onto which to map the data. If using bins defined by edges, use option 'BinCentering','edges'
%
% Outputs:
%         y_binned: the data binned into bins
%         x_center: if using centered bins, equivalent to input bins. If using edges, the centerpoint of bins, length(bins)-1


P=inputParser;
addRequired(P,'x',@isnumeric);
addRequired(P,'y',@isnumeric);
addRequired(P,'v',@isnumeric);
addRequired(P,'xbins',@isnumeric);
addRequired(P,'ybins',@isnumeric);

defaultEdges = 'center';
checkString=@(s) any(strcmp(s,{'center','edges'}));
addParameter(P,'BinCentering',defaultEdges,checkString);

defaultInterpFill = 'none';
checkString=@(s) any(strcmp(s,{'none','interp','extrap'}));
addParameter(P,'InterpFill',defaultInterpFill,checkString);

defaultWeights = 1;
addParameter(P,'weights',defaultWeights,@isnumeric);

parse(P,x,y,v,xbins,ybins,varargin{:});
x = P.Results.x;
y = P.Results.y;
v = P.Results.v;
xbins = P.Results.xbins;
ybins = P.Results.ybins;
BinCentering = P.Results.BinCentering;
InterpFill = P.Results.InterpFill;
weights = P.Results.weights;

use_edges=0;
if exist('option','var')
    if strcmp(option,'edges')
        use_edges=1;
    end
end

if ~(isequal(size(x),size(y),size(v)) & isvector(v) & size(v,2)==1)
    error('Inputs must be column vectors of equal size')
end

if ~isvector(xbins) || ~isvector(ybins)
    error('Input bins must be a vector');
end

if isvector(weights)
    if length(weights)==1
        weights=weights.*ones(size(v));
    elseif numel(weights)==numel(v)
        weights=weights(:);
    else
        error('Size of weights must match data');
    end
end
    
% Make sure x and y bins are column vectors
xbins=xbins(:);
ybins=ybins(:);

if strcmp(BinCentering,'center')
    xedges(1)=xbins(1);
    xedges(2:length(xbins))=xbins(1:end-1)+diff(xbins)/2;
    xedges(length(xbins)+1)=xbins(end);
    x_center = xbins;
    
    yedges(1)=ybins(1);
    yedges(2:length(ybins))=ybins(1:end-1)+diff(ybins)/2;
    yedges(length(ybins)+1)=ybins(end);
    y_center = ybins;
    
elseif strcmp(BinCentering,'edges')
    xedges = xbins;
    x_center = xedges(1:end-1)+diff(xedges)/2;
    yedges = ybins;
    y_center = yedges(1:end-1)+diff(yedges)/2;
else
    error('Unrecognized bin option');
end

NBx = length(x_center);
bin_indx = discretize(x,xedges);
Ix=~isnan(bin_indx);

NBy = length(y_center);
bin_indy = discretize(y,yedges);
Iy=~isnan(bin_indy);

x=x(Ix&Iy);
y=y(Ix&Iy);
v=v(Ix&Iy);
weights=weights(Ix&Iy);
bin_indx=bin_indx(Ix&Iy);
bin_indy=bin_indy(Ix&Iy);

V=NaN(NBy,NBx);
counts=V;
counter=ones(size(v));

for i=1:NBx
    I2=find(bin_indx==i);
    count_binned = accumarray(bin_indy(I2),counter(I2),[NBy,1],@(x)sum(x),0);
    tmp_v = accumarray(bin_indy(I2),weights(I2).*v(I2),[NBy,1],@(x)sum_AAA(x,'omitnan'),NaN)./accumarray(bin_indy(I2),weights(I2).*~isnan(v(I2)),[NBy,1],@(x)sum_AAA(x,'omitnan'),NaN);

    V(:,i)=tmp_v;
    counts(:,i)=count_binned;
end

[X,Y]=meshgrid(x_center,y_center);
end






