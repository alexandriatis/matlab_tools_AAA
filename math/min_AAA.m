function y=min_AAA(x,nanflag)
% I don't like the matlab default behaviour where if all elements being
% summed over are NaN, then sum(x,'omitnan') returns 0. Instead, I want it
% to return NaN. This function does sum(x,nanflag) and returns NaN if all
% elements being summed over are NaN
%
% Just works for one-dimensional sums
%
% Alex Andriatis
% 2023-04-11

y=min(x,[],nanflag);
if all(isnan(x))
    y=NaN;
end