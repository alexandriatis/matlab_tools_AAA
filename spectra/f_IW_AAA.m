function [A]=f_IW_AAA(varargin)

A=[];

P=inputParser;

defaultLat = [];
addParameter(P,'lat',defaultLat,@isnumeric);

defaultUnit = 'day';
validationFcn = @(x) validateattributes(x,{'char','string'},{});
addParameter(P,'unit',defaultUnit,validationFcn);


parse(P,varargin{:});
lat = P.Results.lat;
unit = P.Results.unit;

scaling=1;
switch unit
    case 'second'
        scaling = 1/(60*60*24);
    case 'minute'
        scaling = 1/(60*24);
    case 'hour'
        scaling = 1/(24);
    case 'year'
        scaling = 365.25;
    otherwise
        scaling = 1;
end

if ~isempty(lat)
    A.f = sw_f(lat)*86400/(2*pi); % Inertial Frequency
end
A.M2 = 1/(12.4206012/24); % Principal lunar semidiurnal
A.S2 = 1/(12/24); % Principal solar semidiurnal
A.N2 = 1/(12.65834751/24); % Larger lunar elliptic semidiurnal
A.K1 = 1/(23.93447213/24); % Lunar diurnal
A.M4 = 1/(6.210300601/24); % Shallow water overtides of principal lunar
A.O1 = 1/(25.81933871/24); % Lunar diurnal

names=fieldnames(A);
for n=1:length(names);
    name=names{n};
    A.(name)=A.(name)*scaling;
end



