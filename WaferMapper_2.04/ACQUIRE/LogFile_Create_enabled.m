function [IsSuccess] = LogFile_Create(DirectoryForLogFile)
%This function will always create a unique log file name in the directory
%given and will save this path and name in the global GuiGlobalsStruct
global GuiGlobalsStruct;

IsSuccess = false;
UID_DateStr = datestr(now,30);

GuiGlobalsStruct.LogFileNameStr = sprintf('%s\\LogFile_%s.txt',DirectoryForLogFile, UID_DateStr);
disp(sprintf('Creating log file: %s', GuiGlobalsStruct.LogFileNameStr));

[GuiGlobalsStruct.LogFile_fid, message] = fopen(GuiGlobalsStruct.LogFileNameStr, 'wt');
if GuiGlobalsStruct.LogFile_fid > 0 %if successful
    HeaderString = sprintf('Created: %s', datestr(now));
    fprintf(GuiGlobalsStruct.LogFile_fid, '%s', HeaderString);
    IsSuccess = true;
else
    disp(sprintf('  Failed to create log file: %s', GuiGlobalsStruct.LogFileNameStr));
    disp(sprintf('  message =  %s', message));
    return;
end

%fclose(GuiGlobalsStruct.LogFile_fid);

end

