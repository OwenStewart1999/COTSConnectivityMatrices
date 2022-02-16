function [x, y] = createCircle(xc, yc, radius, nPoints)

% ceebs commenting
theta = linspace(0, 2*pi, nPoints);
x = radius * cos(theta) + xc;
y = radius * sin(theta) + yc;
end