function export_movieframe_AAA(f,figpath,figname,resolution)
savepath=fullfile(figpath,figname);

% Key for movies is making sure that saved movie dimensions are divisible by 2
% apparently

% Final figure size is given by image pixels / pixels per inch * resolution

% Get figure size in inches
set(f,'Units','inches');

width=round(f.Position(3)*resolution,5);
height=round(f.Position(4)*resolution,5);

while mod(width,2)~=0 || mod(height,2)~=0
    resolution = resolution+1;
    width=round(f.Position(3)*resolution,5);
    height=round(f.Position(4)*resolution,5);
end

rstring=sprintf('-r%i',resolution);
print(f,savepath,'-dpng',rstring);
end