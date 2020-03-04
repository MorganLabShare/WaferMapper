%AcquireAnchorStack.m

GuiGlobalsStruct.MontageTarget.LowResForAlignmentFOVWidthInMicrons = 200;

%RetakeArray = [32];
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
%for jj = 1:length(RetakeArray)
    %i = RetakeArray(jj);
    
    LabelStr = GuiGlobalsStruct.CoarseSectionList(i).Label;
    ImageFileNameStr = sprintf('%s\\LowResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    DataFileNameStr = sprintf('%s\\LowResStackImage_%s.mat', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    disp(sprintf('Acquiring image file: %s',ImageFileNameStr));
    
    
    %The UpdateSectionOverviewDisplay(handles) function uses the
    %SectionLabel_EditBox to determine which section to update. This
    %function sets the parameters that are needed by
    %GoToMontageTargetPointRotationAndFOV
    set(handles.SectionLabel_EditBox,'String',LabelStr);
    UpdateSectionOverviewDisplay(handles);
    
    GoToMontageTargetPointRotationAndFOV;
    
    %NOTE: SCAN ROTATION MUST BE 0deg WHEN DOING THE LOW RES IMAGES OR ELSE THE
    %STAGE CORRECTIONS WILL BE IN THE WRONG DIRECTION
    %These lines store the scan rot value computed by
    %GoToMontageTargetPointRotationAndFOV  and then sets to 0deg
    TempStoreScanRotNeededForHighRes = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
    
    GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_STAGE_BACKLASH');
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.1)
    end
    pause(1);
    
    IsAutoFocus = true;
    if(IsAutoFocus)
        %Note: This sequence of operations seems to work. Do not reduce
        %delays without testing
        CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',10000);
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(1);
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(.5);
            disp('Auto Focusing...');
        end
    end
    pause(2);
    
    %Note: this resets the FOV
    FOV_microns = GuiGlobalsStruct.MontageTarget.LowResForAlignmentFOVWidthInMicrons;
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
    pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
    pause(0.5);
 
    %Acquire image with this FOV but with only 1024x1024 pixels. This is
    %used to compare against
    ImageWidthInPixels = 1024;
    ImageHeightInPixels = 1024;
    DwellTimeInMicroseconds = 1;
    Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,ImageFileNameStr);
    %load this just aquired image
    IsReadOK = false;
    while ~IsReadOK
        IsReadOK = true;
        try
            CurrentImage = imread(ImageFileNameStr, 'tif');
        catch MyException
            IsReadOK = false;
            %disp(sprintf('   imread exception: %s',MyException.identifier));
            pause(.1);
        end
    end
    
    
    %Save info
    Info.Label = LabelStr;
    Info.FOV_microns = FOV_microns;
    Info.ImageWidthInPixels = ImageWidthInPixels;
    Info.ImageHeightInPixels = ImageHeightInPixels;
    Info.DwellTimeInMicroseconds = DwellTimeInMicroseconds;
    Info.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    Info.StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    
    
    safesave(DataFileNameStr,'Info');
    disp(sprintf('Saved %s', DataFileNameStr));
    
    
    if i==1
        %just copy this inot a dummy 'retake aligned' image file
        RetakeAlignedImageFileNameStr = sprintf('%s\\RetakeAlignedLowResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
        imwrite(CurrentImage,RetakeAlignedImageFileNameStr,'tif');
    else
        
        
        
        %reload last image and compute offset to current image taken
        PreviousImageFileNameStr = sprintf('%s\\RetakeAlignedLowResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory,...
            GuiGlobalsStruct.CoarseSectionList(i-1).Label);
        PreviousImage = imread(PreviousImageFileNameStr, 'tif');
        
        %display two side by side
        figure(123);
        subplot(1,2,1);
        imshow(PreviousImage,[0,255]);
        title('PreviousImage');
        subplot(1,2,2);
        imshow(CurrentImage,[0,255]);
        title('CurrentImage');
        
        %Caluclate stage offset needed to align with previous aligned image
        H_gaussian = fspecial('gaussian',[5 5],1.5);
        PreviousImage_Filtered = imfilter(PreviousImage,H_gaussian);
        CurrentImage_Filtered = imfilter(CurrentImage,H_gaussian);
        DSFactor = 2;
        PreviousImage_Filtered_DS = imresize(PreviousImage_Filtered,1/DSFactor,'bilinear'); %Must down sample by 8x to prevent out of memory error on fibics computer
        CurrentImage_Filtered_DS = imresize(CurrentImage_Filtered,1/DSFactor,'bilinear');
        [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] = ...
            CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(PreviousImage_Filtered_DS, CurrentImage_Filtered_DS);

        
        %Use this offset to move the stage into optimal position to align
        %with previous section's image
        MicronsPerPixel = FOV_microns/ImageWidthInPixels;
        disp('HERE IS COMPUTED OFFSET:');
        StageX_Microns_Offset = XOffsetOfNewInPixels*DSFactor*MicronsPerPixel;
        StageY_Microns_Offset = YOffsetOfNewInPixels*DSFactor*MicronsPerPixel;
        MyStr = sprintf('StageX_Microns_Offset = %d, StageY_Microns_Offset = %d',StageX_Microns_Offset, StageY_Microns_Offset);
        disp(MyStr);
        StageX_Meters_Offset = StageX_Microns_Offset/1000000;
        StageY_Meters_Offset = StageY_Microns_Offset/1000000;

        disp('Getting stage position');
        StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X'); 
        StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
        stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
        stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
        stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
        MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g, )'...
            ,StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r, stage_m);
        disp(MyStr);
        disp(' ');
        
        StageX_Meters = StageX_Meters - StageX_Meters_Offset;
        StageY_Meters = StageY_Meters - StageY_Meters_Offset;
        
        MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
        disp(MyStr);
        GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
        while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
            pause(.1)
        end
        pause(1)
        
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_STAGE_BACKLASH');
        while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
            pause(.1)
        end
        pause(1);
        
        %Retake this image and record its position information
        RetakeImageFileNameStr = sprintf('%s\\RetakeLowResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
        Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,RetakeImageFileNameStr);
        %load this just aquired image
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                RetakeImage = imread(RetakeImageFileNameStr, 'tif');
            catch MyException
                IsReadOK = false;
                %disp(sprintf('   imread exception: %s',MyException.identifier));
                pause(.1);
            end
        end
        
        %Save info
        Info.Label = LabelStr;
        Info.FOV_microns = FOV_microns;
        Info.ImageWidthInPixels = ImageWidthInPixels;
        Info.ImageHeightInPixels = ImageHeightInPixels;
        Info.DwellTimeInMicroseconds = DwellTimeInMicroseconds;
        Info.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        Info.StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
        Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
        Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
        Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
        RetakeDataFileNameStr = sprintf('%s\\RetakeLowResStackImage_%s.mat', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
        save(RetakeDataFileNameStr,'Info');
        
        
        
        %finally do another realign with the previous image and do software
        %alignment of image and save
        disp('HERE IS COMPUTED OFFSET (of retake):');
        RetakeImage_Filtered = imfilter(RetakeImage,H_gaussian);
        RetakeImage_Filtered_DS = imresize(RetakeImage_Filtered,1/DSFactor,'bilinear');
        
        %NOTE: I NEED TO CROP IMAGES HERE TO GET RID OF EDGE EFFECTS OF
        %COMPARING REALIGNED IMAGES
        %imcrop(image,[XMIN YMIN WIDTH HEIGHT]);
        [TempHeight, TempWidth] = size(PreviousImage_Filtered_DS)
        PreviousImage_Filtered_DS_Crop = imcrop(PreviousImage_Filtered_DS, [50, 50, TempWidth-50, TempHeight - 50]); 
        RetakeImage_Filtered_DS_Crop = imcrop(RetakeImage_Filtered_DS, [50, 50, TempWidth-50, TempHeight - 50]); 
        
        [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] = ...
            CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(PreviousImage_Filtered_DS_Crop, RetakeImage_Filtered_DS_Crop);
        StageX_Microns_Offset = XOffsetOfNewInPixels*DSFactor*MicronsPerPixel;
        StageY_Microns_Offset = YOffsetOfNewInPixels*DSFactor*MicronsPerPixel;
        MyStr = sprintf('StageX_Microns_Offset = %d, StageY_Microns_Offset = %d',StageX_Microns_Offset, StageY_Microns_Offset);
        disp(MyStr);
 
        % Software realign %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        r_offset = YOffsetOfNewInPixels*DSFactor; %Note: Here is where the reversed Y-Axis sign change is fixed
        c_offset = - XOffsetOfNewInPixels*DSFactor;
        RetakeImage_shifted = 0*RetakeImage;
        [MaxR, MaxC] = size(RetakeImage)
        for r = 1:MaxR
            for c = 1:MaxC
                New_r = r + r_offset;
                New_c = c + c_offset;
                if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
                    RetakeImage_shifted(New_r, New_c) = RetakeImage(r,c);
                end
            end
        end
        
        RetakeAlignedImageFileNameStr = sprintf('%s\\RetakeAlignedLowResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
        imwrite(RetakeImage_shifted, RetakeAlignedImageFileNameStr, 'tif');
        
        %PUT IN A BEAM OFFSET OF THE AMOUNT NEEDED TO COMPENSATE FOR LAST
        %CALCULATE IMAGE OFFSET
        %BeamShift( X_Microns, Y_Microns )
        BeamShift( -StageX_Microns_Offset, StageY_Microns_Offset );
        
    end
    
    
    
    %*******************************************************************
    %*** After all of this you are now read to take the "real" image
    %Restore the proper scan rot needed for montage and fiducial stage correction here
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',TempStoreScanRotNeededForHighRes);
    
    
    HighResImageFileNameStr = sprintf('%s\\HighResStackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    HighResDataFileNameStr = sprintf('%s\\HighResStackImage_%s.mat', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    disp(sprintf('Acquiring image file: %s',HighResImageFileNameStr));
    
    PerformAutoFocusStigFocus;
    
    %Note: this resets the FOV
    FOV_microns = GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons;
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
    pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
    pause(0.5);
    
    %Acquire image with this FOV
    ImageWidthInPixels = 16384;%8192;
    ImageHeightInPixels = 16384;%8192;
    DwellTimeInMicroseconds = 2;
    Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,HighResImageFileNameStr);
    %load this just aquired image
%     IsReadOK = false;
%     while ~IsReadOK
%         IsReadOK = true;
%         try
%             CurrentImage = imread(HighResImageFileNameStr, 'tif');
%         catch MyException
%             IsReadOK = false;
%             %disp(sprintf('   imread exception: %s',MyException.identifier));
%             pause(.1);
%         end
%     end
    
    %Save info
    Info.Label = LabelStr;
    Info.FOV_microns = FOV_microns;
    Info.ImageWidthInPixels = ImageWidthInPixels;
    Info.ImageHeightInPixels = ImageHeightInPixels;
    Info.DwellTimeInMicroseconds = DwellTimeInMicroseconds;
    Info.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    Info.StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    Info.ScanRotation = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
    
    save(HighResDataFileNameStr,'Info');
    
    BeamShift( 0, 0 );
    
end