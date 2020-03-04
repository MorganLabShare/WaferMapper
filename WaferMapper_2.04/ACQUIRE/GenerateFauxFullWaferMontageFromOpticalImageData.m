%GenerateFauxFullWaferMontageFromOpticalImageData()

%global GuiGlobalsStruct;

INPUT_POINTS_Pixels = [];
BASE_POINTS_Meters = [];

NumOfOpticalFiducial = 1;
while(1)

    DataFileName = sprintf('%s\\OpticalToSEMFiducial_%0.5g.mat',GuiGlobalsStruct.OpticalWaferImageDirectory, NumOfOpticalFiducial);
    if exist(DataFileName, 'file')
        load(DataFileName);
        
        
        INPUT_POINTS_Pixels(NumOfOpticalFiducial,1) = Info.c_InOpticalImage;  %this is x
        INPUT_POINTS_Pixels(NumOfOpticalFiducial,2) = Info.r_InOpticalImage; %this is y
        BASE_POINTS_Meters(NumOfOpticalFiducial,1) = Info.stage_x;
        BASE_POINTS_Meters(NumOfOpticalFiducial,2) = Info.stage_y;
        
        disp(sprintf('#%0.5g: pixel(x,y)=(%0.5g,%0.5g), stage(x,y)=(%0.5g,%0.5g)', NumOfOpticalFiducial,...
            INPUT_POINTS_Pixels(NumOfOpticalFiducial,1), INPUT_POINTS_Pixels(NumOfOpticalFiducial,2),...
            BASE_POINTS_Meters(NumOfOpticalFiducial,1), BASE_POINTS_Meters(NumOfOpticalFiducial,2)));
        
        NumOfOpticalFiducial = NumOfOpticalFiducial + 1;
    else
        break;
    end
    
end

disp(' ');


%StageTransform is returned from function
OpticalToSEMStageTransform = cp2tform(INPUT_POINTS_Pixels,BASE_POINTS_Meters,'similarity'); %'nonreflective similarity'
disp('Computed OpticalToSEMStageTransform:');
OpticalToSEMStageTransform.tdata.T

disp(' ');


%check
[TotalNumOfOpticalFiducials , dummy] = size(INPUT_POINTS_Pixels);
for i = 1:TotalNumOfOpticalFiducials
    x = INPUT_POINTS_Pixels(i,1);
    y = INPUT_POINTS_Pixels(i,2);
    [x_prime, y_prime] = tformfwd(OpticalToSEMStageTransform,[x],[y]);
    
    disp(sprintf('#%0.5g: pixel(x,y)=(%0.5g,%0.5g), stage(x,y)=(%0.5g,%0.5g)', i,...
            x, y,...
            x_prime, y_prime));
        
end




%made up default params
    LeftStageX_mm = 109; %106;
    RightStageX_mm = 1; %4;
    TopStageY_mm = 1; %4;
    BottomStageY_mm = 109; %106;
    
    TileFOV_microns = 4000; 
    ImageWidthInPixels = 1000;
    ImageHeightInPixels = 1000; 
    DwellTimeInMicroseconds = 1; %not used
    
    NumTileColumns = ceil(1+ ((LeftStageX_mm - RightStageX_mm)/(TileFOV_microns/1000)))
    NumTileRows = ceil(1+ ((BottomStageY_mm - TopStageY_mm)/(TileFOV_microns/1000)))
    
    %Setup up params for FullWaferDownsampledDisplayArray (image that will be
    %displayed for main navigation functions)
    DownsampleFactor = 8;
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
    
    %populate this array with the optical image data
    OpticalImageFileNameStr = sprintf('%s\\FullWaferOpticalImage.tif',GuiGlobalsStruct.OpticalWaferImageDirectory);
    OpticalImage = imread(OpticalImageFileNameStr,'tif');
    [MaxY_Optical, MaxX_Optical] = size(OpticalImage);
    

    NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
    NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;
    
    DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
    DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            
    
    [MaxR, MaxC] = size(FullWaferDownsampledDisplayArray);
    for r = 1:MaxR
        disp(sprintf('r=%d',r));
        
        c_array = 1:MaxC;
        for i = 1:length(c_array)% %1:MaxC

            c = c_array(i);
            
            X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - c*DownSamplePixelWidth_mm;
            Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + r*DownSamplePixelHeight_mm;
            
            StageCoordArray(i,1) = X_Stage_mm/1000;
            StageCoordArray(i,2) = Y_Stage_mm/1000;
  
        end
        
        %[U,V] = TFORMINV(T,X,Y)
        %[x_optical, y_optical] = tforminv(OpticalToSEMStageTransform,[X_Stage_mm/1000],[Y_Stage_mm/1000]);
        OpticalCoordArray = tforminv(OpticalToSEMStageTransform,StageCoordArray);
        
        
        for i = 1:length(c_array)
            c = c_array(i);
            x_optical = OpticalCoordArray(i,1);
            y_optical = OpticalCoordArray(i,2);
            
            x_optical = round(x_optical);
            y_optical = round(y_optical);
            
            if (x_optical >= 1) && (y_optical >= 1) && (x_optical <= MaxX_Optical) && (y_optical <= MaxY_Optical)
                
                FullWaferDownsampledDisplayArray(r,c) = OpticalImage(y_optical, x_optical);
            end
            
        end
            
    end

    
    
    FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    MyStr = sprintf('Saving image file: %s',FullWaferImageFileNameStr);
    imwrite(FullWaferDownsampledDisplayArray/255, FullWaferImageFileNameStr,'tif');
    
    FullMapDataFileNameStr = sprintf('%s\\FullMapData.mat',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    MyStr = sprintf('Saving FullMapData.mat file: %s',FullMapDataFileNameStr);
    disp(MyStr);
    save(FullMapDataFileNameStr,'FullMapData');
    
    %Reload the FullMapImage.tif and assign to global variable
    FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    disp(sprintf('Loading image file: %s',FullWaferImageFileNameStr));
    GuiGlobalsStruct.FullWaferDownsampledDisplayImage = imread(FullWaferImageFileNameStr,'tif');