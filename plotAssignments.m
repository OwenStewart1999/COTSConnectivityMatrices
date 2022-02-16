function plotAssignments(GBRShape, points, reefAssignments)
% plotAssignments will plot each reef, and the points assigned to it, the
% same colour to visualise the initial position assignments and assure they
% are accurate

% inputs:
% GBRShape - a strucuture holding the fields X, Y and optionally Centroid
% initialPos - the points which are being assigned, could be initial
% positions or settlement positions
% reefAssignments - a vector holding the reef indices to which each COTS
% larvae have been assigned to, or 0's if they have not been assigned

% determine the number of reefs
nReefs = length(GBRShape);

% create a figure and turn hold on
figure
hold on

% loop over each reef
for r = 1:nReefs

    % pick a random colour for this reef
    colour = rand([1, 3]);

    % plot the reef outline
    plot(GBRShape(r).X, GBRShape(r).Y, "Color", colour);

    % find all the points assigned to this reef
    indices = find(reefAssignments == r);

    % plot all the indices in the same colour
    plot(points(indices, 1), points(indices, 2), '.', "Color", colour);

end

% set axis equal
axis equal

end