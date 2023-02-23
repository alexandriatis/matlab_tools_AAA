function export_fig_AAA(f,figpath,figname,speed)
savepath=fullfile(figpath,figname);

if ~exist('speed','var')
    speed='fast';
end

switch speed
    case 'fast'
        savefig(f,savepath,'compact');
        print(f,savepath,'-dpng','-r150');
    case 'fancy'
        %savefig(f,savepath); 
        export_fig(f,fullfile(figpath,figname),'-r300','-dpng','-transparent');
    otherwise
        error('Unrecognized save option');
end
disp(['Saved figure ' figname]);