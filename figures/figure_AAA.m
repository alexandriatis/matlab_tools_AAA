function [f,scaling]=figure_AAA(varargin)
% figure_AAA initializes a scaled figure that is useful for making 
% publication figures
%
% Standard AMS figure sizes are 19, 27, 33, or 39pc where
% 1pc = 12 pt = 0.166 inches, 1 pt = 1/72.27 inches
% 1 column = 19 pc = 228 pt = 3.1548 inches = normalized width 0.41
% 2 column = 39 pc = 468 pt = 6.4757 inches = normalized width 0.84
%
% Scaling the figure allows plotting on large monitors while preserving
% font and line sizes that are consistent with a given figure width
%
% Optional inputs:
%   n:      A number or figure handle to existing figure. Identical usage
%           to figure(n). Leaving it blank will create a new figure.
%   width:  The width of desired figure. Defaults to normalized units 
%           relative to matlab default figure, 560 pixels wide. Can specify
%           units in pixels, centimeters, or inches. Default 0.6 for
%           legible figures.
%   aspect: Figure aspect ratio height / width, default 0.75 to give
%           560x420 default image
%   units:  Figure width units, defaults to normalized units relative to
%           default matlab figure size, such that width 1 = 560 pixels. Can
%           specify units in 'pc','pixels','inches','centimeters', or 
%           'points'.
%   fontsize: Defaut font size for text in figure. Some text types don't
%           work with this, such as xline and yline, need to be adjusted 
%           manually. Default font size is 7 such that calling a 19 pc ams
%           figure produces ylabels that are approximately latex times new
%           roman font size 12.
%   linewidth: Default line width for lines in a figure. The default is 1 
%           so that line widths look good relative to the text font size in
%           AMS figures.
%   scaling: This is a parameter which changes how big the figure looks on
%           the screen while plotting in matlab, but, if everything is 
%           adjusted accordingly, should have no bearing on the final 
%           figure. Its purpose is to allow figures to plot appear well on 
%           the screen while working with them instead of appearing tiny or
%           huge. By default, scaling adjusts automatically so that the
%           figure is half as wide as your screen. Setting scaling 1 will
%           make the figure appear its actual size in pixels, or can adjust
%           arbitratily for convenience. 
%
%
% Ouptuts:
% f: Handle to the created figure
%
% The scaling, standard fontsize, and linewidths are saved as properties of
% the figure for easy recall later
%
% Examples:
%   figure_AAA; Creates a new figure which is half the screen size
%   figure_AAA(2); Creates figure 2 if it doesn't yet exist
%   figrue_AAA(f); Modifies existing figure f
%   figure_AAA(0,'width',0.6,'aspect',0.8,'units','normalized',...
%               'fontsize',7,'linewidth',1,'scaling',1);
%               Creates a new figure with default values.
%
% Alex Andriatis
% 2024-02-15

P=inputParser;

addOptional(P,'n',0);

defaultWidth = 0.6; % Normalized to matlab default figure size 
addParameter(P,'width',defaultWidth,@isnumeric);

defaultAspect=0.8; % Figure aspect ratio, matlab default is 0.75
addParameter(P,'aspect',defaultAspect,@isnumeric);

defaultScaling=0;
addParameter(P,'scaling',defaultScaling,@isnumeric);

defaultUnits = 'normalized'; % Normalized relative to default figure width
checkString=@(s) any(strcmp(s,{'normalized','pc','pixels','inches','centimeters','points'}));
addParameter(P,'units',defaultUnits,checkString);

defaultFontSize=7;
addParameter(P,'fontsize',defaultFontSize,@isnumeric);

defaultLineWidth=1;
addParameter(P,'linewidth',defaultLineWidth,@isnumeric);

defaultVisibility='on';
checkString=@(s) any(strcmp(s,{'on','off'}));
addParameter(P,'visible',defaultVisibility,checkString)

parse(P,varargin{:});
n = P.Results.n;
width=P.Results.width;
aspect=P.Results.aspect;
scaling=P.Results.scaling;
units=P.Results.units;
fontsize=P.Results.fontsize;
linewidth=P.Results.linewidth;
visible=P.Results.visible;

% Convert all unit sizes to pixels
switch units
    case 'normalized'
        width=width*560; % 560 pixels is default matlab figure size
    case 'pc'
        width=width*12;
    case 'inches'
        ppi = get(0,'ScreenPixelsPerInch');
        width=width*ppi;
    case 'centimeters'
        ppi = get(0,'ScreenPixelsPerInch');
        width=width/2.54*ppi;
    case 'points'
        ppi = get(0,'ScreenPixelsPerInch');
        width=width/72*ppi;
end

if strcmp(visible,'off')
    f=figure('visible','off');
else
    if n==0
        f=figure;
    else
        f=figure(n);
    end
end

un=get(f,'units');
set(f,'units','pixels');

% If line plots look weird, try using painters renderer.
% This is a lot slower for most plots though than opengl
%set(f,'Renderer','Painters');
%set(f,'renderer','zbuffer');
% Also it turns out that sometimes matlab tries to use a weird painter for
% whatever reason, and on big plots causes it to crash on save. Opengl
% doesn't have these problems
%set(f,'Renderer','opengl');

% Clear some common variables in figures
evalin( 'base', 'clear ax cb' );

height=width*aspect;

fsize=[width height];
set(0,'units','pixels')  
screen = get(0,'Screensize');
% Set the default scaling to half screen width or height
if ~scaling
    scaling=min(max(1,round((screen(3)/width)*0.5,1)),max(1,round((screen(4)/height)*0.5,1))); % Default figure 1/2 screen width or height
end
fsize=round(fsize*scaling);

% Limit height and width to fit in the scren it's in while preserving
% aspect ratio
if fsize(1)>0.75*screen(3)
    width=0.75*screen(3);
    height=width*aspect;
    fsize=round([width height]);
    scaling=scaling*fsize(1)/width;
end
if fsize(2)>0.75*screen(4)
    height=0.75*screen(4);
    width=height./aspect;
    fsize=round([width height]);
    scaling=scaling*fsize(1)/width;
end

set(f,'Position',[screen(3:4)/2-fsize/2,fsize]);

set(f,'units',un);

set(groot,'defaultaxesfontsize',round(fontsize*scaling));
set(groot,'defaulttextfontsize',round(fontsize*scaling));
set(groot,'defaultaxeslinewidth',round(0.75*linewidth*scaling));
set(groot,'defaultlinelinewidth',round(linewidth*scaling));

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

% Save the scaling, fontsize, and linewidth as properties of the figure
if ~isprop(f,'Scaling')
f.addprop('Scaling');
end
set(f,'Scaling',scaling);

if ~isprop(f,'LineWidth')
f.addprop('LineWidth');
end
set(f,'LineWidth',linewidth);

if ~isprop(f,'FontSize')
f.addprop('FontSize');
end
set(f,'FontSize',fontsize);

if ~isprop(f,'Script')
f.addprop('Script');
end
set(f,'Script',get_current_filename_AAA);
end