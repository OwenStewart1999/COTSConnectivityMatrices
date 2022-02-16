function GBRShapeEnlarged = enlargeShapes(GBRShape, enlargementDist)
% enlargeShapes will enlarge the shapes held in GBRShape by an amount
% specified in enlargementDist

% inputs: 
% GBRShape - holds the reef outlines in a structure with fields X and Y
% storing the X and Y coordinates
% enlargementDist - the distance to enlarge each reef by (in m)

% output: 
% GBRShapeEnlarged - the original shape structure with each element now
% enlarged

% determine the number of reefs
nReefs = length(GBRShape);

% initailise the results
GBRShapeEnlarged = GBRShape;

% turn warnings off
warning('off')

% loop over each reef
for r = 1:nReefs
    
    % grab the coordinates of the current reef
    X = GBRShape(r).X;
    Y = GBRShape(r).Y;
    
    % as we are enlarging reefs, assume that holes are no longer necessary,
    % hence remove the holes
    [X, Y] = outsideBorder(X, Y);
    
    % the process which will be used is to create a circle of radius
    % enlargementDist around each point, convex hull consecutive points and
    % then polyshape union each convex hull
    
    % determine the number of points in the current reef's outline
    nPoints = length(X);
    
    % create a vector of polyshapes as this will hopefully speed up the
    % union stuff
    
    % use the first two points to create the initial convex hull
    [xcurr, ycurr] = createCircle(X(1), Y(1), enlargementDist, 15);
    [xnext, ynext] = createCircle(X(2), Y(2), enlargementDist, 15);
    x = [xcurr, xnext];
    y = [ycurr, ynext];
    c = convhull(x, y);
    
    % create the initial polyshape from this first convex hull
    if r > 1
        clear polyShapeVec;
    end
    
    polyShapeVec(1) = polyshape(x(c), y(c));
    polyShapeVec(nPoints) = polyshape();
    
    % now loop through the middle points
    for p = 2:(nPoints - 1)
        
        % create the convex hull
        xcurr = xnext;
        ycurr = ynext;
        [xnext, ynext] = createCircle(X(p+1), Y(p+1), enlargementDist, 35);
        x = [xcurr, xnext];
        y = [ycurr, ynext];
        c = convhull(x, y);
        
        % update the polyshape vec
        polyShapeVec(p) = polyshape(x(c), y(c));
        
    end
    
    % now do the wraparound for the final point back to the start
    xcurr = xnext;
    ycurr = ynext;
    [xnext, ynext] = createCircle(X(1), Y(1), enlargementDist, 35);
    x = [xcurr, xnext];
    y = [ycurr, ynext];
    c = convhull(x, y);
    
    % update the polyshape vec
    polyShapeVec(nPoints) = polyshape(x(c), y(c));
    
    % find the union of all stored polyshapes
    pShapeUnion = union(polyShapeVec);

    % remove the holes of the enlarged polygon
    pShapeUnion = rmholes(pShapeUnion);
    
    % now that the polyshape union is complete, return the x and y values
    % for its boundary and store them
    [x, y] = boundary(pShapeUnion);
    GBRShapeEnlarged(r).X = x';
    GBRShapeEnlarged(r).Y = y';
   
    % consider above skipping every second point if the enlarged shapes
    % have too many points - considering they're meant to be a rough
    % enlargement anyway, the gain to speedup may be advantageous

end

% turn warnings back on
warning('on')

end