function [xd,dy]=diff_AAA(x,y)
% function diff_AAA is for computing the simple dy/dindex, but also gets
% the centerpoint of the x-vector it's associated with, because it's
% annoying to write it out each time.
% 
% A common use case is when looking at variations in measurement time step
% in a dataset, where the time step in seconds is dt=diff(time)*86400. But
% how do you get a vector to plot this against? Easiest method is to plot
% against time(1:end-1) or time(2:end), but that would misrepresent the
% location of the time step. There exists the function gradient, which
% computes the centerpoint difference except at the endpoints, but that
% creates extra data. Here, I get the x-vector using the simple linear
% centerpoint xd = (time(1:end-1)+time(2:end))/2;
%
%
% Alex Andriatis
% 2022-09-15

dy = diff(y);
xd = (x(1:end-1)+x(2:end))/2;