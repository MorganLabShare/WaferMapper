function[logBook] = logGlobals(logBook)


global GuiGlobalsStruct

bookName = GuiGlobalsStruct.CurrentLogBook ;
load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])

wmheader{1} = 'UTSLDirectory';
wmsettings{1} = GuiGlobalsStruct.UTSLDirectory;
wmheader{2} = 'MicronsPerPixel_FromCalibration_ForOverviewImages';
wmsettings{2} = GuiGlobalsStruct.MicronsPerPixel_FromCalibration_ForOverviewImages;
wmheader{3} = 'AlignedTargetListDirectory';
wmsettings{3} = GuiGlobalsStruct.AlignedTargetListDir;
wmheader{4} = 'TempImagesDirectory';
wmsettings{4} = GuiGlobalsStruct.TempImagesDirectory;

wmheader = [wmheader fieldnames(GuiGlobalsStruct.MontageParameters)'];
wmsettings = [wmsettings struct2cell(GuiGlobalsStruct.MontageParameters)'];

logBook.sheets.wmSettings.data = wmsettings;
logBook.sheets.wmSettings.header = wmheader;

%% Save
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     safeSave([GuiGlobalsStruct.TempImagesDirectory 'logBooks\' bookName '.mat'],'logBook')