function mlp = seawater_MLP_AAA(SA,CT,P)
% function mlp = seawater_MLP_AAA(SA,CT,P) calculates the mixed-layer
% pressure (depth) based on  de Boyer Montégut et al. (2004).
%
% http://www.ifremer.fr/cerweb/deboyer/mld/Surface_Mixed_Layer_Depth.php
% MLD_DReqDTm02 = depth where ( σ0 = σ010m + Δσ0 ) 
% with Δσ0 = σ0(θ10m - 0.2°C, S10m, P0) - σ0(θ10m, S10m, P0)
%
% Inputs: SA:   Practical Salinity [psu] from GSW 3.6
%         CT:   Conservative Temperature [deg] from GSW 3.6
%         P:    Pressure, increasing downwards
% They all need to be vectors of the same length
%
% Outputs: mlp: Mixed-layer pressure
%
% Alex Andriatis
% 07-22-2022
%
% Updated to work only with pre-sorted profiles of SA and CT to remove
% ambiguity. Still only works on single profiles.
%
% Alex Andriatis
% 2024-05-28
%
% Updated to work by using the mean temperature above the target depth
% rather than the temperatrue at 10 m
% 2024-08-22

sig0 = gsw_sigma0(SA,CT);

I=~isnan(sig0);
P=P(I);
sig0=sig0(I);
SA=SA(I);
CT=CT(I);

if sum(I)<2
    warning('Less than two sample points');
    mlp=NaN;
    return
end

% Vertically average the density, temperature, and salintiy
%sig0_mean=cumtrapz(P,sig0)./(P-P(1));
SA_mean=cumtrapz(P,SA)./(P-P(1));
CT_mean=cumtrapz(P,CT)./(P-P(1));

% Need the target density to be 0.2C colder than the average above it
sig0_tar=NaN(size(P));
for n=1:length(sig0_tar)
    sig0_tar(n)=gsw_sigma0(SA_mean(n),CT_mean(n)-0.2);
end

% Find the first depth at which the density is greater than the target
% density
Imld=find(sig0>=sig0_tar,1,'first');

if Imld>1
    %mlp = interp1(sig0(Imld-1:Imld),P(Imld-1:Imld),)
    mlp = intersections(P(Imld-1:Imld),sig0(Imld-1:Imld),P(Imld-1:Imld),sig0_tar(Imld-1:Imld));
else
    mlp=NaN;
end