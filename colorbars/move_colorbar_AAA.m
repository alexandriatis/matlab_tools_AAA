function move_colorbar_AAA(position_top)
% This function moves the colorbar outside the axes frame so that subplots
% with and without a colorbar end up aligned. Call this function AFTER
% plotting the colorbar.
%
% Inputs:
%   position_top: The vector representing the axes position within the
%   figure, made by calling position_top = get(gca,'position'); BEFORE
%   plotting.
%
% Alex Andriatis
% 2020-03-25

        
position = get(gca,'position');
position(3) = position_top(3);
set(gca,'position',position);