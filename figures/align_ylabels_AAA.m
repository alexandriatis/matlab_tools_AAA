function align_ylabels_AAA(ax,shift)
%
% This function aligns the ylabels in a plot, and allows for left-right
% shifting the ylabels
%
% Alex Andriatis
% 2023-08-16

if ~exist('shift','var') || isempty(shift)
    shift=0;
end
NX=length(ax);
xpos=NaN(1,NX);
for n=1:NX
    ax(n).YLabel.Units='pixels';
    xpos(n)=ax(n).YLabel.Position(1);
end
xposm=mean(xpos);
fpos=get(gcf,'Position');
width=fpos(3);
for n=1:NX
    ax(n).YLabel.Position(1)=xposm+shift*width;
end