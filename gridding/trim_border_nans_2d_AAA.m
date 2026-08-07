function [z,Ix,Iy]=trim_border_nans_2d_AAA(z,nancrit)
% Trims edges of a 2D image to get rid of border NaNs
% Repeatedly trims the side with the most NaNs until all the sides meet
% the criteria for enough non-nan points, by default set to 95%
%
% Inputs:
%   z,          A 2-d matrix
%   nancrit,    An optional variable from 0 to 1 which is the percentage of
%               allowable NaNs left on any of the 4 borders.
%               If nancrit is set to 0, the code trims border rows and
%               columns that have only NaNs. If nancrit is set to 1, the
%               code makes all borders have no NaNs.
%
% Outputs:
%   z,          The trimmed 2-d matrix
%   Ix,         The indices of the input matrix remaining in the output
%               along the 2nd dimension
%   Iy,         Indices along the 1st dimension
%
% Example:
%   [z, Ix, Iy] = trim_border_nans_2d_AAA(z,0.99)
%
%   Trims the borders of input matrix z until each border has at least 99%
%   non-nan data. The output matrix z is equivalent to z=z(Iy,Ix)
%
% Alex Andriatis
% 2023-03-31

if ~exist('nancrit','var')
    nancrit = 0.95;
end

if nancrit==0
    nanind = isnan(z);
    mask = ones(size(z));
    mask(nanind)=NaN;

    mask_y = sum(mask,2,'omitnan');
    mask_x = sum(mask,1,'omitnan');
    x_low=find(mask_x>0,1,'first');
    x_high=find(mask_x>0,1,'last');
    y_low=find(mask_y>0,1,'first');
    y_high=find(mask_y>0,1,'last');
    Ix=x_low:x_high;
    Iy=y_low:y_high;
else

    trimmed=0;
    [NY,NX]=size(z);
    Ix=1:NX;
    Iy=1:NY;
    while ~trimmed
        NY = length(Iy);
        NX = length(Ix);
        
        if any([NY,NX]<3)
            trimmed=1;
            continue
        end
        
        x1=sum(~isnan(z(Iy(1),Ix)))/NX;
        x2=sum(~isnan(z(Iy(end),Ix)))/NX;
        
        y1=sum(~isnan(z(Iy,Ix(1))))/NY;
        y2=sum(~isnan(z(Iy,Ix(end))))/NY;
        
        if all([x1 x2 y1 y2]>=nancrit)
            trimmed=1;
            continue
        end

        [~,Icut]=min([x1/NX, x2/NX, y1/NY, y2/NY]);
        switch Icut
            case 1
                Iy=Iy(2:end);
            case 2
                Iy=Iy(1:end-1);
            case 3
                Ix=Ix(2:end);
            case 4
                Ix=Ix(1:end-1);
        end
    end
end
z=z(Iy,Ix);
end