function UpdateFullWaferDisplay(handles)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global GuiGlobalsStruct;


axes(handles.Axes_FullWaferDisplay);
imshow(GuiGlobalsStruct.FullWaferDownsampledDisplayImage);

if GuiGlobalsStruct.IsZeissAPIInitialized
    GuiGlobalsStruct.IsDisplayCurrentStagePosition = true;
else
    GuiGlobalsStruct.IsDisplayCurrentStagePosition = false;
end

if GuiGlobalsStruct.IsDisplayCoarseSectionList
    %If CoarseSectionList has not been created or loaded then it will be
    %empty array
    for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
        
        if(~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted)
            rpeak = GuiGlobalsStruct.CoarseSectionList(i).rpeak;
            cpeak = GuiGlobalsStruct.CoarseSectionList(i).cpeak;
            
            h1 = line([cpeak-50, cpeak+50],[rpeak, rpeak]);
            h2 = line([cpeak, cpeak],[rpeak-50, rpeak+50]);
            set(h1,'Color',[1 0 0]);
            set(h2,'Color',[1 0 0]);
            
            TextStr = GuiGlobalsStruct.CoarseSectionList(i).Label;
            h3 = text(cpeak, rpeak, TextStr);
            set(h3,'Color',[1 0 0]);
            
        end
    end
end

if GuiGlobalsStruct.IsDisplayCurrentStagePosition
    disp('Getting stage position');
    stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    
    %Note: I need to do the reverse stage correction here if one exists
    %First apply the current stage transformation if it exists
    if isfield(GuiGlobalsStruct,'StageTransform')
        if ~isempty(GuiGlobalsStruct.StageTransform)
            disp(sprintf('Before inverse transform (%d, %d)',stage_x, stage_y));
            [stage_x, stage_y] = tforminv(GuiGlobalsStruct.StageTransform,[stage_x],[stage_y]);
            disp(sprintf('After inverse transform (%d, %d)',stage_x, stage_y));
        end
    end
    
    
    NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
    NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;
    
    DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
    DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
    
    X_Stage_mm = stage_x*1000;
    Y_Stage_mm = stage_y*1000;
    
    x_mouse = -(X_Stage_mm - GuiGlobalsStruct.FullMapData.LeftStageX_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000))/DownSamplePixelWidth_mm;
    y_mouse = (Y_Stage_mm - GuiGlobalsStruct.FullMapData.TopStageY_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000))/DownSamplePixelHeight_mm;
    
    h1 = line([x_mouse-100, x_mouse+100],[y_mouse, y_mouse]);
    h2 = line([x_mouse, x_mouse],[y_mouse-100, y_mouse+100]);
    set(h1,'Color',[0 0 1]);
    set(h2,'Color',[0 0 1]);
    
end



end

