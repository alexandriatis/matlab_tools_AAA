%Waiting for matlab to improve the functionality of exportgraphics before
%switching over to this new figure saving routine
%
%
% function export_fig_AAA(f,figpath,figname,speed,format)
savepath=fullfile(figpath,figname);

if ~exist('speed','var')
    speed='fast';
end
if ~exist('format','var')
    format={'fig','png'};
end

drawnow; % This might prevent some crashes on memory overload on large figs
switch speed
    case 'fast'
        plot_fname_timestamp_AAA(f); % Plot the file name of the script used to generate the figure
        resolution = 150;
        if any(contains(format,'fig'))
            savefig(f,savepath,'compact');
        end
        if any(contains(format,'png'))
            %print(f,savepath,'-dpng',resolution);
            exportgraphics(f,[savepath '.png'],'BackgroundColor','none','Resolution',resolution);
        end
        if any(contains(format,'pdf'))
            print(f,savepath,'-dpdf',resolution,'-fillpage');
        end
    case 'good'
        resolution = 300;
        if any(contains(format,'fig'))
            savefig(f,savepath,'compact');
        end
        if any(contains(format,'png'))
            print(f,savepath,'-dpng',resolution);
        end
        if any(contains(format,'pdf'))
            print(f,savepath,'-dpdf',resolution,'-fillpage');
        end
    case 'fancy'
        resolution = 300;
        if any(contains(format,'fig'))
            savefig(f,savepath);
        end
        if any(contains(format,'png'))
            export_fig(f,savepath,resolution,'-dpng','-transparent');
        end
        if any(contains(format,'pdf'))
            export_fig(f,savepath,resolution,'-dpdf','-transparent');
        end
    otherwise
        error('Unrecognized save option');
end
pause(0.1); % Again to prevent memory overload
disp(['Saved figure ' figname]);