function plot_fname_timestamp_AAA(fg)
% Plots the current figure path name at the bottom of a figure so that I
% know where the figure script is
%
% Alex Andriatis
% 2024-05-13
fstring=get_fname_timestamp_AAA;
if ~isprop(fg,'Scaling')
    fscaling=1;
else
    fscaling=fg.Scaling;
end
if ~isprop(fg,'FontSize')
    fontsize=7;
else
    fontsize=fg.FontSize/2;
end

annotation( 'textbox',[0 0 1 1], 'String', fstring, 'Color', 0.3*ones(1,3), ...
            'FontSize', fontsize*fscaling, 'Units', 'normalized', 'EdgeColor', 'none', ...
            'Position', [0 0 1 1],'HorizontalAlignment','left','VerticalAlignment','bottom','Interpreter','none');