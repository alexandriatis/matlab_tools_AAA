function f=k2f_AAA(k)
% Deep water linear surface gravity wave conversion from wavenumber to
% frequency space
k_or=orientation_1d_AAA(k);

k=row_AAA(k);
g = gravity;
f = sqrt(g*k)/(2*pi);
f=orient_1d_AAA(f,k_or);