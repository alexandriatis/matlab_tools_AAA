function [rho_sort,I]=sort_rho_AAA(SA,CT,p)
%
% sort_rho_AAA sorts the in-situ density profile such that the resulting
% stratification is non-negative
%
% This method ensures that the density at each depth is calculated relative
% to its reference pressure
%
% For limited depth ranges, this method gives approximately the same result
% as sorting density using a density profile relative to a constant depth,
% i.e. the surface. Over greater depth ranges, this method is better than
% using a constant reference depth.
%
% USAGE:  
%  [rho_sort,Isort]=sort_rho_AAA(SA,CT,p)
%
% INPUT:
%  SA  =  Absolute Salinity                                        [ g/kg ]
%  CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
%  p   =  sea pressure                                             [ dbar ]
%         ( i.e. absolute pressure - 10.1325 dbar )
%
%  SA, CT, and p all need to have dimensions Nx1.
%
% OUTPUT:
%  rho_sort  = sorted in-situ density                            [ kg/m^3 ]
%
% AUTHOR: 
%  Alex Andriatis, 2024-01-19
%

% Code works only on single profiles
SA=SA(:);
CT=CT(:);
p=p(:);
if range([length(SA),length(CT),length(p)]~=0)
    error('SA, CT, and p must have same dimensions')
end

% Requires monotonically increasing pressure
if any(diff(p)<0)
    error('Requires monotonically increasing pressure');
end

% Remove NaNs
I=1:length(SA);
I=I(:);
rho_sort=NaN(size(SA));
Inan=find(~isnan(SA)&~isnan(CT)&~isnan(p));
SA=SA(Inan);
CT=CT(Inan);
p=p(Inan);

% For each depth, compute the density profile relative to that depth, pick
% the index with the smallest density, and continue, removing previously
% assigned indices from further calculation
NZ=length(SA);
Ind=1:NZ;
Isort=Ind;
Ifree=true(1,NZ);
for k=1:NZ
    % Calculate the density profile referenced to the current depth
    rtemp=gsw_rho(SA(Ifree),CT(Ifree),p(k));
    % Pick the index with the minimum density
    Itmp=Ind(Ifree);
    [~,Imin]=min(rtemp);
    % Remember the sorted density for each depth, and remove it from
    % further calculation
    Isort(k)=Itmp(Imin);
    Ifree(Itmp(Imin))=false;
end
% Compute the new sorted density profile
rho=gsw_rho(SA(Isort),CT(Isort),p);

% Add back in NaNs if they existed
I(Inan)=Inan(Isort);
rho_sort(Inan)=rho;