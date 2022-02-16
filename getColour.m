function colour = getColour(val, maxVal, cMap)
% getColour will produce an RGB triplet based on a colourmap specified in
% cMap, which is proportional to some current value and the max value

% inputs:
% val - current value for which colour will be representative of (integer)
% maxVal - the maximum possible value
% cMap - the type of colourmap used, e.g. "jet"

% outputs:
% colour - an rgb triplet, i.e. 1 x 3 vector between 1 and 0

% initialise the colourmap
switch cMap
    case "jet"
        cMap = jet(maxVal);
end

% return the correct colour
colour = cMap(val, :);

end