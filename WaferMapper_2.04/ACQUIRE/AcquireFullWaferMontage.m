%Acquire Full Wafer Montage

AnswerName = questdlg('Do you want to just create a faux wafer map from an optical image?', ...
    'Question', ...
    'Yes', 'No', 'Yes');

IsBypassAndCreatFauxMap = false;
if strcmp(AnswerName, 'Yes')
    IsBypassAndCreatFauxMap = true;
    
    GuiGlobalsStruct.OpticalWaferImageDirectory = sprintf('%s\\OpticalWaferImageDirectory', GuiGlobalsStruct.WaferDirectory);
    LoadOpticalWaferImage(handles);
    
    GenerateFauxFullWaferMontageFromOpticalImageData
    
    
    axes(handles.Axes_FullWaferDisplay);
    imshow(FullWaferDownsampledDisplayArray,[0,255]);


    
else %~IsBypassAndCreatFauxMap This is the regular code
    
    uiwait(msgbox('WARNING!!! Make sure the backscatter detector is adjusted so as NOT to have WHITE CORNERS!!','modal'));
    
    
    %Note: This assumes that Zeiss and Fibics APIs are already setup. Check
    %this before this function is called.
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',25);
    uiwait(msgbox('I just set scanrot = 0.0 degrees and Magnification = 25x. Please adjust contrast, brightness, and focus, then press OK.','modal'));
    
    uiwait(msgbox('Use stage rotation (NOT scan rotation) to get strips on wafer close to vertical, then press OK.','modal'));
    
    
    start = tic
    %*** Get TOP Extent ***
    MinAllowed_TopStageY_mm = 4;
    MaxAllowed_TopStageY_mm = 30;
    Default_TopStageY_mm = 12;
    
    %% Use default wafer positions
    AnswerUseDefault = questdlg('Use default wafer positions?', ...
    'Question', ...
    'Yes', 'No', 'Yes');
    
    if strcmp(AnswerUseDefault,'Yes') %use defaults
        RightStageX_mm = 19;
        BottomStageY_mm = 114;
        TopStageY_mm = 17;
        LeftStageX_mm =106;
    else
        
    %% Get user defined borders
    MyAnswer = inputdlg('Leave blank and use joystick to move stage to TOP of desired montage and press OK (or enter value in mm and press OK)');
    if ~isempty(MyAnswer) %is empty if user canceled
        MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
    else
        MyAnswer2Num = NaN;
    end
    if isnan(MyAnswer2Num) %if NaN then use stage coordinates
        TopStageY_mm = (1000*GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')); 
        
    elseif (MyAnswer2Num > MinAllowed_TopStageY_mm) && (MyAnswer2Num < MaxAllowed_TopStageY_mm)
        TopStageY_mm = MyAnswer2Num;
    else
        MyStr = sprintf('TopStageY_mm must be between %0.5g and %0.5g. Setting to default %0.5g',...
            MinAllowed_TopStageY_mm, MaxAllowed_TopStageY_mm, Default_TopStageY_mm);
        uiwait(msgbox(MyStr,'modal'));
        TopStageY_mm = Default_TopStageY_mm;
    end
    MyStr = sprintf('TopStageY_mm = %0.5g',TopStageY_mm);
    disp(MyStr);
    
    
    %*** Get BOTTOM Extent ***
    MinAllowed_BottomStageY_mm = 80;
    MaxAllowed_BottomStageY_mm = 116;
    Default_BottomStageY_mm = 108;
    
    MyAnswer = inputdlg('Leave blank and use joystick to move stage to BOTTOM of desired montage and press OK (or enter value in mm and press OK)');
    if ~isempty(MyAnswer) %is empty if user canceled
        MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
    else
        MyAnswer2Num = NaN;
    end
    
    if isnan(MyAnswer2Num) %if NaN then use stage coordinates
        BottomStageY_mm = (1000*GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')); 
        
    elseif (MyAnswer2Num > MinAllowed_BottomStageY_mm) && (MyAnswer2Num < MaxAllowed_BottomStageY_mm)
        BottomStageY_mm = MyAnswer2Num;
    else
        MyStr = sprintf('BottomStageY_mm must be between %0.5g and %0.5g. Setting to default %0.5g',...
            MinAllowed_BottomStageY_mm, MaxAllowed_BottomStageY_mm, Default_BottomStageY_mm);
        uiwait(msgbox(MyStr,'modal'));
        BottomStageY_mm = Default_BottomStageY_mm;
    end
    MyStr = sprintf('BottomStageY_mm = %0.5g',BottomStageY_mm);
    disp(MyStr);
    
    
    %*** Get LEFT Extent ***
    MinAllowed_LeftStageX_mm = 80;
    MaxAllowed_LeftStageX_mm = 116;
    Default_LeftStageX_mm = 110;
    
    MyAnswer = inputdlg('Leave blank and use joystick to move stage to LEFT of desired montage and press OK (or enter value in mm and press OK)');
    if ~isempty(MyAnswer) %is empty if user canceled
        MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
    else
        MyAnswer2Num = NaN;
    end
    
    if isnan(MyAnswer2Num) %if NaN then use stage coordinates
        LeftStageX_mm = (1000*GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X')); 
        
    elseif (MyAnswer2Num > MinAllowed_LeftStageX_mm) && (MyAnswer2Num < MaxAllowed_LeftStageX_mm)
        LeftStageX_mm = MyAnswer2Num;
    else
        MyStr = sprintf('LeftStageX_mm must be between %0.5g and %0.5g. Setting to default %0.5g',...
            MinAllowed_LeftStageX_mm, MaxAllowed_LeftStageX_mm, Default_LeftStageX_mm);
        uiwait(msgbox(MyStr,'modal'));
        LeftStageX_mm = Default_LeftStageX_mm;
    end
    MyStr = sprintf('LeftStageX_mm = %0.5g',LeftStageX_mm);
    disp(MyStr);
    
    
    
    %*** Get RIGHT Extent ***
    MinAllowed_RightStageX_mm = 4;
    MaxAllowed_RightStageX_mm = 60;
    Default_RightStageX_mm = 26;
    
    MyAnswer = inputdlg('Leave blank and use joystick to move stage to RIGHT of desired montage and press OK (or enter value in mm and press OK)');
    if ~isempty(MyAnswer) %is empty if user canceled
        MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
    else
        MyAnswer2Num = NaN;
    end
    
    if isnan(MyAnswer2Num) %if NaN then use stage coordinates
        RightStageX_mm = (1000*GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X'));
        
    elseif (MyAnswer2Num > MinAllowed_RightStageX_mm) && (MyAnswer2Num < MaxAllowed_RightStageX_mm)
        RightStageX_mm = MyAnswer2Num;
    else
        MyStr = sprintf('RightStageX_mm must be between %0.5g and %0.5g. Setting to default %0.5g',...
            MinAllowed_RightStageX_mm, MaxAllowed_RightStageX_mm, Default_RightStageX_mm);
        uiwait(msgbox(MyStr,'modal'));
        RightStageX_mm = Default_RightStageX_mm;
    end
    MyStr = sprintf('RightStageX_mm = %0.5g',RightStageX_mm);
    disp(MyStr);
    
    end
    
    %Set up Fibics for 4mm wide images at 4micron pixel size 1000x1000 pixels
    TileFOV_microns = GuiGlobalsStruct.WaferParameters.TileFOV_microns; %4000;
    %GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(TileFOV_microns); %done
    %below in Fibics_Acquire function
    ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.TileWidth_pixels; %1000; % GuiGlobalsStruct.WaferParameters.TileWidth_pixels; %1000;
    ImageHeightInPixels = GuiGlobalsStruct.WaferParameters.TileWidth_pixels; %1000; %GuiGlobalsStruct.WaferParameters.TileWidth_pixels; %;
    DwellTimeInMicroseconds = GuiGlobalsStruct.WaferParameters.TileDwellTime_microseconds; %1; %GuiGlobalsStruct.WaferParameters.TileDwellTime_microseconds; %0.5;
    
    NumTileColumns = ceil(1+ ((LeftStageX_mm - RightStageX_mm)/(TileFOV_microns/1000)))
    NumTileRows = ceil(1+ ((BottomStageY_mm - TopStageY_mm)/(TileFOV_microns/1000)))
    
    %Setup up params for FullWaferDownsampledDisplayArray (image that will be
    %displayed for main navigation functions)
    DownsampleFactor = GuiGlobalsStruct.WaferParameters.DownSampleFactorForFullWaferOverviewImage; %8;
    DownsampledTileWidthInPixels = ImageWidthInPixels/DownsampleFactor;
    DownsampledTileHeightInPixels = ImageHeightInPixels/DownsampleFactor;
    FullWaferDownsampledDisplayArray = zeros(NumTileRows*DownsampledTileHeightInPixels,...
        NumTileColumns*DownsampledTileWidthInPixels);
    
    
    
    %Save all crucial params in FullMapData.mat
    FullMapData.TopStageY_mm = TopStageY_mm;
    FullMapData.LeftStageX_mm = LeftStageX_mm;
    FullMapData.NumTileColumns = NumTileColumns;
    FullMapData.NumTileRows = NumTileRows;
    FullMapData.ImageWidthInPixels = ImageWidthInPixels;
    FullMapData.ImageHeightInPixels = ImageHeightInPixels;
    FullMapData.TileFOV_microns = TileFOV_microns;
    FullMapData.DwellTimeInMicroseconds = DwellTimeInMicroseconds;
    FullMapData.DownsampleFactor = DownsampleFactor;
    
    GuiGlobalsStruct.FullMapData = FullMapData;
    
    MyImageDownsampled_BlankWithBorders = 255*ones(DownsampledTileHeightInPixels, DownsampledTileWidthInPixels);
    MyImageDownsampled_BlankWithBorders(:,1:5) = 0;
    MyImageDownsampled_BlankWithBorders(:,(end-4):end) = 0;
    MyImageDownsampled_BlankWithBorders(1:5,:) = 0;
    MyImageDownsampled_BlankWithBorders((end-4):end,:) = 0;
    
    for RowIndex=1:NumTileRows
        for ColumnIndex=1:NumTileColumns
            FullWaferDownsampledDisplayArray(((RowIndex-1)*DownsampledTileHeightInPixels+1):(RowIndex*DownsampledTileHeightInPixels),...
                ((ColumnIndex-1)*DownsampledTileWidthInPixels+1):(ColumnIndex*DownsampledTileWidthInPixels))...
                = MyImageDownsampled_BlankWithBorders;
        end
    end
    
    
    MyStr = sprintf('MONTAGE PARAMETERS:\nTopStageY_mm = %0.5g\n BottomStageY_mm = %0.5g\n LeftStageX_mm = %0.5g\n RightStageX_mm = %0.5g\n',TopStageY_mm, BottomStageY_mm, LeftStageX_mm, RightStageX_mm);
    uiwait(msgbox(MyStr,'modal'));
    
    
    
    
    
    
    
    %********************* Start actual montage commands *************************
    
    %%get current stage position so we can only vary x and y
    disp('Getting stage position');
    stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
    stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
    stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g)'...
        ,stage_x,stage_y,stage_z,stage_t,stage_r, stage_m);
    disp(MyStr);
    disp(' ');
    
    if 1 == GuiGlobalsStruct.WaferParameters.PerformBacklashDuringFullWaferMontage
        disp('Turning stage backlash on in X and Y');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
    else
        disp('Turning stage backlash off in X and Y');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','Off');
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','Off');
    end
    
    
    StartTimeOfMontage = tic;
    
    
    StageY_Meters = TopStageY_mm/1000;
    for RowIndex=1:NumTileRows
        RowStr = sprintf('%d',1000+RowIndex);
        
        StageX_Meters = LeftStageX_mm/1000;
        for ColumnIndex=1:NumTileColumns
            ColumnStr = sprintf('%d',1000+ColumnIndex);
            
            
            StartTimeOfStageMove = tic;
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            disp(MyStr);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            disp(sprintf('Stage Move Duration = %0.7g seconds',toc(StartTimeOfStageMove)));
            
            StartTimeOfImageAcquire = tic;
            FileNameStr = sprintf('%s\\TileR%s_C%s.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory,RowStr(2:4),ColumnStr(2:4));
            MyStr = sprintf('Acquiring %s',FileNameStr);
            disp(MyStr);
            %         Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,...
            %             DwellTimeInMicroseconds,FileNameStr);
            IsDoAutoRetakeIfNeeded = true; %retake if full white or black image
            IsMagOverride = false;
            MagForOverride = -1;
            WaferNameStr = '';
            LabelStr = '';
            Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
                TileFOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
            
            disp(sprintf('Image Aquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
            
            StartTimeOfImageProcessing = tic;
            IsReadOK = false;
            while ~IsReadOK
                IsReadOK = true;
                try
                    MyImage = imread(FileNameStr);
                catch MyException
                    IsReadOK = false;
                    %disp(sprintf('   imread exception: %s',MyException.identifier));
                    pause(.1);
                end
            end
            MyImageDownsampled = imresize(MyImage,[DownsampledTileHeightInPixels, DownsampledTileWidthInPixels],'bilinear');
            
            FullWaferDownsampledDisplayArray(((RowIndex-1)*DownsampledTileHeightInPixels+1):(RowIndex*DownsampledTileHeightInPixels),...
                ((ColumnIndex-1)*DownsampledTileWidthInPixels+1):(ColumnIndex*DownsampledTileWidthInPixels))...
                = MyImageDownsampled;
            axes(handles.Axes_FullWaferDisplay);
            imshow(FullWaferDownsampledDisplayArray,[0,255]);
            disp(sprintf('Image Processing Duration = %0.7g seconds',toc(StartTimeOfImageProcessing)));
            
            StageX_Meters = StageX_Meters - TileFOV_microns/1000000;
        end
        
        StageY_Meters = StageY_Meters + TileFOV_microns/1000000;
        toc(start)
    end
    
    disp(sprintf('Full Montage Duration = %0.7g seconds',toc(StartTimeOfMontage)));
    
    
    
    FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    MyStr = sprintf('Saving image file: %s',FullWaferImageFileNameStr);
    imwrite(FullWaferDownsampledDisplayArray/255, FullWaferImageFileNameStr,'tif')
    
    FullMapDataFileNameStr = sprintf('%s\\FullMapData.mat',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    MyStr = sprintf('Saving FullMapData.mat file: %s',FullMapDataFileNameStr);
    disp(MyStr);
    safeSave(FullMapDataFileNameStr,'FullMapData');
    
    %Reload the FullMapImage.tif and assign to global variable
    FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    disp(sprintf('Loading image file: %s',FullWaferImageFileNameStr));
    GuiGlobalsStruct.FullWaferDownsampledDisplayImage = imread(FullWaferImageFileNameStr,'tif');
end

