function save_AAA(savepath,savename,data)
% This function saves data within a parfor loop
%
% Alex Andriatis
% 2022-08-15
save(fullfile(savepath,savename),'-struct','data');
disp(['Saved file ' savename]);
end

