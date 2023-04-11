function [B,Ix,Iy] = get_submatrix_AAA(variable,varargin)
% get_submatrix_AAA creates sub-matrices (not sub-sampled) from an input
% matrix based on either a desired output size, or output number of
% matrices, allowing for overlapping segments.
%
% Designed for windowing for 2D spectra
%
% Alex Andriatis
% 2023-04-03
%
% Cases:
% 1) One segment
%   - Get the segment centered on the center of A
%
% 2) Fixed segment size, no overlap
%   - Loops through segments starting in the top left
%
% 3) Fixed segment size, overlap
%   - Loops through segments, starting in the top left. There is no overlap
%   in x but there is overlap in y, and every other row is also shifted in
%   x by the overlap ammount.
%
% 4) Fixed number of segments
%   1) If the original segment size is defined, and it creates more
%   segments than the requested number, the output is truncated a numseg
%   segments;
%   2) If the original segment size is not defined, or if the requested
%   segment size does not produce enough segments, the script tries progressively smaller segment size, preserving the aspect ratio
%   of the original image (or original segment size, if defined), until the
%   desired number of segments is reached.
%
%
% Inputs:
%   Required:
%       variable;   An input matrix of size NY x NX
%   Optional:
%       segsize;    A 1x2 vector [SY,SX] specifying the output matrix sizes (default size(variable))
%       numseg;     A number specifying the output number of segments to produce (default 0)
%       overlap;    A ratio specifying the allowable overalp in x and y of
%       neighboring segments. This isn't intuitive, but an overlap of 0.5
%       means that the center of a given matrix is the corner of a matrix
%       on its diagonal.
%
% Outputs:
%       B;       An output matrix of size SY x SX x NS where NS is the resulting number of segments, truncated at numseg, if defined.
%       Ix;      A matrix of size SX x NS which has as its columns the x-indices used to generate each of the submatrices in B
%       Iy;      A matrix of size SY x NS which has as its columns the y-indices used to generate each of the submatrices in B
%
%
% Examples:
% A=1:NY*NX
% A=reshape(A,[NY NX]);
%
% B = get_submatrix_AAA(A); % Returns A;
% B = get_submatrix(AAA,'segsize',[SY SX]); % Returns non-overlapping submatrices of size SY x SX
% B = get_submatrix(AAA,'numseg',NS); % Returns NS non-overlapping sumatrices of as big a size as possible while preserving the aspect ratio of A
% B = get_submatrix(AAA,'segsize',[SY SX],'overlap',0.5); % Returns submatrices of size SY x SX with 50% overlap
% B = get_submatrix(AAA,'segsize',[SY SX],'overlap',0.5,'numseg',NS); % Returns NS submatrices with 50% overlap of either size SY x SX or a smaller size that has the approximate aspect ratio of SY x SX if not enough submatrices could be generated with the original sumatrix size
%
% Alex Andriatis
% 2023-04-03

P=inputParser;
addRequired(P,'variable',@isnumeric);

defaultSegSize = size(variable);
addParameter(P,'segsize',defaultSegSize,@isnumeric);

defaultNumSeg = 0;
addParameter(P,'numseg',defaultNumSeg,@isnumeric);

defaultOverlap=0;
addParameter(P,'overlap',defaultOverlap,@isnumeric);

parse(P,variable,varargin{:});
A = P.Results.variable;
segsize = P.Results.segsize;
numseg = P.Results.numseg;
overlap = P.Results.overlap;

Asize=size(A);

NY=Asize(1);
NX=Asize(2);
SY=segsize(1);
SX=segsize(2);

segsize0=segsize; % Record the original requested segment size

if any(segsize>Asize)
    error('Requested segment size must be equal or smaller than input matrix');
end
if any(segsize<2)
    error('Requested segment size is too small, must be at least 2x2 matrix');
end

if overlap<0 || overlap>1
    error('Overlap must be between 0 and 1');
end

% Define coordinates of top-left bins, Run until the desired number of segments is generatred. 
tl_coord=zeros(0,2);
NS=-1;
while NS<numseg
if numseg==1 % For just one segment, reutrn a segment centered on original matrix 
    xcent = floor(NX/2);
    ycent = floor(NY/2);
    tl_coord(1,1)=ycent-floor(SY/2)+1;
    tl_coord(1,2)=xcent-floor(SX/2)+1;

else % For multiple segments, loop over each row and column
    nj=0;
    ns=0;
    % Define the y-indices of each top-left corner for each submatrix
    for j=1:max(floor(SY*(1-overlap)),1):NY-SY+1
        % Every other row, shift the start of the x-index by the overlap
        switch mod(nj,2)
            case 0
                for i=1:SX:NX-SX+1
                    ns=ns+1;
                    tl_coord(ns,1)=j;
                    tl_coord(ns,2)=i;
                end
            case 1
                for i=mod(floor(SX*(1-overlap)),SX)+1:SX:NX-SX+1
                    ns=ns+1;
                    tl_coord(ns,1)=j;
                    tl_coord(ns,2)=i;
                end
        end
        nj=nj+1;
    end
end
NS=size(tl_coord,1);
if NS>=numseg
    continue
else
    % If the selected segment size is too big to generate the desired
    % number of segments, reduce the segment size
    segsize0=segsize0*0.9;
    segsize=floor(segsize0);
    SY=segsize(1);
    SX=segsize(2);
    if any(segsize<2)
        error('Too many requested segments, resulting data less than 2x2');
    end
end
end

% Save each submatrix and the indices associated with it
B=NaN(SY,SX,NS);
Iy=NaN(SY,NS);
Ix=NaN(SX,NS);
for n=1:NS
    Iy(:,n)=tl_coord(n,1):tl_coord(n,1)+SY-1;
    Ix(:,n)=tl_coord(n,2):tl_coord(n,2)+SX-1;
    B(:,:,n)=A(Iy(:,n),Ix(:,n));
end

% Truncate the output if the result gives more submatrices than requested
if numseg>1
    B=B(:,:,1:numseg);
    Iy=Iy(:,1:numseg);
    Ix=Ix(:,1:numseg);
end    
end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    