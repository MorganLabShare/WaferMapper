



SPN = 'S:\LGNS1_Montages\';
TPN = 'X:\joshm\LGNs1\rawMontages\';

if (sum(TPN)==0) | (sum(SPN) == 0)
    return
end

while 1
    'Checking for finished sections'
    dSPN = dir(SPN); dSPN = dSPN(3:end);
    findFolders = find([dSPN.isdir]);
    folders = dSPN(findFolders);
    for i = 1:length(folders);
        nam = folders(i).name;
        findMon = regexp(nam,'Montage');
        if ~isempty(findMon)
            if exist([SPN nam '\finished.mat'])
                ['Section ' nam ' is ready for copying']
                tic
                
                %% Copy folder one file at a time
                
                %[success message ID] = copyfile([SPN nam],[TPN nam]);
                
                
                
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
                            doCopy = 1;
                        elseif dirSource(d).datenum > dirTarget(SinT).datenum
                            doCopy = 1;
                        elseif dirSource(d).bytes ~= dirTarget(SinT).bytes
                            doCopy = 1;
                        else
                            doCopy = 0;
                        end
                        
                        
                        if doCopy
                            ['Copying file ' SPN nam '\' sNams{d}]
                            for s = 1:3
                                [success message ID] = copyfile([SPN nam '\' sNams{d}],[TPN nam '\' tNams{SinT}]);
                                if success
                                    break
                                end %if copied leave
                            end %try copying three times
                            if s == 3
                                copyFail = 1;
                            end %record a failure to copy
                        end %try copying three times
                    end %run all files in directory (d)
                    
                end %Check directory multiple times
                
                %% Delete source folder
                dirSource = dir([SPN nam]); dirSource = dirSource(3:end);
                dirTarget = dir([TPN nam]); dirTarget = dirTarget(3:end);
                tNams= {dirTarget.name};
                sNams = {dirSource.name};
                doDelete = 1;
                for d = 1:length(dirSource)
                    SinT = find(strcmp(tNams,sNams{d}));
                    
                    %%check if it is ok to delete
                    if isempty(SinT)
                        doDelete = 0;
                    elseif dirSource(d).datenum > dirTarget(SinT).datenum
                        doDelete = 0;
                    elseif dirSource(d).bytes ~= dirTarget(SinT).bytes
                        doDelete = 0;
                    end
                    doDelete
                end %Check all files in directory for completeness
                ['Deleting ' [SPN nam] '.']
                if doDelete
                    [success message messageID] = rmdir([SPN nam],'s');  %Delete section from source directory
                end
                toc
            end %if finished
        end %if montage directory
        
        
        
        
    end %run all folders
    pause(30)
end