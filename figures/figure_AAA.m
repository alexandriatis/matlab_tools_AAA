function [f,scaling]=figure_AAA(varargin)
% paperfigure_ams initializes a figure window with a fixed size that makes
% consistent figures for publication.
%
% AMS requires figures to be in either 19pc or 39pc
% 1pc = 12 pt = 0.166 inches, 1 pt = 1/72.27 inches
% 1 column = 228 pt = 3.1548 inches
% 2 column = 468 pt = 6.4757 inches
% Alternative sizes are 27pc and 33pc
% 1 plus = 324 pt
% 2 minus = 396 pt
%
% 2023-08-05
%
% Adapted for normal figure plottting with reduced axes sizes so that I can
% see more stuff when plotting a figure
% 2023-09-01
%
% Changed width option to just be expressed in pc = pt/12
% Standard sizes: 19, 27, 33, 39 pc
% 2023-09-11
% Alex Andriatis

P=inputParser;

addOptional(P,'n',0);

defaultWidth=19; % Expressed in pc = 12 pt = 12/72.72 inches
addParameter(P,'width',defaultWidth,@isnumeric);

defaultAspect=0.8;
addParameter(P,'aspect',defaultAspect,@isnumeric);

screen = get(0,'Screensize');
defaultScaling=min(max(1,round((screen(3)/560)/2,1)),max(1,round((screen(4)/420)/2,1))); % Default figure half screen width or height
addParameter(P,'scaling',defaultScaling,@isnumeric);

parse(P,varargin{:});
n = P.Results.n;
width=P.Results.width;
aspect=P.Results.aspect;
scaling=P.Results.scaling;

fontsize=6;

if n==0
    f=figure;
else
    f=figure(n);
end

un=get(f,'units');
set(f,'units','pixels');

width = width*12; % Convert pc to pt;

height=width*aspect;

% Limit height to page height
% Max text height 8.5 inches = 614 pt
maxheight=614;
if height>maxheight
    height=maxheight;
end

fsize=[width height];
fsize=round(fsize*scaling);

% Limit height and width to fit in the scren it's in while preserving
% aspect ratio

if fsize(1)>screen(3)
    width=screen(3);
    height=width*aspect;
    scaling=scaling*width/fsize(1);
    fsize=[width height];
    fsize=round(fsize*scaling);
end
if fsize(2)>screen(4)
    height=screen(4);
    width=height./aspect;
    scaling=scaling*width/fsize(1);
    fsize=[width height];
    fsize=round(fsize*scaling);
end

set(f,'Position',[screen(3:4)/2-fsize/2,fsize]);

set(f,'units',un);

set(groot,'defaultaxesfontsize',round(fontsize*scaling));
set(groot,'defaulttextfontsize',round(fontsize*scaling));
set(groot,'defaultaxeslinewidth',round(0.5*scaling));
set(groot,'defaultlinelinewidth',round(0.75*scaling));

% Set text interpreter to Latex by default
set(groot,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
%set(f,'Resize','off');

end