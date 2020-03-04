function[] = checkCurrent(sectionNumber)

sectionNumber = str2num(sectionNumber);
global GuiGlobalsStruct
checkCurrentValuesFile = [GuiGlobalsStruct.WaferDirectory '\checkCurrentValues.mat'];
checkCurrentLocationFile = [GuiGlobalsStruct.WaferDirectory '\checkCurrentPosition.mat'];

%{
%%Execute to mark record position
global GuiGlobalsStruct
checkCurrentLocationFile = [GuiGlobalsStruct.WaferDirectory '\checkCurrentPosition.mat'];
checkCurrentPoint.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
checkCurrentPoint.StageY_Meters= GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
save(checkCurrentLocationFile,'checkCurrentPoint');
%}
if exist(checkCurrentLocationFile)
try load(checkCurrentLocationFile); %load checkCurrentPoint
catch err
    return
end
    
checkCurrentPoint.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
checkCurrentPoint.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
checkCurrentPoint.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
checkCurrentPoint.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');

%% move to record position
GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(checkCurrentPoint.StageX_Meters,checkCurrentPoint.StageY_Meters,...
    checkCurrentPoint.stage_z,checkCurrentPoint.stage_t,checkCurrentPoint.stage_r,checkCurrentPoint.stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash

%% initiate scan conditions
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_IMAGE_STORE',2);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',2000000);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);


%% start recording
pause(5)
for i = 1:10
    pause(1)
    checkCurrentList(i) =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCM');
end


%% save values
if exist(checkCurrentValuesFile,'file')
    load(checkCurrentValuesFile);
    L = length(checkCurrentValues.sec);
    checkCurrentValues.sec(L+1) = sectionNumber;
    checkCurrentValues.vals(L+1,:) = checkCurrentList;
else 
    checkCurrentValues.sec = sectionNumber;
    checkCurrentValues.vals = checkCurrentList;
end

safeSave(checkCurrentValuesFile,'checkCurrentValues');

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',200);
%}
end

