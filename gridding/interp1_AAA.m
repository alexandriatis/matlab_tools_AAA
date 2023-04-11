function [ygrid,F]=interp1_AAA(x,y,xq,interpmethod,extrapmethod)
% interp1_AAA is just the interp1 function but made easier to work with so
% that I can specify different interpolation and extrapolation methods
%
% Alex Andriatis
% 2023-04-10

if nargin<2
    error('Must supply at least 2 inputs - x and y');
end
if nargin<3
    xq=x;
end
if nargin<4
    interpmethod='linear';
end
if nargin<5
    extrapmethod='none';
end
        
if numel(y)~=length(y)
    error('Input y must be a vector');
end

if isempty(x)
    x=1:length(y);
    xq=x;
end

if any(size(x)~=size(y))
    x=x';
    if any(size(x)~=size(y))
        error('Sizes of x and y must match')
    end
end

F=griddedInterpolant(x,y,interpmethod,extrapmethod);
ygrid=F(xq);
end


