%function[] = moveSectionsThroughBuffer()

%% Set directories
SPN = 'V:\LGNS1_Montages\'; % scope write drive
WPN = 'E:\NewMerlinDataBuffer\'; % local intermediate buffer drive
TPN = 'Z:\joshm\LGNs1\rawMontages\'; % server
GPN = 'C:\Users\View192\Google Drive\'; %google drive

%%  Select actions
ClearScope = 1;  %Copy then delete finished sections
CopyScope = 1;  %Copy all data from scope to buffer
CopyBuffer = 1; %Copy data from buffer to server
CopyLog = 1; %Copy data log to server and gdrive

%% Timing variables
delayBetweenChecksForFinishedSectionsInMinutes = 5;
delaySecCheckDays = delayBetweenChecksForFinishedSectionsInMinutes/60/24;
startFoldName = length(WPN) + 1;
currentCheckTime =  datenum(clock);%record time at first read
checkSecNumber = 500; %Number of sections to check before moving onto the next step

%%
while 1
    pause(1)
    
    if CopyLog
        copyLogBook(SPN,{WPN TPN GPN})
    end
    
    %% Find finished Folders on SSD
    if ClearScope
        'Checking for finished sections'
        dSPN = dir(SPN); dSPN = dSPN(3:end);
        folders2find = find([dSPN.isdir]);
        folders = dSPN(folders2find);
        finishedFolders = {};
        for i = 1:length(folders);
            pause(.01)
            nam = folders(i).name;
            findMon = regexp(nam,'Montage');
            if ~isempty(findMon)
                if exist([SPN nam '\finished.mat'])
                    disp(['Section ' nam ' is ready for moving'])
                    finishedFolders{length(finishedFolders)+1} = nam;
                end
            end
        end
        
        
        %% Check finish folders
        if ~isempty(finishedFolders)
            for s = 1: min(length(finishedFolders),checkSecNumber)
                nam = finishedFolders{end - s + 1}
                %%Make folder
                if ~exist([WPN nam],'dir')
                    mkdir([WPN nam])
                end
                tic
                %%Copy Folder
                allGood = shortPush([SPN nam '\'],[WPN nam '\']);
                disp('section copy finished')
                toc
                %%Double Check Folder
                allGood = compFolders([SPN nam '\'],[WPN nam '\']);
                
                
                %% Delete source folder
                if allGood
                    
                    %%Make MD5
                    tic
                    disp(' ')
                    disp('Making MD5 for new folder')
                    md5List = checkSumFolder([WPN nam '\']);
                    safesave([WPN nam '\md5s.mat'],'md5List')
                    toc
                    
                    %%Delete folder
                    disp(['Deleting ' [SPN nam] '.'])
                    [success message messageID] = rmdir([SPN nam],'s');  %Delete section from source directory
                    if success
                        disp('success')
                    else
                        disp('failed to remove directory')
                    end
                    
                    
                else
                    disp(['Not deleting ' [SPN nam] ' due to copy failure.'])
                end
                if CopyLog
                    copyLogBook(SPN,{WPN TPN GPN})
                end
            end % run some sections
        end %if finished
    end
    
    
    %% Move files from scope to data buffer
    if CopyScope
        disp(' ')
        disp('Moving files from scope to Buffer')
        shortPush(SPN,WPN,delaySecCheckDays)
    end
    
    if CopyLog
        copyLogBook(SPN,{WPN TPN GPN})
    end
    
    %% Move files from data buffer to server %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if CopyBuffer
        disp(' ')
        disp('Moving files from Buffer to Server')
        shortPush(WPN,TPN,delaySecCheckDays)
    end
    
    
end %keep checking