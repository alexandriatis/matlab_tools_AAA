function mlp = seawater_MLP_10_AAA(SA,CT,P)
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

sig0 = gsw_sigma0(SA,CT);

% Get sigma0 at 10m, or whatever is the shallowest depth
ztar=10;
if min(P)>ztar
    ztar=min(P);
end
t10 = interp1(P,CT,ztar);
s10 = interp1(P,SA,ztar);
sig_ref = gsw_sigma0(s10,t10);

% Get sigma0 at MLD
sig_tar = gsw_sigma0(s10,t10-0.2);

% Get density difference
dsig0 = sig_tar-sig_ref;

% Get sigma0 at 10m
sig10 = interp1(P,sig0,ztar);

% Sigma at MLD
sig_mld = sig10+dsig0;

% Find the depth of sig_mld
% Becasue there might be inversions, first find the depth, then refine
Itar=find(sig0>sig_mld,1,'first');
if Itar>1
    mlp = interp1(sig0(Itar-1:Itar),P(Itar-1:Itar),sig_mld);
else
    mlp = NaN;
end