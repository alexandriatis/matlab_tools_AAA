function cmap=cbrewer_AAA(cname,varargin)
% This function returen cbrewer2 colormaps but with the light parts removed
% to make them easier to see
%
% examples cmap=cbspectral_without_yellows_AAA returns the full colormap but with 20% of the central colors missing
%           cmap=cbspectral_without_yellows_AAA(n) returns an n point colormap with 20% of the central colors missing
%           cmap=cbspectral_without_yellows_AAA(n,0.3) returns an n point colormap with 30% of the central colors missing
%
% Alex Andriatis
% 2022-04-10

cstrings.seq={'Blues','BuGn','BuPu','GnBu','Greens','Greys','Oranges','OrRd','PuBu','PuBuGn','PuRd','Purples','RdPu','Reds','YlGn','YlGn','YlGnBu','YlOrBr','YlOrRd'};
cstrings.div={'BrBG','PiYG','PRGn','PuOr','RdBu','RdGy','RdYlBu','RdYlGn','Spectral'};
cstrings.qual={'Accent','Dark2','Paired','Pastel1','Pastel2','Set1','Set2','Set3'};

P=inputParser;

checkString=@(s) any(strcmp(s,[cstrings.seq,cstrings.div,cstrings.qual]));
addRequired(P,'cname',checkString);

defaultNcol=[];
addOptional(P,'ncol',defaultNcol,@isnumeric);

defaultCutFrac=0.2;
validFrac = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (x<= 1);
addOptional(P,'cutfrac',defaultCutFrac,validFrac);

parse(P,cname,varargin{:});
cname = P.Results.cname;
ncol = P.Results.ncol;
cutfrac = P.Results.cutfrac;

if any(strcmp(cname,cstrings.seq))
    colcase=1;
elseif any(strcmp(cname,cstrings.div))
    colcase=2;
else
    cmap=cbrewer2(cname,ncol);
    return
end

colors=cbrewer2(cname);
NC=size(colors,1);
ncut=NC*cutfrac;
I=1:NC;

switch colcase
    case 1
        Icut=[1 max(floor(ncut),1)];
    case 2
        Icut=[max(floor(NC/2-ncut/2),1) min(ceil(NC/2+ncut/2),NC)];
end
Itrim=I;
Itrim(Icut(1):Icut(end))=[];
colors=interp1_AAA(Itrim,colors(Itrim,:),linspace(Itrim(1),Itrim(end),NC)','linear','linear');
if isempty(ncol)
    ncol=NC;
end
Icol=round(linspace(1,NC,ncol));
cmap=colors(Icol,:);
end
