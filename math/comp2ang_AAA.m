function y = comp2ang_AAA(x,type)
% Changes angle to complex exponential
switch type
    case 'rad'
        y = angle(x);
    case 'deg'
        y = rad2deg(angle(x));
    otherwise
        error('Type must be either deg or rad');
end