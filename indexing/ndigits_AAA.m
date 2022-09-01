function ndigits=ndigits_AAA(A)
% This function returns the number of digits past the decimal that a number
% contains
%
% Alex Andriatis
% 2022-02-09
ndigits = floor(log10(abs(A)+1)) + 1;
end