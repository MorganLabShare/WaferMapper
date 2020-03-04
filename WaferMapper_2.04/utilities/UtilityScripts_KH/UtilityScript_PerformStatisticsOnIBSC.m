function UtilityScript_PerformStatisticsOnIBSC()

global GuiGlobalsStruct;

%DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
DirName = uigetdir(GuiGlobalsStruct.WaferDirectory, 'Select directory containing images:');
if isequal(DirName,0) 
    disp('User pressed cancel');
    return;
else
    disp(sprintf('User selected: %s', DirName));
end


SectionNum = 1;
while true
    FileNameOfMatFileBeforeIBSC = sprintf('%s\\TempImage_%d.mat',DirName,SectionNum);
    if ~exist(FileNameOfMatFileBeforeIBSC, 'file')
        break
    end
    load(FileNameOfMatFileBeforeIBSC,'Info');
    Info_BeforeIBSC = Info;
    FileNameOfMatFileAfterIBSC = sprintf('%s\\Image_%d.mat',DirName,SectionNum);
    load(FileNameOfMatFileAfterIBSC,'Info');
    Info_AfterIBSC = Info;
    
    %  StageX_Meters: 0.0944
    %  StageY_Meters: 0.0320
    StageX_IBSCOffset_Microns_Array(SectionNum) = (Info_AfterIBSC.StageX_Meters - Info_BeforeIBSC.StageX_Meters)*1000000;
    StageY_IBSCOffset_Microns_Array(SectionNum) = (Info_AfterIBSC.StageY_Meters - Info_BeforeIBSC.StageY_Meters)*1000000;
    
    
    SectionNum = SectionNum + 1;
end

figure(1021);
scatter(StageX_IBSCOffset_Microns_Array, StageY_IBSCOffset_Microns_Array);
%AXIS([XMIN XMAX YMIN YMAX])
axis([-50 50 -50 50]);