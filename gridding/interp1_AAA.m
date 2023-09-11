function [ygrid,F]=interp1_AAA(x,y,xq,interpmethod,extrapmethod)
% interp1_AAA is just the interp1 function but made easier to work with so
% that I can specify different interpolation and extrapolation methods
%
% Also, this method works with matrices, with 1-D linear interpolation
% across each row 
%
% Alex Andriatis
% 2023-04-10

if nargin<3
    error('Must supply at least 3 inputs - x, y, and xq');
end
if nargin<4
    interpmethod='linear';
end
if nargin<5
    extrapmethod='none';
end

if ~isvector(x)
    error('Input x must be a vector');
end
if ~isvector(xq)
    error('Input xq must be a vector');
end
if ~ismatrix(y)
    error('Can only interp 1 or 2-d data');
end

xqorient = orientation_1d_AAA(xq);

[M,N]=size(y);
if isvector(y)
    y=y(:);
elseif M==length(x)
elseif N==length(x)
    y=y';
else
    error('Not sure what to do with your input');
end     

x = x(:);
xq = xq(:);

I=~isnan(x);
x=x(I);
y=y(I,:);
[x,~,ic] = unique(x);
[icx,icy]=ndgrid(ic,1:size(y,2));
y = accumarray([icx(:),icy(:)],y(:),[],@(x)sum_AAA(x,'omitnan'),NaN);

F=griddedInterpolant(x,y,interpmethod,extrapmethod);
ygrid=F(xq);

if xqorient==-1
    ygrid=ygrid';
end
end


