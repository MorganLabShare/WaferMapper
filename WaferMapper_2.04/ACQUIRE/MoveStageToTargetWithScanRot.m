function MoveStageToTargetWithScanRot(StageX_Meters, StageY_Meters, ScanRot_Degrees)
global GuiGlobalsStruct;




disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
pause(.2);

%First apply the current stage transformation if it exists
if isfield(GuiGlobalsStruct,'StageTransform')
    if ~isempty(GuiGlobalsStruct.StageTransform)
        disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters))
        [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',...
            GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees + ScanRot_Degrees);
        disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters))
    else
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);
        GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = 0;
    end
else
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);
    GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = 0;
end

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
%LogFile_WriteLine(sprintf('Moving stage to target x = %0.5g and y = %0.5g',StageX_Meters,StageY_Meters));
disp(MyStr);
GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash



