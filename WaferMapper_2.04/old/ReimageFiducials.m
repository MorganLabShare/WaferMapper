function ReimageFiducials(FiducialsDirectory, ReimageFiducialsDirectory, IsAutoFocus)
global GuiGlobalsStruct;

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','On');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','On');

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
        StageX_Meters = Info.StageX_Meters;
        StageY_Meters = Info.StageY_Meters;
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
        
        %************************************************************
        %Putting autofocus test code here just before user check
        PerformAutoFocusStigFocus;

        
        %Set Fibics FOV to the same as when original fiducial was acquired
        GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
        pause(0.5);
        GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Info.FOV_microns);
        pause(0.5);
        
        %Acquire new fiducial image
        ReimagedImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',ReimageFiducialsDirectory,FiducialNumStr(2:3));
        ReimagedDataFileNameStr = sprintf('%s\\Fiducial_%s.mat',ReimageFiducialsDirectory,FiducialNumStr(2:3));
        
        MyStr = sprintf('Acquiring %s, Please wait...',ReimagedImageFileNameStr);
        h_msgbox = msgbox(MyStr,'modal');
        
        StartTimeOfImageAcquire = tic;
        Fibics_AcquireImage_WithAutoRetakes(Info.ImageWidthInPixels,Info.ImageHeightInPixels,...
            Info.DwellTimeInMicroseconds,ReimagedImageFileNameStr);

        while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
            pause(.2);
        end
        disp(sprintf('Image Aquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
        
        pause(.2);
        if ishandle(h_msgbox)
            close(h_msgbox);
        end
        
        
        %Record any new info for this reimage (NOTE: THIS INCLUDES
        %RECORDING THE NEW STAGE POSITION DUE TO COORDINATE TRANSFORM)
        %Info.Num = Num;
        %Info.FOV_microns = FOV_microns;
        Info.Mag = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MAG');
        %Info.ImageWidthInPixels = ImageWidthInPixels;
        %Info.ImageHeightInPixels = ImageHeightInPixels;
        %Info.DwellTimeInMicroseconds = DwellTimeInMicroseconds;
        Info.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        Info.StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
        Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
        Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
        Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
        Info.ScanRot = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
        
        
        
        save(ReimagedDataFileNameStr,'Info');
        disp(sprintf('Saved %s', ReimagedDataFileNameStr));
        
        
        %display in figure
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                MyImage = imread(ReimagedImageFileNameStr, 'tif');
            catch MyException
                IsReadOK = false;
                %disp(sprintf('   imread exception: %s',MyException.identifier));
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