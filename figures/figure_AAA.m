function [f,scaling]=figure_AAA(varargin)
% figure_AAA initializes a scaled figure that is useful for making publication figures
% Standard AMS figure sizes are 19, 27, 33, or 39pc where
% 1pc = 12 pt = 0.166 inches, 1 pt = 1/72.27 inches
% 1 column = 19 pc = 228 pt = 3.1548 inches
% 2 column = 39 pc = 468 pt = 6.4757 inches
%
% Scaling the figure allows plotting on large monitors while preserving
% font and line sizes that are consistent with a given figure width
%
% Optional inputs:
% n: A number or figure handle to existing figure. Identical usage to
% figure(n). Leaving it blank will create a new figure.
% width: The width of desired figure in pixels (default 560)
% scaling: Scaling up the figure relative to default size 560 x 420
% aspect: Figure aspect ratio height / width, default 0.8
%
% Ouptuts:
% f: Handle to the created figure
% scaling: If the scaling is automatically adjusted, returns new scaling
% for further plotting
%
% Examples:
%   figure_AAA; Creates a new figure which is half the screen size
%   figure_AAA(2); Creates figure 2 if it doesn't yet exist
%   figrue_AAA(f); Modifies existing figure f
%   figure_AAA(0,'width',19,'aspect',0.8,'scaling',2); % Creates a new
%   figure with default values
%
% Alex Andriatis
% 2023-09-11

P=inputParser;

addOptional(P,'n',0);

defaultWidth=560; % Expressed in pt = 1/72.72 inches
addParameter(P,'width',defaultWidth,@isnumeric);

defaultAspect=0.75;
addParameter(P,'aspect',defaultAspect,@isnumeric);

screen = get(0,'Screensize');
defaultScaling=min(max(1,round((screen(3)/560)*0.5,1)),max(1,round((screen(4)/420)*0.5,1))); % Default figure 1/2 screen width or height
addParameter(P,'scaling',defaultScaling,@isnumeric);

parse(P,varargin{:});
n = P.Results.n;
width=P.Results.width;
aspect=P.Results.aspect;
scaling=P.Results.scaling;

fontsize=9;

if n==0
    f=figure;
else
    f=figure(n);
end

un=get(f,'units');
set(f,'units','pixels');

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
    scaling=scaling*fsize(1)/width;
    fsize=round([width height]);
end
if fsize(2)>screen(4)
    height=screen(4);
    width=height./aspect;
    scaling=scaling*fsize(1)/width;
    fsize=round([width height]);
end

set(f,'Position',[screen(3:4)/2-fsize/2,fsize]);

set(f,'units',un);

set(groot,'defaultaxesfontsize',round(fontsize*scaling));
set(groot,'defaulttextfontsize',round(fontsize*scaling));
set(groot,'defaultaxeslinewidth',round(0.8*scaling));
set(groot,'defaultlinelinewidth',round(1.2*scaling));

% Set text interpreter to Latex by default
set(groot,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');

% Prevent accidental figure resizing
% set(f,'Resize','off');

% Clear figure if it already exists - can turn off
clf;
% Hold on; grid on; box on;
hgb;

end