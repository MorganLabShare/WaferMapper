%AcquireMontageStackAtPointsOfTestStack
DirListArray = dir(GuiGlobalsStruct.WaferDirectory);

n = 1;
ListOfDirNames = [];
for i=1:length(DirListArray)
    if (DirListArray(i).isdir == 1) && (length(DirListArray(i).name) >= length('TestStack'))
        
        if strcmp(DirListArray(i).name(1:length('TestStack')), 'TestStack')
            ListOfDirNames{n} = DirListArray(i).name;
            n = n + 1;
        end
    end
end

if length(ListOfDirNames) > 0
        [SelectionNumber,isok] = listdlg('PromptString','Select a TestStack directory:',...
            'SelectionMode','single',...
            'ListString',ListOfDirNames);
        
        if isok == 1
            GuiGlobalsStruct.TestStackDirectory = sprintf('%s\\%s',GuiGlobalsStruct.WaferDirectory,ListOfDirNames{SelectionNumber});
            MyStr = sprintf('GuiGlobalsStruct.TestStackDirectory = %s', GuiGlobalsStruct.TestStackDirectory);
            disp(MyStr);
        end
        
else
    uiwait(msgbox('No directories beginning with ''TestStack'' found.'));
    return;
    
end


%Create a new directory in this wafer to hold all these images
InputDlgAnswer = inputdlg('Enter name for new directory to store images (will create subdirectory under wafer directory)');
NewNameStr = InputDlgAnswer{1};

NewDirPath = sprintf('%s\\%s', GuiGlobalsStruct.WaferDirectory, NewNameStr);

if ~exist(NewDirPath,'dir')
    [success,message,messageid] = mkdir(NewDirPath);
    if success == 1
        GuiGlobalsStruct.TempImagesDirectory = NewDirPath;
        
    else
        msgbox(message);
    end
    
else
    MyStr = sprintf('Directory (%s) already exists. Will take new images only for those image files that do not already exist in the dir.',NewDirPath);
    uiwait(msgbox(MyStr));
end


SectionNum = 1; %1 REM TO CHANGE BACK!!!!!!!!!
IsDone = false;
while ~IsDone 
   DataFileName = sprintf('%s\\TestDownsampledOverviewImage_%d.mat',GuiGlobalsStruct.TestStackDirectory,SectionNum);
   
   if exist(DataFileName,'file')
       MyStr = sprintf('Loading data file %s', DataFileName);
       disp(MyStr);
       load(DataFileName,'Info');
       
       
       ScanRot_Degrees = Info.ScanRotation;
       GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);
       
       WorkingDistance = Info.WorkingDistance;
       GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',WorkingDistance);
       
       disp('Getting stage position');
       stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
       stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
       stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
       stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');

       StageX_Meters = Info.StageX_Meters;
       StageY_Meters = Info.StageY_Meters;
       MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
       disp(MyStr);
       GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
       while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
           pause(.1)
       end
       pause(1);
       wmBackLash
       
       %Add on the scan rotation desired in montage target (will be reset
        %at end of acquition)
        TempStoreScanRot = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
        NewScanRot = TempStoreScanRot - GuiGlobalsStruct.MontageTarget.MontageNorthAngle; %NOTE KH put in '-' 4-13-2011
        %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
        if NewScanRot > 360
            NewScanRot = NewScanRot - 360;
        end
        if NewScanRot < 0
            NewScanRot = NewScanRot + 360;
        end
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',NewScanRot);
        
        PerformAutoFocus;
        %GridAutoFocus(2, 2, 60, 60);
        
        AcquireMontageAtCurrentPosition(Info.WaferName, Info.Label);
        
        
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',TempStoreScanRot);
       
   else
       IsDone = true;
   end
   
   SectionNum = SectionNum + 1;
end