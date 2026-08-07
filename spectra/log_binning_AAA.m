function [ma_g,f_g] = log_binning_AAA(f,ma,scaling)
% This function is for log-binning spectra such that higher frequencies are
% binned uniformly in log space, for neater spectral plots
%
% Alex Andriatis
% 2024-01-29

Inan=~isnan(ma);
f=f(Inan);
ma=ma(Inan);

if ~exist('scaling','var')
    scaling=1;
end


f=unique(f);
If=find(f>0,2,'first');
df=range(f(If));
frange=[f(If(1)) max(f)];

dfg=log10(df)-floor(log10(df));
% Find the percentage of the plot that one frequency step uses
dfg=dfg/(scaling*2);
f_g=log10(f(If(1))):dfg:log10(f(end));
f_g=10.^(f_g);
If=(f_g>=min(f)) & f_g<=max(f);
f_g=f_g(If);

ma_g=binning_AAA(f,ma,f_g,'Interpfill','interp');
end