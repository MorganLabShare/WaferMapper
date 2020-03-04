
TPN = GetMyDir;
TPNstitched = [TPN 'stageStitched\'];
if ~exist(TPNstitched,'file')
    mkdir(TPNstitched)
end

dTPN = dir(TPN); dTPN = dTPN(3:end);

for i = 1:length(dTPN)
    if dTPN(i).isdir
        
        nam = dTPN(i).name
        und = regexp(nam,'_');
        if length(und) == 2
            waf = nam(1:und(1)-1);
            sec = nam(und(1)+4:und(2)-1);
            if ~isempty(waf) & ~isempty(sec)
                stitchedName = ['StageStitched_' waf '_sec' sec '_WithQualVals.tif'];
                imageFound = 1;
                if ~exist([TPN nam '\' stitchedName],'file')
                    stitchedName = ['StageStitched_' waf '_sec' sec '.tif'];
                    if ~exist([TPN nam '\' stitchedName],'file')
                        imageFound = 0;
                    end %if stitched
                end %if stitched with quality
                
                if imageFound
                    fileName = [TPN nam '\' stitchedName];
                    newFileName = [TPNstitched  stitchedName];
                    [Success,Message,MessageID] = copyfile(fileName, newFileName);
                    if Success
                        ['Copied ' stitchedName]
                    else
                        ['Failed to copy ' stitchedName]
                    end
                end %if image found
                
                
            end %if waf, sec names
            
        end %if 2 underscores
    end % if is directory
end %end run directories

