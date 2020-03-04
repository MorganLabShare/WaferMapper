function ReimageFiducials(FiducialsDirectory, ReimageFiducialsDirectory, IsAutoFocus)
global GuiGlobalsStruct;

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);

%code to correct for offset between sigma and merlin mapped wafers
StageOffsetForLowResFiducialTaking_X_Meters = 0;
StageOffsetForLowResFiducialTaking_Y_Meters = 0;
if ~isfield(GuiGlobalsStruct,'StageTransform')   %only gets used if this is the low res fiducial take since it is cleared at call of auto reload
    if isfield(GuiGlobalsStruct, 'StageOffsetForLowResFiducialTaking_X_Meters')
        StageOffsetForLowResFiducialTaking_X_Meters = GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_X_Meters;
        StageOffsetForLowResFiducialTaking_Y_Meters = GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_Y_Meters;
    end
end

h_fig_image = figure();

FiducialNum = 1;
while true
    FiducialNumStr = sprintf('%d',(100 + FiducialNum));
    ImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',FiducialsDirectory,FiducialNumStr(2:3));
    DataFileNameStr = sprintf('%s\\Fiducial_%s.mat',FiducialsDirectory,FiducialNumStr(2:3));
    
    if exist(ImageFileNameStr, 'file')
        
        %load info for this fiducial
        disp(sprintf('Loading %s', DataFileNameStr));
        load(DataFileNameStr,'Info');  

        %Set Fibics FOV to the same as when original fiducial was acquired
        GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
        
        %The idea here is to always modify an existing transformation and
        %scan rotation. If these do not exist yet then create as unity.
        StageX_Meters = Info.StageX_Meters + StageOffsetForLowResFiducialTaking_X_Meters;
        StageY_Meters = Info.StageY_Meters + StageOffsetForLowResFiducialTaking_Y_Meters;
        if isfield(GuiGlobalsStruct,'StageTransform')
            if ~isempty(GuiGlobalsStruct.StageTransform)
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
            else
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
                GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = 0; 
            end
        else
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
            GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = 0;     
            
            
        end
        
        
        
        
        %Move stage to this stored fiducial position
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
        
        if IsAutoFocus
            %************************************************************
            %Putting autofocus test code here just before user check
            
            %PerformAutoFocus;
            %NOTE: I AM NOT CALLING THE REGULAR AUTOFOCUS FUNCTION HERE BECAUSE
            %      I NEED TO FOCUS AT LOWER MAG ON THE TEM GRID FIDUCIALS
            %*** START: This sequence is desigend to release the SEM from Fibics control
            CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
            GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
            pause(1);
            GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
            pause(1);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
            pause(1);
            %*** END
            
            %*** Auto focus
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',300); %NOTE LOW MAG
            pause(1);
            GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
            pause(1);
            while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
                pause(.5);
                disp('Auto Focusing...');
            end
            pause(2);
            
        end

        
        %Set Fibics FOV to the same as when original fiducial was acquired
%         GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
%         pause(0.5);
%         GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
%         pause(0.5);
        %NOTE: I WILL NOT DO THIS FOV RESET BUT INSTEAD RESET TO ORIGINAL MAG
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',Info.Mag);
        pause(0.5);
        
        %Acquire new fiducial image
        ReimagedImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',ReimageFiducialsDirectory,FiducialNumStr(2:3));
        ReimagedDataFileNameStr = sprintf('%s\\Fiducial_%s.mat',ReimageFiducialsDirectory,FiducialNumStr(2:3));
        
        MyStr = sprintf('Acquiring %s, Please wait...',ReimagedImageFileNameStr);
        h_msgbox = msgbox(MyStr,'modal');
        
        StartTimeOfImageAcquire = tic;
        
        %Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
        %     FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
        IsDoAutoRetakeIfNeeded = false;
        IsMagOverride = false; %KH changed from true on 10-18-2011 %true; %NOTE: WE ARE USING ORIGINAL MAG AND NOT COUNTING ON FIBICS FOV
        MagForOverride = Info.Mag;
        WaferNameStr = '';
        LabelStr = '';
        Fibics_AcquireImage(Info.ImageWidthInPixels, Info.ImageHeightInPixels, Info.DwellTimeInMicroseconds, ReimagedImageFileNameStr,...
            Info.FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);

        
        
        
        %old way
        %Fibics_AcquireImage_WithAutoRetakes(Info.ImageWidthInPixels,Info.ImageHeightInPixels,...
        %             Info.DwellTimeInMicroseconds,ReimagedImageFileNameStr);

        while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
            pause(.2);
        end
        disp(sprintf('Image Aquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
        
        pause(.2);
        if ishandle(h_msgbox)
            close(h_msgbox);
        end
 
        
        
        %display in figure
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                MyImage = imread(ReimagedImageFileNameStr, 'tif');
                
                %%% If we are using a secondary detector then we need to
                %%% invert image (original assumed take with backscatter
                %%% detector with -,-,-,- set for the quadrants.
                DetectorStr = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_DETECTOR_TYPE');
%                 if strcmp(DetectorStr, 'InLens') || strcmp(DetectorStr, 'SE2')
%                     IsNeedToInvert = true;
%                 else
%                     IsNeedToInvert = false;
%                 end
%                 if IsNeedToInvert
%                     MyImage = 255-MyImage; 
%                     %overwrite original file with inverted contrast
%                     imwrite(MyImage,ReimagedImageFileNameStr, 'tif');
%                 end
                %%% End invert code
                
            catch MyException
                IsReadOK = false;
                pause(.1);
            end
        end
        
        figure(h_fig_image);
        imshow(MyImage,[0,255]);
        
        
        FiducialNum = FiducialNum + 1;
        
    else
        break;
    end
    
end

if ishandle(h_fig_image)
   close(h_fig_image); 
end