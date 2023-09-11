function postfix_paperfigure_ams_AAA(f,scaling)
% paperfigure_ams initializes a figure window with a fixed size that makes
% consistent figures for publication.
%
% AMS requires figures to be in either 19pc or 33pc
% 1pc = 12 pt = 0.166 inches, 1 pt = 1/72.27 inches
% 1 column = 228 pt = 3.1548 inches
% 2 column = 468 pt = 6.4757 inches
%
% Alex Andriatis
% 2023-08-05
%
% Second function to fix figure properties after it is plotted
% 2023-08-07

fontsize=10;

if ~exist('f','var')
    f=gcf;
end
if ~exist('scaling','var')
    scaling=1; % Depends on monitor resolution. I want to make figures as big as I can
end

tx=findall(f,'Type','Text');
NTX=length(tx);
for i=1:NTX
    tx(i).Interpreter='latex';
end

ax=findall(f,'Type','Axes');
NAX=length(ax);
for i=1:NAX
    ax(i).FontSize=fontsize*scaling;
end

c=findall(f,'Type','ColorBar');
NC=length(c);
for i=1:NC
    c(i).TickLabelInterpreter='Latex';
    c(i).FontSize=fontsize*scaling;
    c(i).Label.Interpreter='Latex';
    c(i).Label.FontSize=fontsize*scaling;
end

lg=findall(f,'Type','Legend');
NLG=length(lg);
for i=1:NLG
    lg(i).FontSize=fontsize*scaling;
end



end