% make_movie_parallel is an example script for making a moive of data. It works by
% defining a time grid for the movie and a timestep based on a frame rate,
% and then calls a function which does all the plotting, then saves the
% frames. It can run either in parallel in the background or in the
% foreground. To complile the movie use command line ffmpeg, or the script
% in convert_png_mp4.sh
%
% Alex Andriatis
% 2023-02-22

ccc;

%% Define movie paths
framename = 'movieframe'; % Placeholder name of movie frame for saving, doesn't really matter what this is
figpath = ['parfigs_movie']; % Folder to dump all the movie frames into
mkdir(figpath);

%% Construct a movie time vector 

sps = 60*24; % data seconds per playback second of movie
fps = 30; % Movie frames per playback second
dt = 1; % seconds per index of data (observation frequency)
ipf = round((1/dt)/(fps/sps)); % index per frame

%% Movie time grid
t1 = datenum(2020,11,20,18,00,00);
t2 = datenum(2020,11,21,03,00,00);

tgrid = t1:ipf*dt/86400:t2;

%%
NT = length(tgrid);
ndigits=ndigits_AAA(NT);
padstr=['%0' num2str(ndigits) 'd'];
fprintf('Starting a %i frame movie \n',NT);
overwrite=1;
tic;
%parfor (i=1:NT,10)
for i=1:NT
    figname = [framename '_' num2str(i,padstr)];
    if ~overwrite && exist([fullfile(figpath,figname) '.png'],'file')
        continue
    end
    t=tgrid(i);
    f=figure('visible','off');
    plot_movieframe();
    export_movieframe_AAA(f,figpath,figname,150);
    fprintf('Saved frame %i of %i\n',i,NT);
    close(f);
end
disp(['Finished plotting movie frames']);
toc;




