function [IsSuccess] = LogFile_Close()

global GuiGlobalsStruct;
IsSuccess = false;

if GuiGlobalsStruct.LogFile_fid > 2 %if exists and is not stdout etc.
    FinalString = sprintf('\nClosed: %s', datestr(now));
    fprintf(GuiGlobalsStruct.LogFile_fid, '%s', FinalString);
    
    status = fclose(GuiGlobalsStruct.LogFile_fid);
    if (status ~= 0)
        disp(sprintf('Problem closing log file'));
        return;
    else
        GuiGlobalsStruct.LogFileNameStr = '';
        IsSuccess = true;
    end
    
else
    disp(sprintf('Problem closing log file'));
    return;
end


