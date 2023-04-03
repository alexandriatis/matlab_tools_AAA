function heading=ll2heading_AAA(lon,lat);

% X = cos θb * sin ∆L
% 
% Y = cos θa * sin θb – sin θa * cos θb * cos ∆L
lat1 = lat(1:end-1);
lat2 = lat(2:end);

lon1 = lon(1:end-1);
lon2 = lon(2:end);
X=cosd(lat2).*sind(lon2-lon1);
Y=cosd(lat1).*sind(lat2)-sind(lat1).*cosd(lat2).*cosd(lon2-lon1);
heading=atan2d(X,Y);