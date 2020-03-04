%AcquireOverviewImages
global GuiGlobalsStruct;

FOV_microns = GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns; %4096; % 4096;
%GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(SectionOveriewFOV_microns);
ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels; %4096; %4096;
ImageHeightInPixels = GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels; %4096; %4096;
DwellTimeInMicroseconds = GuiGlobalsStruct.WaferParameters.SectionOverviewDwellTime_microseconds; %1; %KH CHANGE BACK TO 1

%IsDoAutoFocus = true; %true; %KH CHANGE BACK TO TRUE

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);

GuiGlobalsStruct.IsDisplayCurrentStagePosition = false;
set(handles.DisplaySectionCrosshairs_ToolbarButton,'state','on');
UpdateFullWaferDisplay(handles);

uiwait(msgbox('Section locations to be imaged are displayed. Check stig and focus (will perform focus on every section) and contrast, then press OK to proceed.'));

start = tic;

%uiwait(msgbox('WARNING CODE WAS MODIFIED TO TAKE EVERY 10th SECTION!!!'));

for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
    
    if(~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted)
        ImageFileNameStr = sprintf('%s\\SectionOverview_%s.tif',GuiGlobalsStruct.SectionOverviewsDirectory,GuiGlobalsStruct.CoarseSectionList(i).Label);
        %DataFileNameStr = sprintf('%s\\SectionOverview_%s.mat',GuiGlobalsStruct.SectionOverviewsDirectory,GuiGlobalsStruct.CoarseSectionList(i).Label);
        
        if exist(ImageFileNameStr,'file') %This allows for simple retakes - just delete the bad image and run again
            MyStr = sprintf('%s exists. SKIPPING.', ImageFileNameStr);
            disp(MyStr);
        else
            cpeak = GuiGlobalsStruct.CoarseSectionList(i).cpeak;
            rpeak = GuiGlobalsStruct.CoarseSectionList(i).rpeak;
            
            
            
            NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
            NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;
            
            DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            
            
            X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - cpeak*DownSamplePixelWidth_mm 
            Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + rpeak*DownSamplePixelHeight_mm 
            '!!added ane to stage target'
            
            StageX_Meters = X_Stage_mm/1000;
            StageY_Meters = Y_Stage_mm/1000;
            
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
            
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            disp(MyStr);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            %Acquire image
            if GuiGlobalsStruct.WaferParameters.PerformAutofocus 
                PerformAutoFocus; %PerformAutoFocusStigFocus;
                pause(2);
            end
%             pause(1);
%             GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(SectionOveriewFOV_microns);
            
            
            MyStr = sprintf('Acquiring %s, Please wait...',ImageFileNameStr);
            h_msgbox = msgbox(MyStr,'modal');
            
            StartTimeOfImageAcquire = tic;
            %             Fibics_AcquireImage_WithAutoRetakes(SectionOveriewImageWidthInPixels,SectionOveriewImageHeightInPixels,...
            %                 SectionOveriewDwellTimeInMicroseconds,ImageFileNameStr);
            
            %Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
            %     FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
            IsDoAutoRetakeIfNeeded = true; %retake if full white or black image
            IsMagOverride = false;
            MagForOverride = -1;
            WaferNameStr = '';
            LabelStr = GuiGlobalsStruct.CoarseSectionList(i).Label;
            Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
            
            disp(sprintf('Image Acquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
            
            IsReadOK = false;
            while ~IsReadOK
                IsReadOK = true;
                try
                    MyImage = imread(ImageFileNameStr, 'tif');
                catch MyException
                    IsReadOK = false;
                    pause(.1);
                end
            end
            
            axes(handles.Axes_SectionOverviewDisplay);
            imshow(MyImage, [0,255]);
            
            %Note: I am switching from a struct called SectionOveriewInfo
            %to one call simply Info stored automatically by
            %Fibics_AcquireImage() function
%             SectionOveriewInfo.Label = GuiGlobalsStruct.CoarseSectionList(i).Label;
%             SectionOveriewInfo.FOV_microns = SectionOveriewFOV_microns;
%             SectionOveriewInfo.ImageWidthInPixels = SectionOveriewImageWidthInPixels;
%             SectionOveriewInfo.ImageHeightInPixels = SectionOveriewImageHeightInPixels;
%             SectionOveriewInfo.DwellTimeInMicroseconds = SectionOveriewDwellTimeInMicroseconds;
%             SectionOveriewInfo.StageX_Meters = StageX_Meters;
%             SectionOveriewInfo.StageY_Meters = StageY_Meters;
%             SectionOveriewInfo.stage_z = stage_z;
%             SectionOveriewInfo.stage_t = stage_t;
%             SectionOveriewInfo.stage_r = stage_r;
%             SectionOveriewInfo.stage_m = stage_m;
%             
%             
%             save(DataFileNameStr,'SectionOveriewInfo');
%             disp(sprintf('Saved %s', DataFileNameStr));
            
           try close(h_msgbox);end
            
            axes(handles.Axes_FullWaferDisplay);
            %Mark on display as completed
            h1 = line([cpeak-40, cpeak+40],[rpeak, rpeak]);
            h2 = line([cpeak, cpeak],[rpeak-40, rpeak+40]);
            set(h1,'Color',[0 0 1]);
            set(h2,'Color',[0 0 1]);
        end
        
    end
    toc(start)
end


