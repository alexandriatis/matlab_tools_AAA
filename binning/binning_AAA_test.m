function [y_binned,x_center]=binning_AAA_test(x,y,bins,varargin)
% This fucntion is designed to bin data 
%
% Alex Andriatis
% 2021-08-13
%
% Improved to handle 2-d binning (just 1-d binning with a for loop)
% 2022-05-30

P=inputParser;
addRequired(P,'x',@isnumeric);
addRequired(P,'y',@isnumeric);
addRequired(P,'bins',@isnumeric);

defaultEdges = 'center';
checkString=@(s) any(strcmp(s,{'center','edges'}));
addParameter(P,'BinCentering',defaultEdges,checkString);

defaultInterpFill = 'none';
checkString=@(s) any(strcmp(s,{'none','interp','extrap'}));
addParameter(P,'InterpFill',defaultInterpFill,checkString);

parse(P,x,y,bins,varargin{:});
x = P.Results.x;
y = P.Results.y;
bins = P.Results.bins;
BinCentering = P.Results.BinCentering;
InterpFill = P.Results.InterpFill;

use_edges=0;
if exist('option','var')
    if strcmp(option,'edges')
        use_edges=1;
    end
end

if ~isvector(x)
    error('Input x must be a vector');
end
if ~isvector(bins)
    error('Input bins must be a vector');
end
if ~ismatrix(y)
    error('Can only bin 1 or 2-d data');
end
xorient = orientation_1d_AAA(x);

[M,N]=size(y);
compcase = 0;
if M==length(x)
    compcase = 1;
elseif N==length(x)
    compcase = 2;
else
    error('Not sure what to do with your input');
end

% Make sure x and bins are column vectors
x = column_AAA(x);
bins = column_AAA(bins);

[x,I]=sort(x);
if strcmp(BinCentering,'center')
    edges(1)=bins(1);
    edges(2:length(bins))=bins(1:end-1)+diff(bins)/2;
    edges(length(bins)+1)=bins(end);
    x_center = bins;
elseif strcmp(BinCentering,'edges')
    edges = bins;
    x_center = edges(1:end-1)+diff(edges)/2;
else
    error('Unrecognized bin option');
end

bin_ind = discretize(x,edges);
I2=~isnan(bin_ind);
bin_ind = bin_ind(I2);

switch compcase
    case 1
        tmp = y(I,:);
        tmp = tmp(I2,:);
        [xx,yy]=ndgrid(bin_ind,1:N);
    case 2
        tmp = y(:,I);
        tmp = tmp(:,I2);
        tmp = tmp';
        [xx,yy]=ndgrid(bin_ind,1:M);
end
tmp_binned = accumarray([xx(:) yy(:)],tmp(:));



% tmp_binned = fill_interp_2d_gridded_AAA(x,y,data,interp,extrap)
%         
% 
% 
% switch compcase
%     case 1
%         yorient = orientation_1d_AAA(y);
%         y = column_AAA(y);
%         y = y(I);
%         y = y(I2);
%         y_binned = accumarray(bin_ind,y(I2),[length(bins),1],@nanmean,NaN);
%         if strcmp(InterpFill,'interp') && sum(~isnan(y_binned))>=2
%             y_binned = interp1(x_center(~isnan(y_binned)),y_binned(~isnan(y_binned)),x_center,'linear');
%         elseif strcmp(InterpFill,'extrap') && sum(~isnan(y_binned))>=2
%             y_binned = interp1(x_center(~isnan(y_binned)),y_binned(~isnan(y_binned)),x_center,'linear','extrap');
%         end
%         y_binned = orient_1d_AAA(y_binned,yorient);
%         
%     case 2
%         y_binned = NaN(length(x_center),N);
%         tmp = y(I,:);
%         tmp = tmp(I2,:);
%         
%         [xx,yy]=ndgrid(bin_ind,1:N);
%         
%         
% end
% tmp_binned = accumarray([xx(:) yy(:)],tmp(:));
%         
%         for t=1:N
%             fprintf('%i percent done \n',round(t/N*100));
%             tmp = y(:,t);
%             tmp = column_AAA(tmp);
%             tmp = tmp(I);
%             tmp_binned = accumarray(bin_ind(I2),tmp(I2),[length(bins),1],@nanmean,NaN);
%             if strcmp(InterpFill,'interp') && sum(~isnan(tmp_binned))>=2
%                 tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear');
%             elseif strcmp(InterpFill,'extrap') && sum(~isnan(tmp_binned))>=2
%                 tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear','extrap');
%             end
%             y_binned(:,t) = tmp_binned;
%         end
%     case 3
%         y_binned = NaN(M,length(x_center));
%         for t=1:M
%             fprintf('%i percent done \n',round(t/M*100));
%             tmp = y(t,:);
%             tmp = column_AAA(tmp);
%             tmp = tmp(I);
%             tmp_binned = accumarray(bin_ind(I2),tmp(I2),[length(bins),1],@nanmean,NaN);
%             if strcmp(InterpFill,'interp') && sum(~isnan(tmp_binned))>=2
%                 tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear');
%             elseif strcmp(InterpFill,'extrap') && sum(~isnan(tmp_binned))>=2
%                 tmp_binned = interp1(x_center(~isnan(tmp_binned)),tmp_binned(~isnan(tmp_binned)),x_center,'linear','extrap');
%             end
%             y_binned(t,:) = tmp_binned;
%         end
%     otherwise
%         error('Unrecognized case');
% end
x_center = orient_1d_AAA(x_center,xorient);
end






