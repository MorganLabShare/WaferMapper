function GoToFirstFiducial(FiducialsDirectory)
global GuiGlobalsStruct;

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);

FiducialNum = 1;

FiducialNumStr = sprintf('%d',(100 + FiducialNum));
ImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',FiducialsDirectory,FiducialNumStr(2:3));
DataFileNameStr = sprintf('%s\\Fiducial_%s.mat',FiducialsDirectory,FiducialNumStr(2:3));

if ~exist(DataFileNameStr, 'file')
    uiwait(msgbox(sprintf('Could not load: %s', DataFileNameStr)));
    return;
else
    h_msgbox = msgbox('Moving to first fiducial position...');
    
    
    %load info for this fiducial
    disp(sprintf('Loading %s', DataFileNameStr));
    load(DataFileNameStr,'Info');
    
    %Set Fibics FOV to the same as when original fiducial was acquired
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
    
    %The idea here is to always modify an existing transformation and
    %scan rotation. If these do not exist yet then create as unity.
    StageX_Meters = Info.StageX_Meters;
    StageY_Meters = Info.StageY_Meters;
    
    %Move stage to this stored fiducial position
    disp('Getting stage position');
    stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g, )'...
        ,stage_x,stage_y,stage_z,stage_t,stage_r, stage_m);
    disp(MyStr);
    disp(' ');
    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
    disp(MyStr);
    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.02)
    end
    wmBackLash
    
    if ishandle(h_msgbox)
        close(h_msgbox);
    end
    
    
    
    MyAnswer = questdlg('Use joystick to move stage (x,y) to center the low resolution fiducial and press OK.', 'Question', 'OK', 'Cancel', 'OK');
    if strcmp(MyAnswer, 'Cancel')
        return;
    end
    
    New_StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    New_StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    
    
    GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_X_Meters = New_StageX_Meters - StageX_Meters;
    GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_Y_Meters = New_StageY_Meters - StageY_Meters;
    
    uiwait(msgbox(sprintf('Offset (x,y) = (%0.5g, %0.5g) mm', 1000*GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_X_Meters, ...
        1000*GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_Y_Meters)));
    
end