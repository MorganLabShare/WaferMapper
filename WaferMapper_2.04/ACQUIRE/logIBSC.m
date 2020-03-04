function[logBook] = logIBSC(logBook,StageX_Microns_Offset,StageY_Microns_Offset, AngleOffsetOfNewInDegrees, FigureOfMerit,XOffsetOfNewInPixels, YOffsetOfNewInPixels)
global GuiGlobalsStruct
% bookName = GuiGlobalsStruct.CurrentLogBook ;
% load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])


secNam = GuiGlobalsStruct.MontageTarget.LabelStr;

L = size(logBook.sheets.IBSC.data,1);
logBook.sheets.IBSC.data(L+1,1:7) = { secNam  StageX_Microns_Offset StageY_Microns_Offset ...
    AngleOffsetOfNewInDegrees  FigureOfMerit XOffsetOfNewInPixels  YOffsetOfNewInPixels};

%% Save
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     safeSave([GuiGlobalsStruct.TempImagesDirectory 'logBooks\' bookName '.mat'],'logBook')