function xor=orientation_1d_AAA(x)
% Determines if a vector is a row or column vector
if iscolumn(x)
    xor=1;
elseif isrow(x)
    xor=-1;
else
    xor=0;
end
end
       
   