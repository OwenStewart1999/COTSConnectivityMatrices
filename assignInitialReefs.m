function initialReefs = assignInitialReefs(COTSStruct, GBRShape, searchCell, partArr)
% assign initial reefs will take the initial positions of the larvae stored
% in COTSStruct and determine the reefs they originated from

% inputs:
% COTSStruct - a structure where each row/element corresponds to the total
% path of a COTS over time, i.e. records it's X and Y positions and the
% times at which each were observed - must have the fields initialX and
% initialY
% GBRShape - a struct containing the outlines of each reef, whose
% coordinates are in the fields X and Y
% searchCell - a cell array used to improve searching speed, can be created
% using the createSearchCell() function
% partArr - an array of partitions of size n x 2 x 5 where n is the number
% of partitions / cells, and (n, 1, :) are the x values ((n, 2, :) for y)

% output:
% intialReefs - an array containing the initial reefs for which each COTS
% was released from

% determine the number of COTS larvae
nCOTS = length(COTSStruct);

% initialise the output
initialReefs = zeros(nCOTS, 1);

% loop over each larvae, and determine the reef they are either situated
% in, or closest to
for c = 1:nCOTS

    % apply the already written searching algorithm
    initialReefs(c) = findReefFast([COTSStruct(c).initialX, COTSStruct(c).initialY], GBRShape, searchCell, [], [], "nearest", partArr);

end

end