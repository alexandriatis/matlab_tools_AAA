function I = find_bordering_NaNs_AAA(data,number,direction)
% function find_bordering_NaNs_AAA gives the indices of data that ether
% precedes or follows a NaN value. Used for data QC, expecially binning,
% where the index closest to missing data might not be trustworthy.
%
% Usage
%   data = [NaN 2 3 4 NaN];
%   I = find_bordering_NaNs_AAA(data,1,'before');
%   data(I)=NaN;
%
% Examples:
%   I = find_bordering_NaNs_AAA(data);
%   I = find_bordering_NaNs_AAA(data,2,'after');
% 
% Inputs:
%   data:   a row vector of some data
%   number: the number of points bordering a NaN to remove (default 1)
%   direction: either 'before','after', or 'both' (default 'both')
%
% Outputs:
%   I:      the indices of the (number) points either before, after, or on
%           either side of a NaN value in the data
%
% Alex Andriatis
% 2022-08-11

    if ~exist('number','var') || isempty(number)
        number = 1;
    end
    if ~exist('direction','var') || isempty(direction)
        direction = 'both';
    end
    
    L=find(~isnan(data));
    J = [0, L, length(data)+1];
    M = find(diff(J)>1);
    I=[];
    
    if strcmp(direction,'before') || strcmp(direction,'both')
        for i=1:number
            N = M-i;
            N(N<=0 | N>length(L))=[];
            I = [I,L(N)];
        end
    end
    if strcmp(direction,'after') || strcmp(direction,'both')
        for i=1:number
            N = M+i-1;
            N(N<=0 | N>length(L))=[];
            I = [I,L(N)];
        end
    end    
    I = unique(I);
end