%AcquireMontageStackAtTargetPoint

% %Determine what wafer is loaded
% MyStr = sprintf('Stage correction map must be up to date. Press cancel if not.');
% uiwait(msgbox(MyStr));
WaferNameIndex = 0;
global GuiGlobalsStruct;
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


%Create a new directory in this wafer to hold all these images
InputDlgAnswer = inputdlg('Enter name for new directory to store images (will create subdirectory under wafer directory)');
NewNameStr = InputDlgAnswer{1};

NewDirPath = sprintf('%s\\%s', GuiGlobalsStruct.WaferDirectory, NewNameStr);

if ~exist(NewDirPath,'dir')
    [success,message,messageid] = mkdir(NewDirPath);
    if success == 1
        GuiGlobalsStruct.TempImagesDirectory = NewDirPath;
        
    else
        msgbox(message);
    end
    
else
    MyStr = sprintf('Directory (%s) already exists. Will take new images only for those image files that do not already exist in the dir.',NewDirPath);
    uiwait(msgbox(MyStr));
end

%Walk through all sections
for SectionIndex = 1:length(GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray)
    
    MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
    %WaferNameIndex
    %SectionIndex
    
    GuiGlobalsStruct.MontageTarget.MicronsPerPixel = MySection.SectionOveriewInfo.FOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageX_Meters;
    GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageY_Meters;
    GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = MySection.SectionOveriewInfo.ImageHeightInPixels;
    
    GuiGlobalsStruct.MontageTarget.Alignment_r_offset = MySection.AlignmentParameters.r_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_c_offset = MySection.AlignmentParameters.c_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = MySection.AlignmentParameters.AngleOffsetInDegrees;
    GuiGlobalsStruct.MontageTarget.LabelStr = MySection.LabelStr;
    
    goodMatch = GoToTargetPointWithImageBasedStageCorrection
    
    
    if ~goodMatch  %Try refocusing
        CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        
        %*** START: This sequence is desigend to release the SEM from Fibics control
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(0.5)
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
        
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_AutoFunction_ScanRate',GuiGlobalsStruct.MontageParameters.AutofunctionScanrate);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_IMAGE_STORE',GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Contrast',GuiGlobalsStruct.MontageParameters.ImageContrast);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Brightness',GuiGlobalsStruct.MontageParameters.ImageBrightness);
        
        
        
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(0.5);
        end
      goodMatch = GoToTargetPointWithImageBasedStageCorrection

    end
% 
%     if ~goodMatch %reinitialize stage
%         reinitializeStage;
%         goodMatch = GoToTargetPointWithImageBasedStageCorrection
%     end
    
    
    
    
    
    %**************************
    %*******************************************************************
    %*** After all of this you are now ready to take the "real" image
    %Restore the proper scan rot needed for montage and fiducial stage correction here
    IsTakeTestImage = true;
    if IsTakeTestImage
        
        %Add on the scan rotation desired in montage target (will be reset
        %at end of acquition)
        TempStoreScanRot = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
        NewScanRot = TempStoreScanRot - GuiGlobalsStruct.MontageTarget.MontageNorthAngle; %NOTE KH put in '-' 4-13-2011
        %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
        if NewScanRot > 360
            NewScanRot = NewScanRot - 360;
        end
        if NewScanRot < 0
            NewScanRot = NewScanRot + 360;
        end
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',NewScanRot);
        
        PerformAutoFocus;
        AcquireMontageAtCurrentPosition(WaferName, MySection.LabelStr);
        
        %             %%%% TAKE CENTER HIGH RES IMAGE
        %             ImageFileNameStr = sprintf('%s\\HighResImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, MySection.LabelStr);
        %             disp(sprintf('Acquiring image file: %s',ImageFileNameStr));
        %
        %             %PerformAutoFocus; %Already performed above for stage correction image
        %
        %             ImageWidthInPixels = 4096; %1024
        %             ImageHeightInPixels = 4096; %1024
        %             DwellTimeInMicroseconds = .5;
        %             FOV_microns = 65.536; %4nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
        %             IsDoAutoRetakeIfNeeded = true;
        %             %Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
        %             %      FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
        %             IsMagOverride = false;
        %             MagForOverride = -1;
        %             WaferNameStr = WaferName;
        %             LabelStr = MySection.LabelStr;
        %             Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
        %                 FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
        %
        %
        %%%% TAKE CENTER Med RES IMAGE
        ImageFileNameStr = sprintf('%s\\MedResImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, MySection.LabelStr);
        disp(sprintf('Acquiring image file: %s',ImageFileNameStr));
        
        %PerformAutoFocus;
        
        ImageWidthInPixels = 4096;%16384;%; %1024
        ImageHeightInPixels = 4096;%16384;%; %1024
        DwellTimeInMicroseconds = 1;
        FOV_microns = 524.288; %32nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
        IsDoAutoRetakeIfNeeded = true;
        %Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
        %      FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
        IsMagOverride = false;
        MagForOverride = -1;
        WaferNameStr = WaferName;
        LabelStr = MySection.LabelStr;
        Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
            FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
        
        
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',TempStoreScanRot);
    end
end


%generate_xml_file(DirNameOfTempImageMatFiles)
generate_xml_file(GuiGlobalsStruct.TempImagesDirectory);