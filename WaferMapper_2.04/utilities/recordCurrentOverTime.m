
if ~exist('sm','var')
sm = startFibics;
end

%%

currentTime = datestr(clock);
currentTime(currentTime==' ') = '_';
currentTime(currentTime==':') = '-';


bookDir = 'V:\recordedCurrents\';
bookName = ['logBookForCurrent_' currentTime];
bookFileName = [bookDir bookName '.xls'];
bookMatName = [bookDir bookName '.mat'];
currentFileName = [bookDir 'recordCurrent-' currentTime '.mat'];

logBook = logOnce;


recordCurrent = [];

GuiGlobalsStruct.MyCZEMAPIClass = sm;

startTime = clock;
%%
while 1
    
    %%Get Current
    sC =  sm.Get_ReturnTypeSingle('AP_SCM')
    recordCurrent(size(recordCurrent,1)+1,1) = sC;
    recordCurrent(size(recordCurrent),2) = datenum(clock);
    safesave(currentFileName,'recordCurrent')
    
    %%Get Everything Else
    logBook = logScopeConditions(logBook);
    logBook = logImageConditions(logBook,bookName);
    safesave(bookMatName,'logBook')
    
    
    pause(60)
end





%%


%% Write XL

sheets = fieldnames(logBook.sheets);
for i = 1:length(sheets)
    sheets{i}
    sheet = getfield(logBook.sheets,sheets{i});
    startRange = 1;
    if isfield(sheet,'header')
        rangeStr = ['A1:A' num2str(length(sheet.header))];
        [s message] = xlswrite(bookFileName,sheet.header',sheets{i},rangeStr);
        %copyfile(bookFileName,bookFileName);
        startRange = startRange + 1;
    end
    if length(sheet.data)>0
        rangeStr = [ ind2ExcelCol(startRange ) '1:'...
            ind2ExcelCol(startRange + size(sheet.data,1)-1)  num2str(size(sheet.data,2))];
        
        [s message] = xlswrite(bookFileName,sheet.data',sheets{i},rangeStr);
        
    end
end

