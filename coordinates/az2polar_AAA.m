function theta2 = az2polar_AAA(theta)
% This function is made for rotating heading direction from clockwise,
% going towards, reference north (CW,GT,RN) to counterclockwise, going
% towards, reference east (CCW,GT,RE), and vice versa.
%
% A bit different than rotate_heading_AAA
%
% All angles are in degrees
%
% Alex Andriatis
% 2022-12-06

theta = fix_angular_direction_AAA(theta,'deg');
theta2 = 90-theta;
theta2 = fix_angular_direction_AAA(theta2,'deg');