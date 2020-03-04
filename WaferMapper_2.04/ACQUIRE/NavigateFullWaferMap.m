%Navigate Full Wafer Map

%Note: This function assumes that the full wafer map is loaded into the
%MapWafer gui and that Zeiss and Fibics APIs are initialized

axes(handles.Axes_FullWaferDisplay);

if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass')
    disp('Turning stage backlash ON in X and Y');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
end

NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;

[MaxY, MaxX] = size(GuiGlobalsStruct.FullWaferDownsampledDisplayImage);

while(1)
    disp('HERE 3');
    IsAbortMove = false;
    
    %disp('ginput response;');
    [x_mouse, y_mouse, button] = ginput(1);
    if (x_mouse < 0) || (x_mouse > MaxX) || (y_mouse < 0) || (y_mouse > MaxY) 
        disp('HERE 1');
        break; %break out of pick loop if user picks outside of axes bounds
    end
    if button == 27 %'Esc'
        disp('HERE 2');
        break; %break out of pick loop if user presses esc
    end
    
    if (button == 1) || (button == 3) %left mouse click means move, right means zoom in to 3x3 before move
        Mouse_r_IndexInFullMap = y_mouse*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        Mouse_c_IndexInFullMap = x_mouse*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        
        Mouse_TileR = 1+floor(Mouse_r_IndexInFullMap/GuiGlobalsStruct.FullMapData.ImageHeightInPixels);
        Mouse_TileC = 1+floor(Mouse_c_IndexInFullMap/GuiGlobalsStruct.FullMapData.ImageWidthInPixels);
        
        %If user pressed right mouse button then pop up 3x3 image to get
        %more precise position click
        if button == 3
            %determine which tile R,C the user clicked in
            AccumulatorImage3x3 = Read3x3TileImages(Mouse_TileR, Mouse_TileC);
            h_3x3fig = figure();
            
            
            imshow(AccumulatorImage3x3,[0,255]);
            set(h_3x3fig, 'Position', get(0,'Screensize')); %This maximizes the window for best resolution
            
            [x_mouse_in3x3, y_mouse_in3x3, button_in3x3] = ginput(1);
            if button_in3x3 == 27 %'Esc'
                if ishandle(h_3x3fig)
                    close(h_3x3fig);
                end
                IsAbortMove = true;
            end
            
            %Caluclate x_mouse_inFullResolutionPixels
            y_mouse_inFullResolutionPixels = (Mouse_TileR-2)*GuiGlobalsStruct.FullMapData.ImageHeightInPixels + y_mouse_in3x3;
            x_mouse_inFullResolutionPixels = (Mouse_TileC-2)*GuiGlobalsStruct.FullMapData.ImageHeightInPixels + x_mouse_in3x3;
            
            %JUST FOR TEST. REMOVE AFTER!!!
            %ExtractSubImageFromFullWaferTileMontage(y_mouse_inFullResolutionPixels, x_mouse_inFullResolutionPixels, 200, 400);
            %%%
            
            
            X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - x_mouse_inFullResolutionPixels*NativePixelWidth_mm
            Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + y_mouse_inFullResolutionPixels*NativePixelHeight_mm
            
            if ishandle(h_3x3fig)
                close(h_3x3fig);
            end
        else %button == 1
            
            
            DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            
            
            X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - x_mouse*DownSamplePixelWidth_mm
            Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + y_mouse*DownSamplePixelHeight_mm
        end
        
        
        
        
        
        
        
        StageX_Meters = X_Stage_mm/1000;
        StageY_Meters = Y_Stage_mm/1000;
        
        if exist('StageOffsetForLowResFiducialTaking_X_Meters', 'var')
            uiwait(msgbox(sprintf('Using offset (x,y) = (%0.5g, %0.5g) mm', 1000*StageOffsetForLowResFiducialTaking_X_Meters, ...
                1000*StageOffsetForLowResFiducialTaking_Y_Meters)));
            StageX_Meters = StageX_Meters + StageOffsetForLowResFiducialTaking_X_Meters;
            StageY_Meters = StageY_Meters + StageOffsetForLowResFiducialTaking_Y_Meters;
        end
        
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
            if GuiGlobalsStruct.IsUseStageCorrection
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters))
            end
            
            if ~IsAbortMove
                MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
                disp(MyStr);
                GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
                while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                    pause(.02)
                end
                wmBackLash
            end
            
        end
        
        %This updates the display showing the moved to position
        UpdateFullWaferDisplay(handles);
    end
    
    %'G' key is for 'grab image' at current location
    % Where the image is saved is determined byt the state the program is
    % in.
    if (button == 'G') || (button == 'g')
        
        IsGrabImage = false;
        switch GuiGlobalsStruct.ProgramState
            case 'Acquiring Low Resolution Fiducials'
                MyStr = sprintf('About to grab low resolution fiducial image. Manually focus if needed then press OK.\n (NOTE: It does not matter what final mag is, it will be reset before image is taken.)');
                uiwait(msgbox(MyStr, 'modal'));
                IsGrabImage = true;
                
                %parameters for low res fiducials
                FOV_microns = GuiGlobalsStruct.WaferParameters.LowResFiducialFOV_microns; %4096;
                ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels;% 1024;
                ImageHeightInPixels = GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels;%1024;
                DwellTimeInMicroseconds = GuiGlobalsStruct.WaferParameters.FiducialDwellTime_microseconds; %2;
                %GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
                pause(0.5);
                
                %This loop proceeds until it finds a fiducial file name that
                %has not already been written
                Num = 1;
                IsDone = false;
                while ~IsDone
                    FiducialNumStr = sprintf('%d',(100 + Num));
                    ImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',GuiGlobalsStruct.LowResFiducialsDirectory,FiducialNumStr(2:3));
                    
                    if ~exist(ImageFileNameStr, 'file')
                        IsDone = true;
                    end
                    Num = Num + 1;
                end
                
            case 'Acquiring High Resolution Fiducials'
                MyStr = sprintf('About to grab high resolution fiducial image. Manually focus if needed then press OK.\n (NOTE: It does not matter what final mag is, it will be reset before image is taken.)');
                uiwait(msgbox(MyStr, 'modal'));
                IsGrabImage = true;
                
                %parameters for high res fiducials
                FOV_microns = GuiGlobalsStruct.WaferParameters.HighResFiducialFOV_microns; %256;
                ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels; %1024;
                ImageHeightInPixels = GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels; %1024;
                DwellTimeInMicroseconds = GuiGlobalsStruct.WaferParameters.FiducialDwellTime_microseconds; %2;
                %GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
                pause(0.5);
                
                %This loop proceeds until it finds a fiducial file name that
                %has not already been written
                Num = 1;
                IsDone = false;
                while ~IsDone
                    FiducialNumStr = sprintf('%d',(100 + Num));
                    ImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',GuiGlobalsStruct.HighResFiducialsDirectory,FiducialNumStr(2:3));
                    
                    if ~exist(ImageFileNameStr, 'file')
                        IsDone = true;
                    end
                    Num = Num + 1;
                end
                
                
            case 'Acquiring Example Section Image'
                MyStr = sprintf('About to grab example section image (for template matching). Manually focus if needed then press OK.\n (NOTE: It does not matter what final mag is, it will be reset before image is taken.)');
                uiwait(msgbox(MyStr, 'modal'));
                IsGrabImage = true;
                
                %Note: These parameters must be the same as the ones for
                %the tiles in the original full wafer map since a
                %convolution between them is used for auto mapping sections
                %(and since the contrast conmpensation assumes this)
                %Save all crucial params in FullMapData.mat            
                FOV_microns = GuiGlobalsStruct.FullMapData.TileFOV_microns;
                ImageWidthInPixels = GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
                ImageHeightInPixels = GuiGlobalsStruct.FullMapData.ImageHeightInPixels;
                DwellTimeInMicroseconds = GuiGlobalsStruct.FullMapData.DwellTimeInMicroseconds;
                %GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
                pause(0.5);
                
                Num = 1;
                    
                ImageFileNameStr = sprintf('%s\\ExampleSectionImage.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
                
            case 'Acquiring Pixel To Stage Calibration Images'
                MyStr = sprintf('About to grab Pixel To Stage Calibration images. Manually focus if needed then press OK.\n (NOTE: It does not matter what final mag is, it will be reset before image is taken.)');
                uiwait(msgbox(MyStr, 'modal'));
                IsGrabImage = true;
                
                %Note: These parameters must be the same as the ones for
                %the section overviews since the calibration will be used
                %to interpert these images             
                FOV_microns = GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns;
                ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels;
                ImageHeightInPixels = ImageWidthInPixels;
                DwellTimeInMicroseconds = 2; %KH changed to really fast and Y direction move 12-2-2011 %Make really clean images GuiGlobalsStruct.WaferParameters.SectionOverviewDwellTime_microseconds;
                %GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
                pause(0.5);
                
                Num = 1;
                    
                ImageFileNameStr = sprintf('%s\\PixelToStageCalibrationImage.tif',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
                
                
                
            otherwise
                disp('Unknown program state.')
        end
        
        if IsGrabImage
            %MyStr = sprintf('Acquiring %s, Please wait...',ImageFileNameStr);
            %h_msgbox = msgbox(MyStr,'modal');
            
            StartTimeOfImageAcquire = tic;

            %Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
            %     FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
            IsDoAutoRetakeIfNeeded = false;
            IsMagOverride = false;
            MagForOverride = -1;
            WaferNameStr = '';
            LabelStr = '';
            MyStr = sprintf('Acquiring image: %s', ImageFileNameStr);
            h_msgbox = msgbox(MyStr);
            Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
            
            if ishandle(h_msgbox)
                close(h_msgbox);
            end
            
            disp(sprintf('Image Aquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
            
            %Acquire one more stage offset images if we are doing Pixel To Stage Calibration
            if strcmp(GuiGlobalsStruct.ProgramState, 'Acquiring Pixel To Stage Calibration Images')
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
                
                StageX_Meters = stage_x; %stage_x + (FOV_microns/4)/1000000; 
                StageY_Meters = stage_y - (FOV_microns/4)/1000000;
                
                MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
                disp(MyStr);
                GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
                while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                    pause(.02)
                end
                wmBackLash
                
                ImageFileNameStr_Shifted = [ImageFileNameStr(1:end-4), '_ShiftedInY.tif'];
                
                MyStr = sprintf('Acquiring image: %s', ImageFileNameStr_Shifted);
                h_msgbox = msgbox(MyStr);
                Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr_Shifted,...
                    FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
                if ishandle(h_msgbox)
                    close(h_msgbox);
                end
                
                if IsDoCalForXAndY
                    %Same thing for Y shift
                    StageX_Meters = stage_x;
                    StageY_Meters = stage_y - (FOV_microns/4)/1000000; %note minus sign
                    
                    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
                    disp(MyStr);
                    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
                    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                        pause(.02)
                    end
                    wmBackLash
                    ImageFileNameStr_Shifted = [ImageFileNameStr(1:end-4), '_ShiftedInY.tif'];
                    
                    MyStr = sprintf('Acquiring image: %s', ImageFileNameStr_Shifted);
                    h_msgbox = msgbox(MyStr);
                    Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr_Shifted,...
                        FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
                    if ishandle(h_msgbox)
                        close(h_msgbox);
                    end
                end
                
            end
            
            %close(h_msgbox);
        end
        
    end
    
    
    
end