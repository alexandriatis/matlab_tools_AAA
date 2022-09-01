function tlabel = fix_title_AAA(flabel)
% function tlabel cleans up strings that are set as titles in figures.
% The primary function is to replace underscores with spaces, since those
% are commonly used in file and field names which I might not want.
%
% Usage: tlabel = fix_title_AAA(flabel); where flabel is a string.
%
% Alex Andriatis
% 2022-08-04

flabel = strrep(flabel, '_', ' ');
flabel = strrep(flabel, '.mat', '');

tlabel = flabel;
