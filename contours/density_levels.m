function dlevels = density_levels(density,varargin)
% This function is designed to calculate the density levels at which to
% draw contours when making contourf plots of oceanographic variables.
%
% Inputs:
%   Required:
%      density: A maxtirx of size depth x time, units don't matter
%   Optional:
%       weighting:  A string set to either 'equal' or
%                               'pycnocline' determining the spacing of
%                               density contours. Default 'equal'.
%       levels :       The number of density contours to plot.
%                               Default is 10.
%
% Outputs:
%   dlevels: A vector of denisites at which contour lines will be drawn
%
% Example:
%   dlevels = density_levels(density);
%   dlevels =   density_levels(density,'weighting','pycnocline','levels',11);

dlevels=[];

% Parse Inputs
P=inputParser;
addRequired(P,'density',@isnumeric);
if ndims(density)~=2
    error('Density should be a 2-d matrix of depth x time');
end

default_weighting = 'equal';
checkString=@(s) any(strcmp(s,{'equal','pycnocline'}));
addParameter(P,'weighting',default_weighting,checkString);

default_levels = 10;
addParameter(P,'levels',default_levels,@isnumeric);

parse(P,density,varargin{:});
weighting = P.Results.weighting;
levels = P.Results.levels;


% Mean Density
mean_density = mean(density,2,'omitnan'); % Mean in time
mean_density = sort(mean_density); % Sorted in depth 
mean_density = mean_density(~isnan(mean_density)); % Remove NaNs

% Pick density indices to plot
if strcmp(weighting,'equal')
    numdens = round(linspace(1,length(mean_density),levels+2));
    Idens = numdens(2:end-1);
elseif strcmp(weighting,'pycnocline')
    numdens = linspace(mean_density(1),mean_density(end),levels+2);
    [~,Idens] = closest_AAA(mean_density,numdens,1);
    Idens = Idens(2:end-1);
    Idens = unique(Idens);
end
dlevels = mean_density(Idens);
end




