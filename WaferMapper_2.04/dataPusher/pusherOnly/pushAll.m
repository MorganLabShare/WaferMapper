%function[] = pushAll(WPN,TPN,maxCheckTime)
%%Make sure all files in WPN are present and updated in TPN.
%%If lastCheckTime exists, only move files created after last check times

delayCopySeconds = 120;  %Seconds between reading directories and starting file copy
delayCopyDays = delayCopySeconds/60/60/24;

secondsBetweenFullCheck = 120;
daysBetweenFullCheck = secondsBetweenFullCheck/60/60/24;
lastFullCheck = datenum(clock);

%% get folder
if ~exist(TPN,'dir') | ~exist(WPN,'dir')
    error('missing directory')
end

startFoldName = length(WPN) + 1;

%% Read source folder
startCheckTime =  datenum(clock);%record time at first read



    %Update after first run through
    currentCheckTime =  datenum(clock);
    noNew = 1;
    %% Read source folder
    'Checking for new folders and files'
    APN = findFolders(WPN); % find all folders in source directory
    allNams =  {}; allTimes = []; allFolders = {}; allSizes = [];  %initialize empty lists
    
    for f = 1: length(APN)  %run through every found folder
        
        dAPN = dir(APN{f}); dAPN = dAPN(3:end);
        noDir = ~[dAPN.isdir];
        aFiles = dAPN(noDir);
        
        allNams = [allNams; {aFiles.name}'];
        allTimes = [allTimes; [aFiles.datenum]'];
        allSizes = [allSizes; [aFiles.bytes]'];
        fID = ones(length(aFiles),1) * f;
        allFolders = cat(1,allFolders,APN(fID));
    end
    
    %% Make directories
    for i = 1:length(APN)
        source = APN{i};
        dest = [TPN source(startFoldName:end)];
        if ~exist( dest,'dir')
            mkdir(dest);
        end
        noNew = 1;
    end
    
 if exist('lastCheckTime','var')   
     
    %% Copy new files
    copyNew = find(allTimes>lastCheckTime);
    sprintf('Found %d files created since last check.',length(copyNew))
    for i = 1:length(copyNew)
        sprintf('Copying %d of %d new files.',i,length(copyNew))
        source = [allFolders{copyNew(i)} '\' allNams{copyNew(i)}];
        dest = [TPN source(startFoldName:end)];
        if ~exist(dest,'file')
            if (allTimes(copyNew(i)) + delayCopyDays)>datenum(clock)
                pause((allTimes(copyNew(i)) + delayCopyDays-datenum(clock))/24/60/60);
            end
                status = 0;
            while status == 0  %make sure copy succeded
                status = copyfile(source,dest);
            end
        end
    end
    
else
    %% Run full check
    
        tic
        'Running full check for directory match'
        
        for i = 1:length(allNams)
            source = [allFolders{i} '\' allNams{i}];
            dest = [TPN source(startFoldName:end)];
            shouldCopy = 0;
            if ~exist(dest,'file')
                shouldCopy = 1;
            else  %if file exists
                fileInfo = dir(dest);
                fileInfo = fileInfo(end);
                if fileInfo.datenum<allTimes(i) %replace old file
                    shouldCopy = 1;
                    sprintf('replaced old file %s', allNams{i})
                elseif (fileInfo.datenum == allTimes(i) ) & ...
                        (fileInfo.bytes < allSizes(i)); %replace partial file
                	sprintf('replaced partial file %s', allNams{i})
                end % if overwrite
                
            end %whether dest file exists
            
            if shouldCopy %copy if you should
                status = 0;
                noNew = 0;
                while status == 0  %make sure copy succeded
                    status = copyfile(source,dest);  %copy the file
                end %i status is bad
            end
        end       %run all file names
        'Full recheck finished'
        toc
        if noNew
            sprintf('No new files found after full check at %s', datestr(clock))
        else
            sprintf('New files found after full check at %s', datestr(clock))
        end
end





