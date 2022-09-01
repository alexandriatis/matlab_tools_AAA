function [time_gap,variable_gap] = contour_gaps(time,variable,tdif)
% Code for making contour plots with gaps
% Inputs:
%   time - vector of matlab datenum
%   variable - depth x time
%   tdif - max allowable gaps
%
% Alex Andriatis
% 2021-03-17

dt = diff(time); % Difference beween profile times in days
It = find(dt>tdif); % Find indices where the gap between profiles is more than tdif days

time_original = time; % Save the time vector
for i=1:length(It)
    % For each gap, append a time representing the mean time of the gap
    time(end+1)=mean([time_original(It(i)),time_original(It(i)+1)]);
end
% Sort the times to get the gaps in the right place
[time_gap,I]=unique(time);
% Add rows of NaNs in the data to match the extra time indices
variable(:,end+1:end+length(It))=NaN(size(variable,1),length(It));
% Sort the data
variable_gap = variable(:,I);
