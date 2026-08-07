function save_AAA(savepath,savename,data)
% This function saves data within a parfor loop
%
% Alex Andriatis
% 2022-08-15
save(fullfile(savepath,savename),'-struct','data','-v7.3');
disp(['Saved file ' savename]);
end

