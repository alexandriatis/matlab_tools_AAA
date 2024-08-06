function y = unwrap_AAA(x,threshold,type)
% Does the angular mean of a vector of angles
if ~exist('threshold','var') || isempty(threshold);
    threshold=pi;
end
if ~exist('type','var') || isempty(type);
    type='rad';
end
y=x;
switch type
    case 'deg'
        y=deg2rad(y);
    case 'rad'
    otherwise
        error('Type must be either deg or rad');
end

for t=2:length(y)
    dx=y(t)-y(t-1);
    if dx>threshold
        y(t:end)=y(t:end)-2*pi;
    elseif dx<-threshold
        y(t:end)=y(t:end)+2*pi;
    end
end

switch type
    case 'deg'
        y=rad2deg(y);
end
end