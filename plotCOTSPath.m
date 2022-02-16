function plotCOTSPath(GBRShape, larvaeStruct, indices)
% visualiseDispersalPath will allow you to visualise the path taken during
% larval dispersal by specific larvae seeds indicated in the indices array
% the map of positions will also be colour coded to represent the
% self-relative times each position was met

% inputs:
% GBRShape - a structure taken from a shapefile with the borders of each
% reef in the fields X and Y
% larvaeStruct - a structure where each entry corresponds to a separate
% larvae which holds the fields time_days, X and Y which hold the positions
% reached during dispersal and the time at which each of these positions
% were recorded

% going to use the jet colormap to map the times out

% first, plot the GBRShape
plotGBRShape(GBRShape, "fig", "holdOn", [], 'k')

% now, loop through each of the larval indices
for i = 1:length(indices)

    % extract the times for the current larvae and convert to indices in
    % the cMap object
    times = larvaeStruct(indices(i)).time_days_floored;
    maxTime = max(times);

    % grab out the X and Y coords simply because it will be easier that way
    X = larvaeStruct(indices(i)).X;
    Y = larvaeStruct(indices(i)).Y;

    % now loop through and plot each of the positions
    for j = 1:(length(times) - 1)
        if times(j) == 0
            times(j) = 1;
        end
        plot([X(j), X(j+1)], [Y(j), Y(j+1)], "color", getColour(times(j), maxTime, "jet"), "LineWidth", 2)
    end
end

% now just make sure the axes are equal
axis equal

end

