function [corder,cmap,clims] = colororder_AAA(vals,cmap)
% This function is designed to make a better uniform colormap for lots of
% lines representing unevenly-spaced values.
%
% Updated from cmap_colourorder
% 2024-07-23
%
% Input Options:
%   vals: The vector of values (or any other type of number) associated
%   with the lines being plotted. The vector length must match the number of
%   lines, and the vector must not contain NaNs or repeats.
%
%   cmap: A colormap of size nx3 with colormap values betweeen 0 and 1
%
%
% Outputs:
%   corder: A colormap used for the color order of lines
%   cmap:   The underlying colormap
%   clis:   The limits of the underlying colormap
%
% Examples:
%   colororder_AAA(vals,cmap)
%
% 
% Alex Andriatis
% 2024-07-23

vals=column_AAA(vals);
%Determine the number of colors required for colormap
dv = min(diff(unique(vals)));
vlims = [min(vals)-dv/2 max(vals)+dv/2];
if abs(range(vlims)/dv)>255
    newval=linspace(vlims(1),vlims(2),256);
else
    newval = vlims(1):dv:vlims(2);
end
newval=column_AAA(newval);

%Create colormap corresponding to the values given

cmap=interp1_AAA(linspace(vlims(1),vlims(2),size(cmap,1)),cmap,newval,'linear');
corder=interp1_AAA(newval,cmap,vals,'linear');

colororder(gca,corder);
colormap(gca,cmap);
clim(vlims)
end


