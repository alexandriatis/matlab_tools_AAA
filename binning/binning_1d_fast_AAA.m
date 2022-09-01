function [x_center,y_binned]=binning_1d_fast_AAA(x,y,bins,option)
% This fucntion is designed to bin data 
%
% Alex Andriatis
% 2021-08-13
%

if size(x)~=size(y)
    error('Input x and y must be the same size');
end

use_edges=0;
if exist('option','var')
    if strcmp(option,'edges')
        use_edges=1;
    end
end

% Make sure x,y and bins are all column vectors
x = column_AAA(x);
y = column_AAA(y);
bins = column_AAA(bins);

[x,I]=sort(x);
y = y(I);

if ~use_edges
    edges(1)=bins(1);
    edges(2:length(bins))=bins(1:end-1)+diff(bins)/2;
    edges(length(bins)+1)=bins(end);
    
    x_center = bins;
else
    edges = bins;
    x_center = edges(1:end-1)+diff(edges)/2;
end
bin_ind = discretize(x,edges);
I=~isnan(bin_ind);
y_binned = accumarray(bin_ind(I),y(I),[length(bins),1],@nanmean,NaN);
end






