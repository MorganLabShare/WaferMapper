function[] = checkWaferQuality(SPN,TPN,waferName)

%% Get data directory


%% Get data directory
TPNstitched = [TPN 'stageStitched\'];
if ~exist(TPNstitched,'file')
    mkdir(TPNstitched)
end



tic

%% Find wafer folders and check for stitched image
dSPN = dir(SPN); dSPN = dSPN(3:end);
c =0;
for i = 1:length(dSPN)
    if dSPN(i).isdir
        nam = dSPN(i).name;
        und = regexp(nam,'_');
        
        if length(und) == 2
            waf = nam(1:und(1)-1);
            sec = nam(und(1)+4:und(2)-1);
            if strcmp(waf,waferName)
                if ~isempty(waf) & ~isempty(sec)
                    c = c+1;
                    f(c).folderNames = nam;
                    f(c).wafInfo = waf;
                    f(c).secInfo = str2num(sec);
                    f(c).dateInfo{c} = dSPN(i).date;
                    f(c).dateNumInfo = dSPN(i).datenum;
                    
                    %Check for stitched image
                    f(c).stitchedName = 'none';
                    stitchedName = ['StageStitched_' waf '_sec' sec '_WithQualVals.tif'];
                    if ~exist([SPN nam '\' stitchedName],'file')
                        stitchedName = ['StageStitched_' waf '_sec' sec '.tif'];
                    end
                    if exist([SPN nam '\' stitchedName],'file')
                        f(c).stitchedName =  stitchedName;
                    else
                        f(c).stitchedName = stitchedName;
                    end
                    
                    
                end %if waf, sec names
            end
        end %if 2 underscores
    end % if is directory
end %end run directories


%%  Sort wafers and sections
[wafers m n] = unique({f.wafInfo});
for w = 1:length(wafers)
    winfo(w).f=f(n==w);
end

%% write files
for w = 1:length(wafers)
    maxSec = max([winfo(w).f.secInfo]);
    missingSec = [];
    findSize = 1;
    stitchedWafDir = [TPNstitched  winfo(w).f(1).wafInfo '\' ]
    if ~exist(stitchedWafDir)
        mkdir(stitchedWafDir)
    end
    
    for s = 1:maxSec
        targ = find([winfo(w).f.secInfo]==s);
        missing = 1;
        if ~isempty(targ)
            stitchedName = winfo(w).f(targ).stitchedName;
            
            fileName = [SPN  winfo(w).f(targ).folderNames '\'  stitchedName];
            newFileName = [stitchedWafDir 'StageStitched_' winfo(w).f(targ).wafInfo '_sec' zeroBuf(winfo(w).f(targ).secInfo) '.tif'];
            if exist(fileName,'file')
                missing = 0; %file isnt missing
                
                if findSize
                    ssinfo = imfinfo(fileName);
                    ssWidth = ssinfo.Width;
                    ssHeight = ssinfo.Height;
                    findSize = 0;
                end
                
                
                if ~exist(newFileName);
                    [Success,Message,MessageID] = copyfile(fileName, newFileName);
                    if Success
                        ['Copied ' stitchedName]
                    else
                        [Success,Message,MessageID] = copyfile(fileName, newFileName);
                    end %if successful coppy
                end % if file already exists
                
            end
        end
        
    if missing %if missing is triggered record section
        
        missingSec = [missingSec s];
    end
        
    end
    
    for ms = 1:length(missingSec)
    s = missingSec(ms);
    newFileName = [stitchedWafDir 'StageStitched_' winfo(w).f(1).wafInfo '_sec' zeroBuf(s) '_NoImageFound.tif'];
    dummyI = zeros(ssHeight,ssWidth,'uint8');
    imwrite(dummyI,newFileName,'Compression','none')
    
end % run missing sec

    
end %run wafers

% run missing

%
% for i = 1:length(folderNames)
%    [I sStats] = quickStitch([SPN folderNames{i} '\']);
%
%
% end
%
%
%
% if imageFound
%     fileName = [SPN nam '\' stitchedName];
%     newFileName = [TPNstitched  stitchedName];
%     [Success,Message,MessageID] = copyfile(fileName, newFileName);
%     if Success
%         ['Copied ' stitchedName]
%     else
%         ['Failed to copy ' stitchedName]
%     end
% end %if image
%
%
%
%
%
toc