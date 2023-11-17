function export_fig_AAA(f,figpath,figname,speed,format)
savepath=fullfile(figpath,figname);

if ~exist('speed','var')
    speed='fast';
end
if ~exist('format','var')
    format={'fig','png'};
end

switch speed
    case 'fast'
        resolution = '-r150';
        %resolution = '-r300';
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
        resolution = '-r300';
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
disp(['Saved figure ' figname]);