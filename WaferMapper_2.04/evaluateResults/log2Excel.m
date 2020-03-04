function[] = log2Excel()
tic
%% turn log file into excel
global GuiGlobalsStruct;

bookName = GuiGlobalsStruct.CurrentLogBook ;
load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])

bookFileName =[GuiGlobalsStruct.TempImagesDirectory '\logBooks\' GuiGlobalsStruct.CurrentLogBook '.xls'];
bookFileNameUTSL =[GuiGlobalsStruct.UTSLDirectory '\logBooks\' GuiGlobalsStruct.CurrentLogBook '.xls'];

sheets = fieldnames(logBook.sheets);

%% write structure into excel file
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


[success message messageID] = copyfile(bookFileName,bookFileNameUTSL);

toc

