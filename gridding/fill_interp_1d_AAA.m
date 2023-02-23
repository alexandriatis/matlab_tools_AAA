function filled = fill_interp_1d_AAA(x,data,varargin)
% This function fills over nans in the data with linear interpolation
% Optional arguments to use extrapolation, and to ignore segments with a
% time gap larger than some criteria
%
% Examples:
%   y = fill_interp_1d_AAA(x,y); % Fills all gaps with linear interpolation
%   y = fill_interp_1d_AAA(x,y,'Interp','linear','Extrap','extrap'); % Fills
%   gaps with linear interpolation and extrapolates
%   y = fill_interp_1d_AAA(x,y,'GapFill',dt); % Fills gaps smaller or equal
%   to size dt
%
% Alex Andriatis
% 2022-10-10

P=inputParser;
addRequired(P,'x',@isnumeric);
addRequired(P,'data',@isnumeric);

defaultInterp = 'linear';
checkString=@(s) any(strcmp(s,{'linear','nearest','next','previous','pchip','cubic','v5cubic','makima','spline'}));
addParameter(P,'Interp',defaultInterp,checkString);

defaultExtrap = 'none';
checkString=@(s) any(strcmp(s,{'none','extrap'}));
addParameter(P,'Extrap',defaultExtrap,checkString);

defaultGapFill = 0;
addParameter(P,'GapFill',defaultGapFill,@isnumeric);

parse(P,x,data,varargin{:});
x = P.Results.x;
data = P.Results.data;
Interp = P.Results.Interp;
Extrap = P.Results.Extrap;
GapFill = P.Results.GapFill;

dor = orientation_1d_AAA(data);
x=column_AAA(x);
data=column_AAA(data);

I=~isnan(data);
if ~all(I)
    xI = x(I);
    dataI = data(I);
    if GapFill==0
        if strcmp(Extrap,'extrap')
            filled = interp1(xI,dataI,x,Interp,'extrap');
        else
            filled = interp1(xI,dataI,x,Interp,'none');
        end
    else
        I=find(~isnan(data));
        Idt=find(diff(I)>1);
        for t=1:length(Idt)
            dttmp=x(I(Idt(t)+1))-x(I(Idt(t)));
            if dttmp>GapFill
                continue;
            end
            xtmp=[x(I(Idt(t))) x(I(Idt(t)+1))];
            ytmp=[data(I(Idt(t))) data(I(Idt(t)+1))];
            data(I(Idt(t)):(I(Idt(t)+1)))=interp1(xtmp,ytmp,x(I(Idt(t)):(I(Idt(t)+1))),Interp);
        end
        filled=data;
    end
end
filled = orient_1d_AAA(filled,dor);
end