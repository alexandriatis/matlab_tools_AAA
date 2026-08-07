function c = colorbar_AAA(cpos)
% This function places the colorbar outside the axes area so that a plot
% lines up with other sublots. 
% Inputs:
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
    set(gca,'position',sPos);
    c.Location='eastoutside';
    if ~exist('cpos','var')
        cpos = c.Position;
    end
    set(c,'Units','normalized','position',cpos);
    set(c.Label,'Interpreter','Latex');
    set(c,'TickLabelInterpreter','Latex');
end