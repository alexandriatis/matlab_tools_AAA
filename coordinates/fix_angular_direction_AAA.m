function y = fix_angular_direction_AAA(x,type)
% Converts 0-360 coordinates to -180 to 180, or 0 to 2pi to -pi/pi
switch type
    case 'rad'
        y = angle(exp(1i*x));
    case 'deg'
        y = rad2deg(angle(exp(1i*deg2rad(x))));
    otherwise
        error('Type must be either deg or rad');
end