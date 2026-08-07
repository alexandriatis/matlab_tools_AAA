% This function returns the current UTC time as a matlab datenum
% Then rounds to the nearest 3-hour period
%
% function time = getUTC_3h()
%
% Alex Andriatis
% 2021-05-02
%
function time = getUTC_3h()
  tnow = getUTC;
    thour = tnow-floor(tnow);
    thour = floor(thour*24);
    tmult = floor(thour/3);
    time = floor(tnow)+(tmult*3)/24;
end
