function f = figure_AAA(number,scaling,format)
set(0, 'DefaultLineLineWidth', 1);
if ~exist('number','var') || isempty(number)
    f=figure;
else
    f=figure(number);
end
clf;

formatnum = 1;
if exist('format','var')
    switch format
        case 'long'
            formatnum=1;
        case 'tall'
            formatnum=2;
        case 'square'
            formatnum=3;
    end
end

switch formatnum
    case 1
        size = [960 540];
    case 2
        size = [540 960];
    case 3
        size = [540 540];
end

if ~exist('scaling','var') || isempty(scaling)
    scaling = 1;
end
size = round(size*scaling);
screen = get(0,'Screensize');
position = round([screen(3:4)/2-size/2,size]);
while any(position<0) || position(3)>screen(3) || position(4)>screen(4)
    scaling = 0.95*scaling;
    size = round(size*scaling);
    position = round([screen(3:4)/2-size/2,size]);
end
set(f,'Position',[screen(3:4)/2-size/2,size]);
hold on;
supersizeme(1.5*scaling);
end