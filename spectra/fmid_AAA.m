function I = fmid_AAA(f)
% This function gives back the index of the midpoint of a zero-centered
% frequency axis
N = length(f);
if mod(N,2)==0
    I = N/2+1;
else
    I = (N+1)/2;
end
end
