function[] = reinitializeStage(sm);


%attempt to get zeiss api comm object from GuiGlobalsStruct if none is provided
if ~exist('sm')
    global GuiGlobalsStruct;
    sm = GuiGlobalsStruct.MyCZEMAPIClass;
end




%% Get stage information prior to stage INI
disp('Getting stage position');
stage_x = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
stage_y = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = sm.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = sm.Get_ReturnTypeSingle('AP_STAGE_AT_M');
backlashState = sm.Get_ReturnTypeString('DP_STAGE_BACKLASH');



%% Reinitialize the stage
'Reinitializing stage'
sm.Execute('CMD_STAGE_INIT')
while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end



%% Return stage to pre initialization position
'Returning to pre initialization position'
sm.Set_PassedTypeString('DP_STAGE_BACKLASH', backlashState);
sm.MoveStage(stage_x,stage_y,stage_z,stage_t,stage_r,stage_m);
while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end


% %% Backlash once
% previousBacklash = sm.Get_ReturnTypeString('DP_STAGE_BACKLASH');
% 
% sm.Set_PassedTypeString('DP_STAGE_BACKLASH', 'On');
% 
% sm.Execute('CMD_STAGE_BACKLASH')
% while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
%     pause(.02)
% end
% 
% 
% 
% 




