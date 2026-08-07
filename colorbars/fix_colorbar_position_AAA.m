function [c,cpos] = fix_colorbar_position_AAA(cpos)
% This function places the colorbar outside the axes area so that a plot
% lines up with other sublots. 
% Inputs:
%   c = the colorbar object
%   Optional:
%       cpos = the location of a colorbar object, useful if making movies
%       where the colorbar needs to always be in the same place. cpos =
%       c.Position
%
%
% Alex Andraitis
% 2021-10-20
    sPos = get(gca,'position');
    c = colorbar;
    c.Location='eastoutside';
    set(gca,'position',sPos);
    if ~exist('cpos','var')
        cpos = c.Position;
    else
    set(c,'Units','normalized','position',cpos);
    end
    