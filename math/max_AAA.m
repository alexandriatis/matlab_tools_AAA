function y=max_AAA(x,nanflag)
% Returns the maximum of a set, nan if all elements are nan
%
% Alex Andriatis
% 2023-04-11

y=max(x,[],nanflag);
if all(isnan(x))
    y=NaN;
end