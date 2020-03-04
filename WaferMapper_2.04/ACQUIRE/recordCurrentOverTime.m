% 
%  try
%         GuiGlobalsStruct.MyCZEMAPIClass = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass');
%         IsOK = true;
%       end
%     
%     if IsOK
%         MyReturnInt = GuiGlobalsStruct.MyCZEMAPIClass.InitialiseRemoting;
%         if(MyReturnInt == 0)
%             MyMag = GuiGlobalsStruct.MyCZEMAPIClass.GetMag;
%             MyStr = sprintf('Zeiss API successfully initialized. GetMag() = %0.5g',MyMag);
%             GuiGlobalsStruct.IsZeissAPIInitialized = true;
%           
%             %Make sure we have scan rotation = 0;
%             GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
%           end
%     end
%     

%%
global GuiGlobalsStruct
currentTime = datestr(clock);
currentTime(currentTime==' ') = '_';
currentTime(currentTime==':') = '-';


bookDir = 'V:\recordedCurrents\';
bookName = ['logBookForCurrent_' currentTime];
bookFileName = [bookDir bookName '.xls'];
bookMatName = [bookDir bookName '.mat'];
currentFileName = [bookDir 'recordCurrent-' currentTime '.mat'];
% 
% createLogBook(
% logBook = logOnce;


recordCurrent = [];

startTime = clock;
%%
while 1
    
    %%Get Current
    sC =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCM')
    recordCurrent(size(recordCurrent,1)+1,1) = sC;
    recordCurrent(size(recordCurrent),2) = datenum(clock);
    safesave(currentFileName,'recordCurrent')
    
    
    
    
    %%Get Everything Else
%     logBook = logScopeConditions(logBook);
%     logBook = logImageConditions(logBook,bookName);
%     safesave(bookMatName,'logBook')
    
    
    pause(5)
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

%%
times = datestr(recordCurrent(:,2))
plot(recordCurrent(:,1))






