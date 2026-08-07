function y = gaussian_AAA(x,a,b,c,d)
y=a*exp(-(x-b).^2/(2*c^2))+d;
end