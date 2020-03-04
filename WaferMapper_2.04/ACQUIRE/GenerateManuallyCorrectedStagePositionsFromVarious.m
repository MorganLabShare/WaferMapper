function [  ] = GenerateManuallyCorrectedStagePositionsFromVarious( )

global GuiGlobalsStruct;

%WD_AtAcquitionStart, StigX_AtAcquitionStart, StigY_AtAcquitionStart have
%been removed from WaferMapper as of 6-28-2013.


AnswerStr = questdlg('Generate based on...', ...
                         'Question', ...
                         'Section List', 'Target Point', 'Aligned Target Points', 'Section List');
                     

                     
if strcmp(AnswerStr, '')
    return;
end

if isfield(GuiGlobalsStruct, 'StageTransform') 
    if ~isempty(GuiGlobalsStruct.StageTransform) 
        GuiGlobalsStruct.IsUseStageCorrection = true;
    else
        GuiGlobalsStruct.IsUseStageCorrection = false;
    end
else
    GuiGlobalsStruct.IsUseStageCorrection = false;
end


if strcmp(AnswerStr, 'Aligned Target Points') %WaferName and WaferNameIndex needed below
    % %Determine what wafer is loaded
    WaferNameIndex = 0;
    for i = 1:length(GuiGlobalsStruct.ListOfWaferNames)
        WaferName = GuiGlobalsStruct.ListOfWaferNames{i};
        WaferDirName = sprintf('%s\\%s',...
            GuiGlobalsStruct.UTSLDirectory, WaferName);
        if strcmp(GuiGlobalsStruct.WaferDirectory, WaferDirName)
            WaferNameIndex = i;
        end
    end
    if WaferNameIndex == 0
        MyStr = sprintf('Could not find index of current wafer in loaded target points.');
        uiwait(msgbox(MyStr));
        return;
    end
    WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex};
    
    YesNoAnswerToUseImagedBasedStageCorrection = questdlg('Do you want to use image based stage correction?', 'Question', 'Yes', 'No', 'No');
    
    if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
        YesNoAnswerToPerformAutoFocusDuringIBSC = questdlg('Do you want to perform an Auto Focus during IBSC?', 'Question', 'Yes', 'No', 'No');
    end
    
end

MyStr = sprintf('Generating %d files...',length(GuiGlobalsStruct.CoarseSectionList));
h_msgbox = msgbox(MyStr);


%Walk through each section and
for SectionIndex = 1:length(GuiGlobalsStruct.CoarseSectionList)
    
    %%% START: IF 'Section List'
    if strcmp(AnswerStr, 'Section List')
        y_mouse = GuiGlobalsStruct.CoarseSectionList(SectionIndex).rpeak;
        x_mouse = GuiGlobalsStruct.CoarseSectionList(SectionIndex).cpeak;
        
        IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
        IsActualMove = false;
        [StageX_Meters,StageY_Meters] = GoToStagePositionBasedOnFullWaferOverviewCoords(x_mouse, y_mouse, IsUseStageCorrection, IsActualMove);
        ScanRotation = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
    end
    %%% END: IF 'Section List'
    
    %%% START: IF 'Target Point'
    if strcmp(AnswerStr, 'Target Point')
        LabelStr = num2str(SectionIndex);
        
        
        OverviewDataFileNameStr = sprintf('%s\\SectionOverview_%s.mat',GuiGlobalsStruct.SectionOverviewsDirectory,...
            LabelStr);
        OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',...
            GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,LabelStr);
        
        load(OverviewDataFileNameStr, 'Info');
        load(OverviewAlignedDataFileNameStr, 'AlignmentParameters');
        
        
        %     Info
        %     AlignmentParameters
        
        %read in this info
        GuiGlobalsStruct.MontageTarget.MicronsPerPixel = Info.ReadFOV_microns/Info.ImageWidthInPixels; %KH replaced with ReadFOV_microns 6-15-2011
        GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = Info.StageX_Meters;
        GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = Info.StageY_Meters;
        GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = Info.ImageWidthInPixels;
        GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = Info.ImageHeightInPixels;
        
        GuiGlobalsStruct.MontageTarget.Alignment_r_offset = AlignmentParameters.r_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_c_offset = AlignmentParameters.c_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = AlignmentParameters.AngleOffsetInDegrees;
        GuiGlobalsStruct.MontageTarget.LabelStr = LabelStr;
        
        
        %First get target point coords in pixels relative to center of image
        y_pixels = -( GuiGlobalsStruct.MontageTarget.r - floor(GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels/2) );
        x_pixels = GuiGlobalsStruct.MontageTarget.c - floor(GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels/2);
        
        %Then apply a rotation of this
        theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees;
        cosTheta = cos(theta_rad);
        sinTheta = sin(theta_rad);
        x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
        y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;
        
        %Then apply the translation offsets that were needed to align this image
        x_prime_pixels = x_prime_pixels - GuiGlobalsStruct.MontageTarget.Alignment_c_offset;
        y_prime_pixels = y_prime_pixels + GuiGlobalsStruct.MontageTarget.Alignment_r_offset;
        
        %now convert this to stage coordinates
        StageX_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview;
        StageY_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview;
        
        
        %Handle pixel to stage calibration
        if isfield(GuiGlobalsStruct, 'MicronsPerPixel_FromCalibration_ForOverviewImages')
            MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MicronsPerPixel_FromCalibration_ForOverviewImages;
        else
            MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
        end
        
        
        StageX_Meters = StageX_Meters_CenterOriginalOverview - ...
            x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000);
        StageY_Meters = StageY_Meters_CenterOriginalOverview - ...
            y_prime_pixels*(MicronsPerPixel_FromCalibration/1000000);
        
        
        
        
        ScanRot_Degrees = -GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees -...
            GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
        
        
        
        %Apply the current stage transformation if it exists
        if isfield(GuiGlobalsStruct,'StageTransform')
            if ~isempty(GuiGlobalsStruct.StageTransform)
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                ScanRot_Degrees = ScanRot_Degrees + GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees;
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));  
            end
        end
        
        %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
        if ScanRot_Degrees > 360
            ScanRot_Degrees = ScanRot_Degrees - 360;
        end
        
        if ScanRot_Degrees < 0
            ScanRot_Degrees = ScanRot_Degrees + 360;
        end
        
        ScanRotation = ScanRot_Degrees;
    end
    %%% END: IF 'Target Point'
    
    %%% START: IF 'Aligned Target Points' ('No' YesNoAnswerToUseImagedBasedStageCorrection condition)
    if strcmp(AnswerStr, 'Aligned Target Points') && strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'No')
        MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
        
        GuiGlobalsStruct.MontageTarget.MicronsPerPixel = MySection.SectionOveriewInfo.ReadFOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
        GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageX_Meters;
        GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageY_Meters;
        GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = MySection.SectionOveriewInfo.ImageWidthInPixels;
        GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = MySection.SectionOveriewInfo.ImageHeightInPixels;
        
        GuiGlobalsStruct.MontageTarget.Alignment_r_offset = MySection.AlignmentParameters.r_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_c_offset = MySection.AlignmentParameters.c_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = MySection.AlignmentParameters.AngleOffsetInDegrees;
        GuiGlobalsStruct.MontageTarget.LabelStr = MySection.LabelStr;
        
        
        %First get target point coords in pixels relative to center of image
        y_pixels = -( GuiGlobalsStruct.MontageTarget.r - floor(GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels/2) );
        x_pixels = GuiGlobalsStruct.MontageTarget.c - floor(GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels/2);
        
        %Then apply a rotation of this
        theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees;
        cosTheta = cos(theta_rad);
        sinTheta = sin(theta_rad);
        x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
        y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;
        
        %HERE IS WHERE I ADD IN THE CORRECTION FROM THE AlignedTargetList
        r_offset = MySection.YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
        c_offset = - MySection.XOffsetOfNewInPixels;
        GuiGlobalsStruct.MontageTarget.Alignment_r_offset = GuiGlobalsStruct.MontageTarget.Alignment_r_offset...
            +r_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_c_offset = GuiGlobalsStruct.MontageTarget.Alignment_c_offset...
            +c_offset;
        
        %Then apply the translation offsets that were needed to align this image
        x_prime_pixels = x_prime_pixels - GuiGlobalsStruct.MontageTarget.Alignment_c_offset;
        y_prime_pixels = y_prime_pixels + GuiGlobalsStruct.MontageTarget.Alignment_r_offset;
        
        %now convert this to stage coordinates
        StageX_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview;
        StageY_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview;
        
        %Handle pixel to stage calibration
        if isfield(GuiGlobalsStruct, 'MicronsPerPixel_FromCalibration_ForOverviewImages')
            MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MicronsPerPixel_FromCalibration_ForOverviewImages;
        else
            MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
        end
        
        StageX_Meters = StageX_Meters_CenterOriginalOverview - ...
            x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000);
        StageY_Meters = StageY_Meters_CenterOriginalOverview - ...
            y_prime_pixels*(MicronsPerPixel_FromCalibration/1000000);%Note: This function already applies the stage correction transformation
                                                                            %and angle correction
        %ScanRot_Degrees = -GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees;% -GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
        ScanRot_Degrees = -GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees -...
            GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
        
        %Apply the current stage transformation if it exists
        if isfield(GuiGlobalsStruct,'StageTransform')
            if ~isempty(GuiGlobalsStruct.StageTransform)
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                ScanRot_Degrees = ScanRot_Degrees + GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees;
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));          
            end
        end
        
        %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
        if ScanRot_Degrees > 360
            ScanRot_Degrees = ScanRot_Degrees - 360;
        end
        
        if ScanRot_Degrees < 0
            ScanRot_Degrees = ScanRot_Degrees + 360;
        end
        
        ScanRotation = ScanRot_Degrees;
    end
    %%% END: IF 'Aligned Target Points' ('No' YesNoAnswerToUseImagedBasedStageCorrection condition)
    
    %%% START: IF 'Aligned Target Points' ('Yes' YesNoAnswerToUseImagedBasedStageCorrection condition)
    if strcmp(AnswerStr, 'Aligned Target Points') && strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
        MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
        
        GuiGlobalsStruct.MontageTarget.MicronsPerPixel = MySection.SectionOveriewInfo.ReadFOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
        GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageX_Meters;
        GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageY_Meters;
        GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = MySection.SectionOveriewInfo.ImageWidthInPixels;
        GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = MySection.SectionOveriewInfo.ImageHeightInPixels;
        
        GuiGlobalsStruct.MontageTarget.Alignment_r_offset = MySection.AlignmentParameters.r_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_c_offset = MySection.AlignmentParameters.c_offset;
        GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = MySection.AlignmentParameters.AngleOffsetInDegrees;
        GuiGlobalsStruct.MontageTarget.LabelStr = MySection.LabelStr;
        
        if strcmp(YesNoAnswerToPerformAutoFocusDuringIBSC, 'Yes')
            DoAutoFocusAfterGoToMontageTargetMove = true; %used in GoToTargetPointWithImageBasedStageCorrection function
        else
            DoAutoFocusAfterGoToMontageTargetMove = false;
        end
        GoToTargetPointWithImageBasedStageCorrection; 
        pause(2);
     
        %record the position and scan rotation moved to
        StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        ScanRotation = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
    end
    %%% END: IF 'Aligned Target Points' ('Yes' YesNoAnswerToUseImagedBasedStageCorrection condition)
    
    clear Info; %needed because it is used in a different context above
    
    %%%%%%%%%%%%%%%
    %%% Do actual generation of CorrectedStagePosition_x.mat file
    Info.StageX_Meters = StageX_Meters;
    Info.StageY_Meters = StageY_Meters;
    Info.ScanRotation = ScanRotation;
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
    
    if ~exist(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory, 'dir')
        mkdir(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory);
    end
    
    
    DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,SectionIndex);
    save(DataFileNameStr,'Info');
    disp(sprintf('Saved %s', DataFileNameStr));
end

if ishandle(h_msgbox)
    close(h_msgbox);
end

