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

% Sort pressure just to make sure everything is in the right order
[P,Isort] = sort(P,'ascend');
SA = SA(Isort);
CT = CT(Isort);

sig0 = gsw_sigma0(SA,CT);
% Sort it to remove inversions
[sig0,Isort] = sort(sig0,'ascend');

% Get sigma0 at 10m
t10 = interp1(P,CT(Isort),10);
s10 = interp1(P,SA(Isort),10);
sig_ref = gsw_sigma0(s10,t10);

% Get sigma0 at MLD
sig_tar = gsw_sigma0(s10,t10-0.2);

% Get density difference
dsig0 = sig_tar-sig_ref;

% Get sigma0 at 10m
sig10 = interp1(P,sig0,10);

% Sigma at MLD
sig_mld = sig10+dsig0;

% Find the depth of sig_mld
mlp = interp1(sig0,P,sig_mld);
end