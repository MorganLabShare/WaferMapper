

bookDir = 'Z:\joshm\LGNs1\rawMontages\LogBooks\';
bookName = 'LogBook_w052';
gDrive = 'C:\Users\View192\Google Drive\logBooks\'



while 1

logSec2Excel(bookDir, bookName);

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
pause(60)
end
