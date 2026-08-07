function theta2 = rotate_heading_AAA(theta)
% This function is made for rotating heading direction from 
% counterclockwise, going towards, reference east (CCW, gt, RE) to
% clockwise, coming from, reference north (CW, cf, RN) 
% and vice versa. 
%
% All angles are in degrees
%
% Alex Andriatis
% 2022-05-02

theta = -theta-90;
theta2 = fix_angular_direction_AAA(theta,'deg');