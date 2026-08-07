function k=f2k_AAA(f)
% Deep water linear surface gravity wave conversion from wavenumber to
% frequency space
f_or=orientation_1d_AAA(f);

f=row_AAA(f);
g = gravity;
k=((2*pi*f).^2)/g;
k=orient_1d_AAA(k,f_or);
