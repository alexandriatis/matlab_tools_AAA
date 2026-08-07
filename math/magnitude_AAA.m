function mag = magnitude_AAA(x,y)

if exist('y','var')
    mag = sqrt(x.^2 + y.^2);
else
    mag = abs(x);
end