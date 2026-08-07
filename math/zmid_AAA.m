function z=zmid_AAA(z)
% zmid_AAA finds the midpoints for a vector of numbers, most commonly used
% for the centerpoint of a depth grid
%
% Alex Andriatis
% 2023-12-12
if length(z)<2
    error('Input vector must be at least 2 points');
end
z=(z(2:end)+z(1:end-1))/2;