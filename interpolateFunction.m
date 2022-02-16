function intFunc = interpolateFunction(discFunc, interval)
% interpolateFunction will interpolate a given discrete function using
% simple linear interpolation as polynomial interpolation proved to be
% grossly innacurate

% inputs:
% discFunc - a discreate function in the form n x 2 where n is the number
% of data points, the bottom row is the dependent variable and the top row
% is the independent variable
% interval - the interval for the independent variable to be discretised
% into, i.e. 1 for integer differences, 0.1 for 0.1 differences etc

% output: 
% intFunc - the interpolated function values in the form m x 2 where again
% the top row is the dependent variable and the bottom is the independent

% fuck it I think I need to just interpolate the points

% determine the number of points
n = size(discFunc, 2);

% determine the new interpolation positions, using rounding - determine the
% upper and lower bounds
lowerBound = ceil(min(discFunc(1, :)) / interval) * interval; 
upperBound = floor(max(discFunc(1, :)) / interval) * interval; 

% now create a set of points we want to discretise over
intPoints = lowerBound:interval:upperBound; % working

% interpolate over those points
intVals = interp1(discFunc(1, :), discFunc(2, :), intPoints);

% now combine output
intFunc =  [intPoints; intVals];

end
