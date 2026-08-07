function x_oriented=orient_1d_AAA(x,xor)
% Flips a vector depending on if it should be a row or column vector
switch xor
    case 1
        x_oriented = column_AAA(x);
    case -1
        x_oriented = row_AAA(x);
    otherwise
        x_oriented = x;
end
end
       
   