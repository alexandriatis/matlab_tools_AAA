function flabel = fix_fieldname_AAA(tlabel)
% function tlabel cleans up strings that are set as filenames in figures.
% The primary function is to replace spaces with underscores, since those
% are commonly used in title names which I might not want.
%
% Usage: flabel = fix_fname_AAA(tlabel); where flabel is a string.
%
% Alex Andriatis
% 2022-08-04

flabel = strrep(tlabel, ' ', '_');
flabel = strrep(flabel, '.mat', '');
flabel = regexprep(flabel,'^_','','emptymatch');
end
