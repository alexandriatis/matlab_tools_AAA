function y = ang2comp_AAA(x,type)
% Changes angle to complex exponential
switch type
    case 'rad'
        y = exp(1i*x);
    case 'deg'
        y = exp(1i*deg2rad(x));
    otherwise
        error('Type must be either deg or rad');
end