function[allGood] = compFolders(SPN,TPN)

allGood = 1;

dirSource = dir(SPN); dirSource = dirSource(3:end);
        dirTarget = dir(TPN); dirTarget = dirTarget(3:end);
        tNams= {dirTarget.name};
        sNams = {dirSource.name};
        allGood = 1;
        
        for d = 1:length(dirSource)
            SinT = find(strcmp(tNams,sNams{d}));
            %%check if it is ok to delete
            if isempty(SinT)
                allGood = 0; 'missing file'
            elseif dirSource(d).datenum > dirTarget(SinT).datenum
                allGood = 0; 'out of date'
            elseif dirSource(d).bytes ~= dirTarget(SinT).bytes
                allGood = 0; 'incomplete target'
            end
        end %Check all files in directory for completeness