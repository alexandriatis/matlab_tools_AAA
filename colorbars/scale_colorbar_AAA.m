function scale_colorbar_AAA(c,scale,rotation)
% scale_colorbar_AAA changes colorbars by a scaling, generally to shrink
% them
% Rotation = 1 is vertical
% Rotation = 0 is horizontal
%
% Alex Andriatis
% 2023-08-16
if ~exist('scale','var') || isempty(scale)
    scale=0.5;
end
if ~exist('rotation','var') || isempty(rotation)
    rotation=1;
end
NC=length(c);
for i=1:NC
    c(i).Position(1+rotation)=c(i).Position(1+rotation)+(c(i).Position(3+rotation)-c(i).Position(3+rotation)*scale)/2;
    c(i).Position(3+rotation)=c(i).Position(3+rotation)*scale;
end