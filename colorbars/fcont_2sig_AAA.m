function fcont_lev = fcont_2sig_AAA(zdata)
% fcont_2sig_AAA gets the colorbar limits to show 95% of the data
zdata(isinf(zdata))=NaN;
tcent = mean(zdata,'all','omitnan');
tvar = std(zdata,0,'all','omitnan');
fcont_lev = [tcent - 2*tvar, tcent + 2*tvar];