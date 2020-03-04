function[] = wmBacklash(sm);


%attempt to get zeiss api comm object from GuiGlobalsStruct if none is provided
if ~exist('sm')
    global GuiGlobalsStruct;
    sm = GuiGlobalsStruct.MyCZEMAPIClass;
end

backlashOffset = 10/1000000; %in microns to meters


%% Get stage information prior to stage INI
%disp('Getting stage position');
stage_x = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
stage_y = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = sm.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = sm.Get_ReturnTypeSingle('AP_STAGE_AT_M');
backlashState = sm.Get_ReturnTypeString('DP_STAGE_BACKLASH');

pause(.01)
'execute backlash'
sm.MoveStage(stage_x + backlashOffset,stage_y+backlashOffset,stage_z,stage_t,stage_r,stage_m);
while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
pause(.01)

sm.MoveStage(stage_x,stage_y,stage_z,stage_t,stage_r,stage_m);
while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
pause(.01)


new_stage_x = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
new_stage_y = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');


if (new_stage_x ~= stage_x) | (new_stage_y ~= stage_y)
    'missed first backlash'
    sm.Set_PassedTypeString('DP_STAGE_BACKLASH', backlashState);
    sm.MoveStage(stage_x,stage_y,stage_z,stage_t,stage_r,stage_m);
    while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.02)
    end
    pause(.01)
    
    
end





