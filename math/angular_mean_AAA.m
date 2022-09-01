function y = angular_mean_AAA(x,type)
% Does the angular mean of a vector of angles
switch type
    case 'rad'
        y = angle(mean(exp(1i*deg2rad(x)),'omitnan'));
    case 'deg'
        y = rad2deg(angle(mean(exp(1i*deg2rad(x)),'omitnan')));
    otherwise
        error('Type must be either deg or rad');
end