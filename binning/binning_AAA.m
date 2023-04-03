function [y_binned,x_center]=binning_AAA(x,y,bins,varargin)
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
addRequired(P,'bins',@isnumeric);

defaultEdges = 'center';
checkString=@(s) any(strcmp(s,{'center','edges'}));
addParameter(P,'BinCentering',defaultEdges,checkString);

defaultInterpFill = 'none';
checkString=@(s) any(strcmp(s,{'none','interp','extrap'}));
addParameter(P,'InterpFill',defaultInterpFill,checkString);

defaultWeights = 1;
addParameter(P,'weights',defaultWeights,@isnumeric);

parse(P,x,y,bins,varargin{:});
x = P.Results.x;
y = P.Results.y;
bins = P.Results.bins;
BinCentering = P.Results.BinCentering;
InterpFill = P.Results.InterpFill;
weights = P.Results.weights;

use_edges=0;
if exist('option','var')
    if strcmp(option,'edges')
        use_edges=1;
    end
end

if ~isvector(x)
    error('Input x must be a vector');
end
if ~isvector(bins)
    error('Input bins must be a vector');
end
if ~ismatrix(y)
    error('Can only bin 1 or 2-d data');
end
xorient = orientation_1d_AAA(x);

[M,N]=size(y);
compcase = 0;
if isvector(y)
    compcase = 1;
    yorient = orientation_1d_AAA(y);
    y=y(:);
    NT=1;
elseif M==length(x)
    compcase = 2;
    NT = N;
elseif N==length(x)
    compcase = 3;
    y=y';
    NT = M;
else
    error('Not sure what to do with your input');
end

if isempty(weights)
    weights=1;
end
if isvector(weights)
    if length(weights)==1
        weights=weights.*ones(size(y));
    elseif numel(weights)==numel(y)
        weights=reshape(weights,size(y));
    elseif numel(weights)==M 
        weights=weights(:);
        weights=repmat(weights,[1 N]);
    elseif numel(weights)==N
        weights=weights(:);
        weights=repmat(weights,[1 M]);
    else
        error('Size of weights must match data');
    end
elseif compcase == 2 || compcase == 3
    if size(weights)~=size(y)
        weights = weights';
        if size(weights)~=size(y)
            error('Size of weights must match data');
        end
    end
else
    error('Something went wrong with weights');
end
    
    
% Make sure x and bins are column vectors
x = column_AAA(x);
bins = column_AAA(bins);
[x,I]=sort(x);
if strcmp(BinCentering,'center')
    edges(1)=bins(1);
    edges(2:length(bins))=bins(1:end-1)+diff(bins)/2;
    edges(length(bins)+1)=bins(end);
    x_center = bins;
elseif strcmp(BinCentering,'edges')
    edges = bins;
    x_center = edges(1:end-1)+diff(edges)/2;
else
    error('Unrecognized bin option');
end
NB = length(x_center);
bin_ind = discretize(x,edges);
I2=~isnan(bin_ind);
bin_ind = bin_ind(I2);

switch compcase
    case 1
        y=y(I);
        y=y(I2);
        
        weights = weights(I);
        weights = weights(I2);
        
    case {2,3}
        y=y(I,:);
        y=y(I2,:);
        
        weights = weights(I,:);
        weights = weights(I2,:);
end
y_binned = NaN(NB,NT);
for t=1:NT
    tmp_binned = accumarray(bin_ind,weights(:,t).*y(:,t),[NB,1],@(x)sum(x,'omitnan'),NaN)./accumarray(bin_ind,weights(:,t),[NB,1],@(x)sum(x,'omitnan'),NaN);
    if strcmp(InterpFill,'interp') && sum(~isnan(tmp_binned))>=2
        tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear');
    elseif strcmp(InterpFill,'extrap') && sum(~isnan(tmp_binned))>=2
        tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear','extrap');
    end
    y_binned(:,t) = tmp_binned;
    %fprintf('binning %i percent done \n',floor(t/NT*100));
end

switch compcase
    case 1
        y_binned = orient_1d_AAA(y_binned,yorient);
    case 3
        y_binned = y_binned';
end
x_center = orient_1d_AAA(x_center,xorient);
end






