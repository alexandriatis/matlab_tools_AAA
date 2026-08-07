function [a,b]=subplot_calculator_AAA(N2)
% funciton subplot_calculator_AAA gives the indices for a rectangular long
% figure given a nuber of subplots to make

N=sqrt(N2);
if round(N)<N
    a = floor(N);
    b = ceil(N);
else
    a = ceil(N);
    b = a;
end