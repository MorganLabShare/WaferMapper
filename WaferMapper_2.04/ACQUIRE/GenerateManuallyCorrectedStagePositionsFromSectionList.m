function [  ] = GenerateManuallyCorrectedStagePositionsFromSectionList(  )

global GuiGlobalsStruct;


if isfield(GuiGlobalsStruct, 'StageTransform') 
    if ~isempty(GuiGlobalsStruct.StageTransform) 
        GuiGlobalsStruct.IsUseStageCorrection = true;
    else
        GuiGlobalsStruct.IsUseStageCorrection = false;
    end
else
    GuiGlobalsStruct.IsUseStageCorrection = false;
end

%Walk through each section and
for SectionIndex = 1:length(GuiGlobalsStruct.CoarseSectionList)
    
    y_mouse = GuiGlobalsStruct.CoarseSectionList(SectionIndex).rpeak;
    x_mouse = GuiGlobalsStruct.CoarseSectionList(SectionIndex).cpeak;
    
    IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
    IsActualMove = false;
    [StageX_Meters,StageY_Meters] = GoToStagePositionBasedOnFullWaferOverviewCoords(x_mouse, y_mouse, IsUseStageCorrection, IsActualMove)
    
    
    
    Info.StageX_Meters = StageX_Meters;
    Info.StageY_Meters = StageY_Meters;
    Info.ScanRotation = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
    Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    Info.WorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
    Info.Brightness = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
    Info.Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
    Info.StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
    Info.StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
    if isfield(GuiGlobalsStruct, 'StageTransform')
        Info.StageTransformAtTimeOfSave = GuiGlobalsStruct.StageTransform;
    else
        Info.StageTransformAtTimeOfSave = [];
    end
    
    
    
    
    DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,SectionIndex);
    save(DataFileNameStr,'Info');
    disp(sprintf('Saved %s', DataFileNameStr));
end

