function [SA,CT] = seawater_ST_from_st_AAA(s,t,p,lon,lat)
% Function seawater_ST_from_st_AAA calculates SA and CT from SP and t,
% using gsw v3.6, since I got tired of having to do the same calculation
% every time. Runs on a single profile, can't handle matrices, just use a
% for loop.
%
% Example: [SA,CT] = seawater_ST_from_st_AAA([33 34 35],[18 17 16],[0 1 2],[-130 -130 -130],[35 35 35]);
%          [SA,CT] = seawater_ST_from_st_AAA([],[17],[]);
%
% Alex Andriatis
% 07-22-2022
%
if isempty(s)
    s = 35; % average ocean salinity
end
if isempty(t)
    t = 20; % ocean surface temperature
end
if isempty(p)
    p = 0; % ocean surface pressure
end
if isempty(lat) || all(isnan(lat))
    lat=35;
end
if isempty(lon) || all(isnan(lon))
    lon = 0;
end
s = column_AAA(s);
t = column_AAA(t);
p = column_AAA(p);
lat = column_AAA(lat);
lon = column_AAA(lon);

NZ = max([length(s),length(t),length(p)]);

if length(s)~=NZ
    if length(s)==1
        s = s*ones(NZ,1);
    elseif length(s)==2
        s = linspace(s(1),s(2),NZ);
    else
        error('Salinity incompatible length');
    end
end
if length(t)~=NZ
    if length(t)==1
        t = t*ones(NZ,1);
    elseif length(t)==2
        t = linspace(t(1),t(2),NZ);
    else
        error('Temperature incompatible length');
    end
end
if length(p)~=NZ
    if length(p)==1
        p = p*ones(NZ,1);
    elseif length(p)==2
        p = linspace(p(1),p(2),NZ);
    else
        error('Pressure incompatible length');
    end
end

if length(lon)~=NZ
    if length(lon)==1
        lon = lon*ones(NZ,1);
    elseif length(lon)==2
        lon = linspace(lon(1),lon(2),NZ);
    else
        error('Longitude incompatible length');
    end
end
if length(lat)~=NZ
    if length(lat)==1
        lat = lat*ones(NZ,1);
    elseif length(lat)==2
        lat = linspace(lat(1),lat(2),NZ);
    else
        error('Longitude incompatible length');
    end
end
SA = gsw_SA_from_SP(s,p,lon,lat);
CT = gsw_CT_from_t(SA,t,p);
end

