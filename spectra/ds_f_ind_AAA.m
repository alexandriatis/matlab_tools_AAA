function [Ipos,Ineg]=ds_f_ind_AAA(p)
% ds_f_ind_AAA returns the indices corresponding to the positive and
% negative halves of a double sided frequency series, the result of an fft.
%
% Alex Andriatis
% 2021-08-23

if mod(p,2)==0
   Ipos=(1:p/2+1);
   Ineg=(p/2+2:p);
else
   Ipos=(1:(p+1)/2);
   Ineg=((p+1)/2+1:p);
end
end