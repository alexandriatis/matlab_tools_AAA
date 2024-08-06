function fstring=get_fname_timestamp_AAA
% Returns the time and the file name of the script that's currently running. 
% Useful for saving filepaths on figures so that I know where they came from
%
% Alex Andriatis
% 2024-05-13
mfilePath=get_current_filename_AAA;
ftime=datestr(now);
fstring=[ftime '  ' mfilePath];