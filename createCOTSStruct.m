function COTSStruct = createCOTSStruct(COTSTable, seeds, uniqueSeeds)
% createCOTSStruct will create a structure with each row being a separate
% COTS - this will make tracking positions far far easier

% input:
% COTSTable - a table where each row corresponds to the current position,
% and time of a specific COTS seed
% must have the following columns: "seed", "initialX", "initialY",
% "releaseTime_seconds", "reefIndex", "time_days", "xPos", "yPos"
% seeds - converts the seed of a COTS into it's index, as seeds are not
% consecutive from 0 up - i.e. first COTS seed is 10, so seeds(10) = 1
% uniqueSeeds - holds all the unique seeds in order, i.e. uniqueSeeds(1) =
% 10

% output:
% COTSStruct - a structure where each row/element corresponds to the total
% path of a COTS over time, i.e. records it's X and Y positions and the
% times at which each were observed

% determine the total number of seeds
nCOTS = length(uniqueSeeds);

% determine the number of rows in the COTSTable
nRows = height(COTSTable);

% initialise the output
COTSStruct = struct('seed', cell(nCOTS, 1), 'releaseTime_seconds', [], 'initialX', [], 'initialY', [], 'time_days', [], 'time_days_floored', [], 'X', [], 'Y', [], 'index', []);

% loop through each entry in the COTSTable
for r = 1:nRows
    
    % determine the index of the current seed
    ind = seeds(COTSTable{r, "seed"});
    
    % store the relevant information if it has not already been stored
    if isempty(COTSStruct(ind).seed)
        COTSStruct(ind).seed = COTSTable{r, "seed"};
        COTSStruct(ind).releaseTime_seconds = COTSTable{r, "releaseTime_seconds"};
        COTSStruct(ind).initialX = COTSTable{r, "initialX"};
        COTSStruct(ind).initialY = COTSTable{r, "initialY"};
    end

    % store the current time, x and y coords and index value
    COTSStruct(ind).time_days = [COTSStruct(ind).time_days, COTSTable{r, "time_days"}];
    COTSStruct(ind).X = [COTSStruct(ind).X, COTSTable{r, "xPos"}];
    COTSStruct(ind).Y = [COTSStruct(ind).Y, COTSTable{r, "yPos"}];
    COTSStruct(ind).index = [COTSStruct(ind).index, COTSTable{r, "reefIndex"}];
    
end

% we now want to go through and also sort the X, Y and time arrays for each
% COTS so that they are in chronological order
for c = 1:nCOTS
    
    % determine the indexing required to sort the times of the current COTS
    [~, I] = sort(COTSStruct(c).time_days, "ascend");
    
    % now sort everyhting and save it
    COTSStruct(c).time_days = COTSStruct(c).time_days(I);
    COTSStruct(c).X = COTSStruct(c).X(I);
    COTSStruct(c).Y = COTSStruct(c).Y(I);
    
end

% now also add a field of the time in days for each point but floored, with
% the initial release time converted and added
for c = 1:nCOTS
    COTSStruct(c).time_days_floored = floor(COTSStruct(c).time_days + (COTSStruct(c).releaseTime_seconds / (60*60*24)) - 17867);
end

end