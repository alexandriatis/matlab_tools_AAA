function y = angle_between_vectors_AAA(a,b)
% Give the angle between two vectors A and B
y = rad2deg(acos(dot(a / norm(a), b / norm(b))));
end