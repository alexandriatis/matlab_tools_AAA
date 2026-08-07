function letter=alphabet_AAA(n)
% Returns the nth letter of the english alphabet in lowercase, or the whole
% alphabet if no value is given
%
% Alex Andriatis
% 2023-08-16
if ~exist('n','var')
    n=0;
end
alphabet='a':'z';
if n==0
    letter=alphabet;
elseif abs(n)>length(alphabet)
    error('Request an index within the english alphabet');
else
    letter=alphabet(abs(n));
end
if n<0
    letter=upper(letter);
end