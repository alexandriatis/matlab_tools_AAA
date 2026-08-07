function [lat,lon] = fixlatlon(plat,plon)
% This function converts decimal degree lat lons into negative/positive
% values
%
% Alex Andriatis
% 2020-12-08

     plat = rem(plat,180);
     plat(plat>90) = 180-plat(plat>90);
     plat(plat<-90) = -180-plat(plat<-90);
     
     plon = rem(plon,360);
     plon(plon>180) = 360-plon(plon>180);
     plon(plon<-180) = -360-plon(plon<-180);
     
     lat = plat;
     lon = plon;
end