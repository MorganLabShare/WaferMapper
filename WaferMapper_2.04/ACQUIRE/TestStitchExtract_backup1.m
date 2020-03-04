%test stitch extract
clear all;
close all;

%pick the montage directory
MontageDir = uigetdir('F:\JM_YR1C_Data\w010_Sec1_Montage','Pick the montage directory');
if MontageDir == 0
    return;
end

%read the tile configuration file and tile size
[TileConfiguration] = ReadTileConfigration(MontageDir);


%main GUI loop
while true
    
    %clear the imput window
    figure(100);
    subplot(1,3,1);
    cla;
    set(gca, 'YDir', 'reverse');
    axis equal;
    
    
    %draw the outlines of all tiles
    Width = TileConfiguration.TileWidthInPixels;
    Height = TileConfiguration.TileHeightInPixels;
    [MaxRow, MaxCol] = size(TileConfiguration.TileArray);
    for RowNum = 1:MaxRow
        for ColNum = 1:MaxCol
            CenterX = TileConfiguration.TileArray(RowNum, ColNum).XCoord;
            CenterY = TileConfiguration.TileArray(RowNum, ColNum).YCoord;
            
            DrawBox(CenterX, CenterY, Width, Height, [0 0 1]);
        end
    end
    
    %redraw the old box for reference
    if exist('GrabCenterX', 'var')
        DrawBox(GrabCenterX, GrabCenterY, GrabWidth, GrabHeight, [0.5 0.5 0.5]);
    end
    
    %get user point
    [x, y, button] = ginput(1);
    if button == 27 %'Esc'
        disp('HERE 2');
        break; %break out of pick loop if user presses esc
    end
    GrabCenterX = x; %10000;
    GrabCenterY = y; %10000;
    GrabWidth = 5000;
    GrabHeight = 5000;
    GrabImage = uint8(zeros(GrabWidth, GrabHeight)); %this clears it as well
    
    %draw this box on the screen
    DrawBox(GrabCenterX, GrabCenterY, GrabWidth, GrabHeight, [1 0 0]);
    
    
    %determine what tile the top left corner is in
    TopLeftCornerX = GrabCenterX - GrabWidth/2;
    TopLeftCornerY = GrabCenterY - GrabHeight/2;
    TopLeftCornerHitTile_RowNum = 0;
    TopLeftCornerHitTile_ColNum = 0;
    IsFoundHit = false;
    for RowNum = 1:MaxRow
        for ColNum = 1:MaxCol
            MinX = TileConfiguration.TileArray(RowNum, ColNum).MinX;
            MaxX = TileConfiguration.TileArray(RowNum, ColNum).MaxX;
            MinY = TileConfiguration.TileArray(RowNum, ColNum).MinY;
            MaxY = TileConfiguration.TileArray(RowNum, ColNum).MaxY; 
            
            if (TopLeftCornerX >= MinX) && (TopLeftCornerX < MaxX) && (TopLeftCornerY >= MinY) && (TopLeftCornerY < MaxY)
                TopLeftCornerHitTile_RowNum = RowNum;
                TopLeftCornerHitTile_ColNum = ColNum;
                IsFoundHit = true;
                break;
            end
            
        end
        if IsFoundHit
            break;
        end
    end
    
    if ~IsFoundHit
        disp('error - out of bounds');
        subplot(1,2,2);
        cla;
    else
        disp(sprintf('TopLeftCornerHitTile = (%d, %d)',TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum));
    end
    
    
    if IsFoundHit
        TopLeftPixelInTile_X = ( (GrabCenterX - GrabWidth/2) - TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).XCoord) + ...
            TileConfiguration.TileWidthInPixels/2;
        TopLeftPixelInTile_Y = ( (GrabCenterY - GrabHeight/2) - TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).YCoord) + ...
            TileConfiguration.TileHeightInPixels/2;
        
        
        BottomRightPixelInTile_X_InGlobalCoords = (GrabCenterX + GrabWidth/2);
        if BottomRightPixelInTile_X_InGlobalCoords > TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).MaxX
            BottomRightPixelInTile_X_InGlobalCoords = TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).MaxX;
        end
        BottomRightPixelInTile_X = (BottomRightPixelInTile_X_InGlobalCoords - TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).XCoord)+ ...
            TileConfiguration.TileWidthInPixels/2;
        
        BottomRightPixelInTile_Y_InGlobalCoords = (GrabCenterY + GrabHeight/2);
        if BottomRightPixelInTile_Y_InGlobalCoords > TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).MaxY
            BottomRightPixelInTile_Y_InGlobalCoords = TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).MaxY;
        end
        BottomRightPixelInTile_Y = (BottomRightPixelInTile_Y_InGlobalCoords - TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).YCoord)+ ...
            TileConfiguration.TileHeightInPixels/2;
        
        
        
        
        disp(sprintf('TopLeftPixelInTile_X = %0.8g', TopLeftPixelInTile_X));
        disp(sprintf('TopLeftPixelInTile_Y = %0.8g', TopLeftPixelInTile_Y));
        disp(sprintf('BottomRightPixelInTile_X = %0.8g', BottomRightPixelInTile_X));
        disp(sprintf('BottomRightPixelInTile_Y = %0.8g', BottomRightPixelInTile_Y));
        
        %test
        TopLeftCornerX = (GrabCenterX - GrabWidth/2);
        TopLeftCornerY = (GrabCenterY - GrabHeight/2);
        BottomRightCornerX = (GrabCenterX + GrabWidth/2);
        BottomRightCornerY = (GrabCenterY + GrabHeight/2);
        [ImageSubRegion] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TopLeftCornerHitTile_RowNum,  TopLeftCornerHitTile_ColNum, ...
            TopLeftCornerX, TopLeftCornerY, BottomRightCornerX, BottomRightCornerY);
        
        %'PixelRegion'    {ROWS, COLS}
        MyImage = imread(TileConfiguration.TileArray(TopLeftCornerHitTile_RowNum, TopLeftCornerHitTile_ColNum).FullPathName, 'tif', ...
            'PixelRegion', ...
            {[round(TopLeftPixelInTile_Y), round(BottomRightPixelInTile_Y)], ...
            [round(TopLeftPixelInTile_X), round(BottomRightPixelInTile_X)]}  );
        [MyImage_MaxR, MyImage_MaxC] = size(MyImage);
        GrabImage(1:MyImage_MaxR, 1:MyImage_MaxC) = MyImage;
        
     
        
        figure(100);
        subplot(1,3,2);
        imshow(GrabImage);
        
        subplot(1,3,3);
        imshow(ImageSubRegion);
    end
    
end
