function cmap = cmap_colourorder(vals,varargin)
% This function is designed to make a better uniform colormap for lots of
% lines representing unevenly-spaced values.
%
% Input Options:
%   vals: The vector of values (or any other type of number) associated
%   with the lines being plotted. The vector length must match the number of
%   lines, and the vector must not contain NaNs or repeats.
%
%   ax: Optional: The axes for which this color order is being defined. If
%   ax is not specified the default is ax=gca
%   
%   colormaptype: Optional: The name of the type of colormap to be used,
%   passed as a string. This can be 'default' (matlab default colormaps), 
%   'cmocean', or 'cbrewer' (in which case cbrewertype must also be specified. 
%   If colormapname is not specified the default is the 
%   matlab colormaps
%   
%
%   colormapname: Optional: 
%   The name of the colormap to be used, passed as a string. See cmoocean
%   and cbrewer for options.
%   If colormapname and colormaptype, or colormaptype is 'default' and 
%   colormapname is not specified is not specified the default is
%   matlab parula
%   
%   cbrewertype: Required with cbrewer: The colormap type ('div', 'seq' or
%    'qual') to be used with cbrewer.
%
%   ownmap: if you wish to use your own colormap, not one of the given map.
%   Length must match the length of vals.
%   

% Outputs:
%   The function will change the ColorOrder of the axes specified by ax
%
% Examples:
%   cmap_colororder(vals) %maps to parula
%   cmap_colororder(vals,ax) %maps to parula on axis called ax
%   cmap_colororder(vals,'ownmap',C) %maps to user defined map C
%   cmap_colororder(vals,'cmapname','jet') %maps to jet
%   cmap_colororder(vals,gca,'cmaptype','cmocean','cmapname','thermal')
%   %maps to cmocean map 'thermal'
%   cmap_colororder(vals,'cmaptype','cbrewer','cbrewertype','seq','cmapname','Reds')
%   %maps to cbrewer map 'Reds' under 'seq' map type 
%
% Alex Andriatis & Bethan Wynne-Cattanach
% 2020-11-22

%Default variables
ax=gca;
cmaptype='default';

%Parse inputs
while ~isempty(varargin)
    switch lower(varargin{1})
          case 'ax'
              ax = varargin{2};
          case 'cmaptype'
              cmaptype = varargin{2};
          case 'cmapname'
              cmapname = varargin{2};
          case 'cbrewertype'
            cbrewertype = varargin{2};
          case 'ownmap'
            C = varargin{2};
          otherwise
              error(['Unexpected option: ' varargin{1}])
    end
      varargin(1:2) = [];
end

%Determine the number of colors required for colormap
[vals,Isort] = sort(vals);
vlims = [min(vals) max(vals)];
dv = min(diff(vals));
if abs(range(vlims)/dv)>100
    dv=mean(diff(vals));
end
newval = vlims(1):dv:vlims(2);
numcolors = length(newval);

%Determine colormap

if strcmp(cmaptype,'cbrewer') && ~exist('cmapname','var') && ~exist('cbrewertype','var')
    error('cmapname and cbrewertype must be specified for cbrewer')
elseif strcmp(cmaptype,'cbrewer') && exist('cmapname','var') && ~exist('cbrewertype','var')
     error('cmapname must be specified for cbrewer')
elseif strcmp(cmaptype,'cbrewer') && ~exist('cmapname','var') && exist('cbrewertype','var')
     error('cbrewertype must be specified for cbrewer')
end
      

if exist('C','var')
        if size(C,2)~=3 || max(C,[],'all')>1 || min(C,[],'all')<0
            error('Colormap C must be an nx3 matrix of RGB ([0,1]) values')
        else
            cmap=zeros(length(newval),3);
            %interpolate onto any colormap that you want
            for i=1:3
                cmap(:,i) = interp1(linspace(vlims(1),vlims(2),size(C,1)),C(:,i),newval);    
            end
        end
elseif strcmp(cmaptype,'default') && ~exist('cmapname','var')
    cmap = parula(numcolors);
elseif strcmp(cmaptype,'default') && exist('cmapname','var')
    cname = matlab.lang.makeValidName(cmapname);
    cmap= eval([cname '(' num2str(numcolors) ')']);
elseif strcmp(cmaptype,'cmocean')
    cmap = cmocean(cmapname,numcolors);
elseif strcmp(cmaptype,'cbrewer')
    cmap = cbrewer2(cbrewertype,cmapname,numcolors);
end

%Create colormap corresponding to the values given

[~,Ivals] = closest(newval,vals);
c = cmap(Ivals,:);
c = c(Isort,:);
colororder(ax,c);
colormap(ax,cmap);
caxis(vlims)
end


