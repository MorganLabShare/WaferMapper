
bookDir = 'V:\LGNS1_Montages\logBooks\';
bookName = 'LogBook_w045';
lsDrive = 'Z:\joshm\LGNs1\rawMontages\LogBooks\';
gDrive = 'C:\Users\View192\Google Drive\logBooks\'



while 1
%logSec2Excel(bookDir,bookName)

success = 0;
while ~success
    [success message] = copyfile([bookDir bookName '.mat'],[gDrive bookName '.mat'])
    pause(1)
end


success = 0;
while ~success
    [success message] = copyfile([bookDir bookName '.mat'],[lsDrive bookName '.mat'])
    pause(1)
end


pause(30)

end
