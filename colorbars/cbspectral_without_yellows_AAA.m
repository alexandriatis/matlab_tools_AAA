function cmap=cbspectral_without_yellows_AAA(n,cutfrac)
% This function returns the spectral cbrewer2 colormap but without the
% central light-yellow colors
%
% examples cmap=cbspectral_without_yellows_AAA returns the full colormap but with 20% of the central colors missing
%           cmap=cbspectral_without_yellows_AAA(n) returns an n point colormap with 20% of the central colors missing
%           cmap=cbspectral_without_yellows_AAA(n,0.3) returns an n point colormap with 30% of the central colors missing
%
% Alex Andriatis
% 2022-04-10

colors=cbrewer2('spectral');

% Remove the middle 20% of the spectral colormap
NC=size(colors,1);
if ~exist('cutfrac','var') || isempty(cutfrac)
    cutfrac=0.2;
end
ncut=NC*cutfrac;
I=[round(NC/2-ncut/2) round(NC/2+ncut/2)];
colors(I(1):I(2),:)=interp1_AAA(I,colors(I,:),[I(1):I(2)]');
% for i=1:3
%     colors(I(1):I(2),i)=interp1_AAA(I,colors(I,i),I(1):I(2));
% end

if ~exist('n','var') || isempty(n)
    n=NC;
end
Icol=round(linspace(1,NC,n));
cmap=colors(Icol,:);
end
