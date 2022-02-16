function connectivityMat = createConnectivityMat(initialReefs, finalReefs, GBRShape)
% createConnectivityMat will create a connectivity matrix for the COTS
% larvae on the Great Barrier Reef

% inputs:
% initialReefs - a vector of the initial reefs at which each COTS larvae
% begins
% finalReefs - a vector of the final reefs at which each COTS larvae
% reaches, with 0's for those larvae which died

% outputs:
% connectivityMat - a connectivity matrix for COTS on the GBR

% determine the number of reefs
nReefs = length(GBRShape);

% initialise the connectivity matrix
connectivityMat = zeros(nReefs);

% determine the number of COTS larvae
nCOTS = length(initialReefs);

% loop over each COTS larvae
for c = 1:nCOTS
    
    % the initial reef will determine the row we are in and the final reef
    % will determine the column - for now we will just add values in for
    % counts, and will later scale by initial reefs
    if initialReefs(c) > 0 && finalReefs(c) > 0
        connectivityMat(initialReefs(c), finalReefs(c)) = connectivityMat(initialReefs(c), finalReefs(c)) + 1;
    end
    
end

% now scale each row by the number of COTS larvae initially released
for r = 1:nReefs
    
    % determine the number of COTS released from  that reef
    reefCOTS = sum(initialReefs == r);
    
    % scale row
    if reefCOTS > 0
        connectivityMat(r, :) = connectivityMat(r, :) / reefCOTS;
    end
    
end

end