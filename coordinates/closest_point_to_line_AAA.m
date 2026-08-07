function [point,pointy]=closest_point_to_line_AAA(x0,y0,P)
% Finds, in 2 dimensions, the closest point on a polynmoial line to a given
% target coordinate or set of N points. 
%
% Inputs:
%   x0,y0:      A target coordintate (x0,y0), or a set of coordinates of size 1xN or Nx1
%   P:          The polynmoial coefficients of a line y=f(x), such as the output of Polyfit P=polyfit(x,y,n);
%
% Outputs:
%   point:      The coordinate x along the line y=f(x) defined by the polynomial coefficients P. Length N
%   point_y:    The y-coordinate along the line y=f(x). It's redundant since you can just get point_y = polyval(P,point). Length N
%
% Alex Andriatis
% 2022-11-11

N = length(x0);
if N~=length(y0)
    error('x and y targets must be of same length');
end

% Define symbolic equation for a polynomial line y=f(x)
syms x
y = poly2sym(P,x);

% Output x-coordinates along line y=f(x)
point=NaN(1,N);

% Loop over all target coordinates
for i=1:N
    syms x
    dsquared = (x-x0(i)).^2 + (y-y0(i)).^2; % Squared distance from target point to line
    eqn = diff(dsquared)==0; % Equation for derivative of distance == 0 (local minima of distance)
    S=vpasolve(eqn,x,[-Inf Inf]); % Numerically solve for local minima
    x=S;
    D=subs(dsquared); % For each local minimum distance get the distance to target point
    [~,I]=min(D); % In case of multiple local minima, find the global minimum distance to target
    point(i)=S(I); % Save x-coordinate on line corresponding to target coordinate
end
pointy=polyval(P,point); % For convenience, give the y-values along the line corresponding to x-values.