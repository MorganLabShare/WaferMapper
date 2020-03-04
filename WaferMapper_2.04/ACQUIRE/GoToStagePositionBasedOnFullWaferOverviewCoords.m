function [StageX_Meters,StageY_Meters] = GoToStagePositionBasedOnFullWaferOverviewCoords(x_mouse, y_mouse, IsUseStageCorrection, IsActualMove)
global GuiGlobalsStruct;



if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass')
    disp('Turning stage backlash ON in X and Y');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH',GuiGlobalsStruct.backlashState);
end

NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;

[MaxY, MaxX] = size(GuiGlobalsStruct.FullWaferDownsampledDisplayImage);

DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;

X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - x_mouse*DownSamplePixelWidth_mm
Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + y_mouse*DownSamplePixelHeight_mm

StageX_Meters = X_Stage_mm/1000;
StageY_Meters = Y_Stage_mm/1000;

if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass')
    
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
    
    %*** Do stage correction here if requested
    if IsUseStageCorrection
        disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
        [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
        disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
    end
    
    if IsActualMove
        MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
        disp(MyStr);
        GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
        while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
            pause(.02)
        end
        wmBackLash
    end
    
end


end



