function [IsSuccess] = LogFile_WriteLine(LineToWrite, IsPrefixWithTime)

global GuiGlobalsStruct;
IsSuccess = false;

if ~exist('IsPrefixWithTime','var')
   IsPrefixWithTime = true;
end



if GuiGlobalsStruct.LogFile_fid > 2 %if exists and is not stdout etc.
    if IsPrefixWithTime
        WriteString = sprintf('%s: %s', datestr(now), LineToWrite);
    else
        WriteString = sprintf('%s', LineToWrite);
    end    
    count = fprintf(GuiGlobalsStruct.LogFile_fid, '\n%s', WriteString);
    
    if (count > 0)
        IsSuccess = true;
    end
else
    disp(sprintf('Problem writing to log file'));
end

