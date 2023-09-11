function paperfigure_ams_AAA(f,col,aspect,scaling)
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
% Alex Andriatis
% 2023-08-05

fontsize=10;

if ~exist('f','var')
    f=gcf;
end
if ~exist('col','var')
    col='onecolumn';
end
if ~exist('aspect','var')
    aspect=1;
end
if ~exist('scaling','var')
    scaling=1; % Depends on monitor resolution. I want to make figures as big as I can
end


un=get(f,'units');
set(f,'units','pixels');
screen = get(0,'Screensize');

switch col
    case 'onecolumn'
        width=19*12;
    case 'twocolumn'
        width=39*12;
    case 'oneplus'
        width=27*12;
    case 'twominus'
        width=33*12;
end

height=width*aspect;

% Limit height to page height
% Max text height 8.5 inches = 614 pt
maxheight=614;
if height>maxheight
    height=maxheight;
end

fsize=[width height];
fsize=fsize*scaling;

set(f,'Position',[screen(3:4)/2-fsize/2,fsize]);

set(f,'units',un);

set(groot,'defaultaxesfontsize',fontsize*scaling);
set(groot,'defaulttextfontsize',fontsize*scaling);
set(groot,'defaultaxeslinewidth',0.75*scaling);
set(groot,'defaultlinelinewidth',1*scaling);

% Set text interpreter to Latex by default
set(groot,'defaulttextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
%set(f,'Resize','off');

end