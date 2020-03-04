

waferName = 'w042'

SPN = 'E:\NewMerlinDataBuffer\'
TPN = 'E:\Processed\'
bookDir = [SPN 'LogBooks\'];
gDrive = 'C:\Users\View192\Google Drive\logBooks\'

bookName = ['LogBook_' waferName];
%%
while 1

%% Summarize logBook and write to excel    
logSec2Excel(bookDir, bookName);

%% Copy logBook to google drive
success = 0;
while ~success
    [success message] = copyfile([bookDir bookName '.mat'],[gDrive bookName '.mat'])
    pause(.1)
end
pause(3)

success = 0;
while ~success
    [success message] = copyfile([bookDir bookName '.xls'],[gDrive bookName '.xls'])
    pause(.1)
end

%% collect quality images
checkWaferQuality(SPN,TPN,waferName)
checkWaferStitching(SPN,TPN,waferName)


pause(5)
end
