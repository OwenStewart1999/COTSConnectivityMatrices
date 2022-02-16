function [finalReefs, status, overReefCount] = assignFinalReefs(COTS, GBRShape, GBRShapeEnlarged, searchCellEnlarged, settlementProb, deathProb)
% assignFinalReefs will take the COTS larvae in COTSStruct and assign them
% to a final reef in which they settle in, or determine if they instead die
% out
% the results of the final reefs each larvae end up on will be stored in
% finalReefs as the index of the reef they end up on, or a 0 if it dies our

% inputs:
% COTS - a matlab structure containing information on each COTS larvae,
% each element being a different individual larvae and holds its seed, the
% time at which each of the positions were recorded
% GBRShape - a structure where each element is a different reef, and the
% fields X and Y contain the border of the reef
% GBRShapeEnlarged - the same set of reefs, however each of the borders
% have been enlarged by 1km
% partArr1 - an array of partitions of size n x 2 x 5 where n is the number
% of partitions / cells, and (n, 1, :) are the x values ((n, 2, :) for y) -
% note - partArr1 should be at a lower resolution than partArr2, as
% partArr1 is searched first
% partArr2 - an array of partitions of size n x 2 x 5 where n is the number
% of partitions / cells, and (n, 1, :) are the x values ((n, 2, :) for y)
% partCell2 - a cell array containing the indices of reefs contained in
% each partition from partArr2
% partToPartCell - a cell array containing the indices of partitions in
% partArr2 which belong to partitions in partArr1 (i.e. will be same length
% as partArr1)
% settlementProb - an array of probabilities for settlement of dimension 2
% x n, where the top row is the probabilities and the bottom is the time in
% days since release
% deathProb - same as settlement, however is instead the probability a COTS
% larvae will die

% outputs: 
% finalReefs - an array the same size as COTSStuct which holds the
% indices of each reef in which the COTS larvae settle, or 0 if they die
% status - an array which assists in tracking the status of each COTS,
% which will be modified at the end to include the seed in the first
% column, a binary variable in the second which will be 1 if the larvae
% settled, and 0 if it died, and finally the 3rd column which records the
% day at which a larvae settled or died - larvae who survived the entire
% time period but did not settle will have a value of one day after
% survivorship/settlement rates end
% overReefCount - a count of the number of COTS larvae which are over a
% reef on a given day - used to help verify settlement rates are being
% applied correctly - will be 2 x n where the top row is the counts of
% settlements, and the bottom row are the days

% turn off warnings
warning("off", "all")

% create the status variable which during the method will be indexed by
% seed, and have its first column be the previous reef for which the COTS
% was over, the second column will be a binary representative of settlement
% and the third will be the time at which the larvae settled or died
status = zeros(COTS(end).seed, 3);

% determine the first and final days necessary for simulation, taking the
% minimum range described by the death and settlement arrays
firstDaySurv = deathProb(1, 1);
firstDaySett = settlementProb(1, 1);
lastDay = min(settlementProb(1, end), deathProb(1, end));

% to further simplify things, we will allow the settlement and death arrays
% to be indexed by day only
settlementProb = horzcat(zeros(1, firstDaySett - 1), settlementProb(2, 1:(lastDay - firstDaySett + 1)));
deathProb = horzcat(zeros(1, firstDaySurv - 1), deathProb(2, 1:(lastDay - firstDaySurv + 1)));

% intialise the overReefs variable
overReefCount = [];

% if we have survival data before settlement data, begin to apply the death
% processes by looping over the days until the first day of settlement data
% occurs
if firstDaySurv < firstDaySett
    
    for d = firstDaySurv:(firstDaySett - 1)

        % now check the number of remaining COTS, and apply the death
        % process
        nCOTS = length(COTS);
        dead = binornd(1, deathProb(d) * ones(nCOTS, 1));
        dead = find(dead);
        if ~isempty(dead)

            % determine the seeds of the dead COTS
            deadSeeds = zeros(length(dead), 1);
            for s = 1:length(dead)
                deadSeeds(s) = COTS(dead(s)).seed;
            end

            % remove the dead COTS and update their status entries
            status(deadSeeds, 1) = 0;
            status(deadSeeds, 3) = d;
            COTS(dead) = [];

        end

    end
end

% now loop over the days for which we have both settlement and death data
for d = firstDaySett:lastDay

    % initialise a variable which will keep track of the COTS seeds which
    % are over a reef on this day
    overReef = [];

    % loop over the remaining larvae
    for l = 1:length(COTS)

        % for the current COTS, check if it has any positions on this day
        if ismember(d, COTS(l).time_days_floored)

            % initialise the reefInd variable which will hold the index of
            % a reef if the current larvae is above one
            reefInd = 0;

            % then loop over the positions on this day - may need and if
            % below
            indChecks = find(COTS(l).time_days_floored == d);
            for p = 1:length(indChecks)

                % grab the current position
                posX = COTS(l).X(indChecks(p));
                posY = COTS(l).Y(indChecks(p));

                % check if the current larvae has recently been over a reef
                if status(COTS(l).seed, 1) > 0

                    % if it is still over the previous reef update reefInd,
                    % otherwise reset the value in status
                    if inpolygon(posX, posY, GBRShapeEnlarged(status(COTS(l).seed, 1)).X, GBRShapeEnlarged(status(COTS(l).seed, 1)).Y)
                        reefInd = status(COTS(l).seed, 1);
                    else
                        status(COTS(l).seed, 1) = 0;
                    end

                end

                % if the larvae is not above its previous reef, or does not
                % have a previous reef, search all reefs
                if reefInd == 0
                    reefInd = findReefFast([posX, posY], GBRShapeEnlarged, searchCellEnlarged, "overlap", GBRShape);
                    status(COTS(l).seed, 1) = reefInd;
                end

                % if larvae is over a reef, add it to the overReef variable
                % and break the current for loop
                if reefInd > 0
                    overReef = [overReef; l];
                    break
                end
            end
        end
    end

    % now that we have looped over all the COTS, we want to run a good
    % ol' Bernoulli trial for settlement of all the COTS which are over
    % a reef
    if ~isempty(overReef)

        % run the Bernoulli trial
        settled = binornd(1, settlementProb(d) * ones(length(overReef), 1));
        settled = find(settled);
        settledIndices = overReef(settled);

        % set all the settled COTS larvae's status section to settled
        % and remove them from the COTS structure
        settledSeeds = zeros(length(settledIndices), 1);
        for s = 1:length(settled)
            settledSeeds(s) = COTS(settledIndices(s)).seed;
        end
        status(settledSeeds, 2) = 1;
        status(settledSeeds, 3) = d;
        COTS(settledIndices) = [];

    end

    % update the overReefCount variable
    if ~isempty(overReef)
        overReefCount = horzcat(overReefCount, [length(overReef); d]);
    else
        overReefCount = horzcat(overReefCount, [0; d]);
    end


    % now check the number of remaining COTS, and apply the death
    % process
    nCOTS = length(COTS);
    dead = binornd(1, deathProb(d) * ones(nCOTS, 1));
    dead = find(dead);
    if ~isempty(dead)

        % determine the seeds of the dead COTS
        deadSeeds = zeros(length(dead), 1);
        for s = 1:length(dead)
            deadSeeds(s) = COTS(dead(s)).seed;
        end

        % remove the dead COTS and update their status entries
        status(deadSeeds, 1) = 0;
        status(deadSeeds, 3) = d;
        COTS(dead) = [];
        
    end
end

% once all days are complete, set any of the remaining alive COTS larvae's
% status to dead
nCOTS = length(COTS);
deadSeeds = zeros(nCOTS, 1);
for c = 1:nCOTS
    deadSeeds(c) = COTS(c).seed;
end
status(deadSeeds, 1) = 0;
status(deadSeeds, 2) = 0;
status(deadSeeds, 3) = lastDay + 1;

% now add the seeds of each of the COTS in the status variable
status = horzcat((1:length(status))', status);

% now get rid of all the rows of status which do not correspond to an
% actual seed
indices = status(:, end) > 0;
status = status(indices, :);

% now update the final reefs variable to store the reefs at which COTS
% settled at, or a 0 if COTS did not settle
finalReefs = status(:, 2);

% now get rid of the column in status with the previous reef as this is now
% unnecessary
status = status(:, [1, 3:end]);

% turn warnings back on
warning("on", "all")

end