function trend=logline_AAA(xdata,m,b)
    trend = 10.^(m*log10(xdata)+b); % Linear trend in log space