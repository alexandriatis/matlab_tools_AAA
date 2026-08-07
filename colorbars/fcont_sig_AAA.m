function fcont_lev = fcont_sig_AAA(zdata,nsig)
% fcont_sig_AAA gets the colorbar limits to nsig * sigma of the color range
if ~exist('nsig','var')
    nsig=2.575829; % 99% of data
end
zdata(isinf(zdata))=NaN;
tcent = mean(zdata,'all','omitnan');
tvar = std(zdata,0,'all','omitnan');
fcont_lev = [tcent - nsig*tvar, tcent + nsig*tvar];