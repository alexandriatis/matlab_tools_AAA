function align_colorbar_labels_AAA(c,shift,rotation)
%
% This function aligns the colorbars in a plot, and allows for left-right
% shifting the colorbars
%
% Rotation = 1 is vertical
% Rotation = 0 is horizontal
%
%
% Alex Andriatis
% 2023-08-16

if ~exist('shift','var') || isempty(shift)
    shift=0;
end
if ~exist('rotation','var') || isempty(rotation)
    rotation=1;
end
% Align colorbar labels
NC=length(c);
xpos=NaN(1,NC);
for n=1:NC
    set(c(n).Label,'Units','normalized');
    xpos(n)=c(n).Label.Position(2-rotation);
end
xposm=mean(xpos);
for n=1:NC
    c(n).Label.Position(2-rotation)=xposm+shift;
end