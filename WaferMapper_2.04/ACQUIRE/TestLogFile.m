

[IsSuccess] = LogFile_Create('Z:\Hayworth\TestLog');


for i = 1:100
    LineToWrite = sprintf('i = %d', i);
    IsPrefixWithTime = true;
    [IsSuccess] = LogFile_WriteLine(LineToWrite, IsPrefixWithTime);
    
    pause(1);
end

[IsSuccess] = LogFile_Close();
    