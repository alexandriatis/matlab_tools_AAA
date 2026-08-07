function data = load_AAA(datapath,dataname)
% This function loads data within a parfor loop
%
% Alex Andriatis
% 2022-08-15
if exist('dataname','var')
    data = load(fullfile(datapath,dataname));
else
    data = load(datapath);
end
end

