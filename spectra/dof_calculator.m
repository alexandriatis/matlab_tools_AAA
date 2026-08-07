%% Degree of Freedom Calculation
% Arbitrary window and overlap segments as described by Sarah Gille in 
% http://pordlabs.ucsd.edu/sgille/sioc221a/lecture11_notes.pdf

function [nu] = dof_calculator(seglength,numseg,window,overlap) 

Ns = seglength;
Nb = numseg;

h=[];
if strcmp(window,'boxcar')==1 % (4/3)*Nb for 50% overlap
    h = rectwin(Ns);
elseif strcmp(window,'triangle')==1 % (16/9)*Nb for 50% overlap
    h = triang(Ns);
elseif strcmp(window,'hanning')==1 % (36/19)*Nb for 50% overlap
    h = hanning(Ns);
elseif strcmp(window,'hamming')==1 % (~1.80)*Nb for 50% overlap
    h = hamming(Ns);
end
h = h/sqrt(sum(h.^2)); %normalize window so that int(h.^2)=1
n = round(Ns*(1-overlap)); %number of points of overlap between segments

sumh=[];
for m=1:Nb-1
    if Ns-m*n>=1
        sumh(m) = (1-m/Nb)*abs(sum(h(1:Ns-m*n).*h(1+m*n:Ns)))^2; % Equation 12 in notes
    end
end
denom = 1+2*sum(sumh);
nu_eff = 2/denom;
nu = Nb*nu_eff;
pars_str = 'Dof normalization is %0.3f \n';
%fprintf(pars_str,nu_eff);
