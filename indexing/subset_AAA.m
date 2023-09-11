function ind = subset_AAA(vec,val,inclusive)
% Find the indices in one vector (vec) that are within the bounds of
% another (val)
% Inputs:
%   vec: A one-dimensional vector of values
%   val: A 1x2 vector of values bounding the desired limits
%
% Outputs:
%   ind: The indices of vec within the limits of val
%
% Alex Andriatis
% 2023-05-29
if ~exist('exclude','var');
    inclusive=[1 1];
end
if all(inclusive)
    ind= vec >= val(1) & vec <=val(end);
elseif all(~inclusive)
    ind= vec > val(1) & vec <val(end);
elseif inclusive(1)
    ind= vec >= val(1) & vec <val(end);
elseif inclusive(2)
    ind= vec > val(1) & vec <=val(end);
else
    error('Something went wrong');
end
