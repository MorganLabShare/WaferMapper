function[] = moveSectionsThroughBuffer()

%% Set directories
SPN = 'V:\LGNS1_Montages\'; % scope write drive
WPN = 'E:\MerlinDataBuffer\'; % local intermediate buffer drive
TPN = 'Z:\joshm\LGNs1\rawMontages\'; % server


%% Timing variables


delayBetweenChecksForFinishedSectionsInMinutes = 15; 
delaySecCheckDays = delayBetweenChecksForFinishedSectionsInMinutes/60/24;
startFoldName = length(WPN) + 1;

%% Read source folder
currentCheckTime =  datenum(clock);%record time at first read

while 1
    pause(1)
    
    %% copy SSD to Buffer
    %'Copying all files from SSD to Buffer'
    %shortPush(SPN,WPN)
    
    %% move finished sections off of SSD
    'Checking for finished sections'
    dSPN = dir(SPN); dSPN = dSPN(3:end);
    findFolders = find([dSPN.isdir]);
    folders = dSPN(findFolders);
    for i = 1:length(folders);
        pause(.01)
        nam = folders(i).name;
        findMon = regexp(nam,'Montage');
        if ~isempty(findMon)
            if exist([SPN nam '\finished.mat'])
                ['Section ' nam ' is ready for copying']
                tic
                
                %% Check for success
                copyFail = 0;
                for r = 1 %possible repeat copying
                    matched = 1;
                    if ~exist([TPN nam])
                        mkdir([TPN nam])
                    end
                    dirSource = dir([SPN nam]); dirSource = dirSource(3:end);
                    dirTarget = dir([TPN nam]); dirTarget = dirTarget(3:end);
                    tNams= {dirTarget.name};
                    sNams = {dirSource.name};
                    
                    for d = 1:length(dirSource)
                        SinT = find(strcmp(tNams,sNams{d}));
                        
                        if isempty(SinT)
                            doCopy = 1; 'create new'
                        elseif dirSource(d).datenum > dirTarget(SinT).datenum
                            doCopy = 1; 'update'
                        elseif dirSource(d).bytes ~= dirTarget(SinT).bytes
                            doCopy = 1; 'replace incomplete'
                        else
                            doCopy = 0;
                        end
                        if doCopy
                            
                            for s = 1:3
                             ['Copying file ' SPN nam '\' sNams{d}]   
                                [success message ID] = copyfile([SPN nam '\' sNams{d}],[TPN nam '\' tNams{SinT}]);
                                if success
                                    break
                                end %if copied leave
                            end %try copying three times
                            if s == 3
                                copyFail = 1;
                                'Failed to copy'
                            end %record a failure to copy
                        end %do coppy
                    end %run all files in directory (d)
                    
                end %Check directory multiple times
                
                %% Delete source folder
                dirSource = dir([SPN nam]); dirSource = dirSource(3:end);
                dirTarget = dir([WPN nam]); dirTarget = dirTarget(3:end);
                tNams= {dirTarget.name};
                sNams = {dirSource.name};
                doDelete = 1;
                sprintf('Preparing to delete %s',[SPN nam])

                for d = 1:length(dirSource)
                    SinT = find(strcmp(tNams,sNams{d}));
                    %%check if it is ok to delete
                    if isempty(SinT)
                        doDelete = 0; 'missing file'
                    elseif dirSource(d).datenum > dirTarget(SinT).datenum
                        doDelete = 0; 'out of date'
                    elseif dirSource(d).bytes ~= dirTarget(SinT).bytes
                        doDelete = 0; 'incomplete target'
                    end
                end %Check all files in directory for completeness
                ['Deleting ' [SPN nam] '.']
                if doDelete
                    [success message messageID] = rmdir([SPN nam],'s');  %Delete section from source directory
                end
                toc
            end %if finished
        end %if montage directory
    end % end check of image directory for finished sections
    
    
    
    %% Move files from data buffer to server %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'Moving files from Buffer to Server'
   
    shortPush(WPN,TPN,delaySecCheckDays)
    
        
        
end %keep checking