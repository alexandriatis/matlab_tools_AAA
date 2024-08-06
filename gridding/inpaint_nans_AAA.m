function z=inpaint_nans_AAA(z,nanflag,method)
% Does inpaint_nans but if no extrapolation is requested, doesn't
% extrapolate
%
% Alex Andriatis
% 2023-06-14

if ~exist('method','var')
    method=0;
end
if exist('nanflag','var') && strcmp(nanflag,'extrap')
    z=inpaint_nans(z,method);
    return
end
[NY,NX]=size(z);
Iylim=NaN(2,NX);
Ixlim=NaN(NY,2);
mask=~isnan(z);
for n=1:NX
    tmp=find(mask(:,n)==1,1,'first');
    if isempty(tmp)
        tmp=NY+1;
    end
    Iylim(1,n)=tmp;
    
    tmp=find(mask(:,n)==1,1,'last');
    if isempty(tmp)
        tmp=0;
    end
    Iylim(2,n)=tmp;
end
for n=1:NY
    tmp=find(mask(n,:)==1,1,'first');
    if isempty(tmp)
        tmp=NX+1;
    end
    Ixlim(n,1)=tmp;
    tmp=find(mask(n,:)==1,1,'last');
    if isempty(tmp)
        tmp=0;
    end
    Ixlim(n,2)=tmp;
end
z=inpaint_nans(z,method);

for n=1:NX
    if Iylim(1,n)>1
        z(1:Iylim(1,n)-1,n)=NaN;
    end
    if Iylim(1,n)<NY
        z(Iylim(2,n)+1:NY,n)=NaN;
    end
end
for n=1:NY
    if Ixlim(n,1)>1
        z(n,1:Ixlim(n,1)-1)=NaN;
    end
    if Ixlim(n,2)<NX
        z(n,Ixlim(n,2)+1:NX)=NaN;
    end
end