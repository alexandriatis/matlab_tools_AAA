function xmid=midpoint_AAA(x)
% midpoint_AAA finds the midpoints for a vector of numbers, 
% most commonly used for the centerpoint of a depth grid
%
% Alex Andriatis
% 2023-12-12
if length(x)<2
    error('Input vector must be at least 2 points');
end
xmid=(x(2:end)+x(1:end-1))/2;