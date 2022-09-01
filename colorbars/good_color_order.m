function good_color_order(vals,ax,colormapname)
% This function is designed to make a better uniform colormap for lets of
% lines representing unevenly-spaced values.
% It works with any cmocean colormap name.
%
% Inputs:
%   vals: The vector of values (or any other type of number) associated
%   with the lines being plotted. The vector length must match the number of
%   lines, and the vector must not contain NaNs.
%
%   ax: Optional: The axes for which this color order is being defined. If
%   ax is not specified the default is ax=gca
%
%   colormapname: Optional: The name of the cmocean colormap to be used,
%   passed as a string. If colormapname is not specified the default is
%   matlab parula
%
% Outputs:
%   The function will change the ColorOrder of the axes specified by ax
%
% Examples:
%   good_color_order(vals)
%   good_color_order(vals,gca)
%   good_color_order(vals,'thermal')
%   good_color_order(vals,gca,'thermal')
%
% Alex Andriatis
% 2020-11-22

% Parse inputs
if ndims(vals)>2 || length(vals)<2
    error('values vector must be a vector of length > 1')
end

if exist('ax','var')
    if isstring(ax)
        colormapname = ax;
        ax = gca;
    end
else
    ax = gca;
end

if exist('colormapname','var')
    if ~ischar(colormapname)
        error('colormapname must be a cmocean-compatible string')
    end
end
      
[vals,Isort] = sort(vals);
vlims = [min(vals) max(vals)];
dv = min(diff(vals));
newval = vlims(1):dv:vlims(2);
numcolors = length(newval);

if exist('colormapname','var')
    c = cmocean(colormapname,numcolors);
    disp('yes')
else
    c = colormap(parula(numcolors));
end

[~,Itimes] = closest(newval,vals,1);
c = c(Itimes,:);
c = c(Isort,:);
colororder(ax,c);

end

