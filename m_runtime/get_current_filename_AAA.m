function mfilePath=get_current_filename_AAA
% Returns the file name of the script that's currently running. Useful for
% saving filepaths on figures so that I know where they came from
%
% Alex Andriatis
% 2024-05-13
ST = dbstack('-completenames');
mfilePath = ST(end).file;
if contains(mfilePath,'LiveEditorEvaluationHelper') || isempty(mfilePath)
    mfilePath = matlab.desktop.editor.getActiveFilename;
end
