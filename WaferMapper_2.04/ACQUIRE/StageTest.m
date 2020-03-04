disp('Turning stage backlash off in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','Off');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','Off');



%%get current stage position so we can only vary x and y
disp('Getting stage position');
stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g)'...
    ,stage_x,stage_y,stage_z,stage_t,stage_r, stage_m);
disp(MyStr);
disp(' ');

StageX_Meters = stage_x;
StageY_Meters = stage_y;
DeltaMovement_Meters = .001;


for i = 1:10
    StartTime = tic;
    StageX_Meters = StageX_Meters + DeltaMovement_Meters;
    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
    disp(MyStr);
    %GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STAGE_GOTO_X',StageX_Meters);
    c = 0; clear stage_xt
    startWhile = toc(StartTime)
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        c = c+1;
        stage_xt(c) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X')*1000;
        pause(.01)
    end
    plot(stage_xt),hold on
    disp(sprintf('Stage Move Duration = %0.7g seconds',toc(StartTime)));
end
hold off
