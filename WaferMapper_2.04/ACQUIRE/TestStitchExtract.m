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
    subplot(1,2,1);
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
    GrabWidth = 2000; %5000;
    GrabHeight = 2000; %5000;
    GrabImage = uint8(zeros(GrabWidth, GrabHeight, 3)); %this clears it as well
    
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
        
        %Get subimage from tile containing top left corner
        TopLeftCornerX_AbsoluteCoords = (GrabCenterX - GrabWidth/2);
        TopLeftCornerY_AbsoluteCoords = (GrabCenterY - GrabHeight/2);
        BottomRightCornerX_AbsoluteCoords = (GrabCenterX + GrabWidth/2);
        BottomRightCornerY_AbsoluteCoords = (GrabCenterY + GrabHeight/2);
        
        
        %get Top-Left SubRegion
        ExtendTopLeftByThisManyPixels = TileConfiguration.TileWidthInPixels * 0.03; % 3 percent overlap from first tile is enough to fill in "four corners missing region"
        [ImageSubRegion_FromTile_TL] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TopLeftCornerHitTile_RowNum,  TopLeftCornerHitTile_ColNum, ...
            TopLeftCornerX_AbsoluteCoords, TopLeftCornerY_AbsoluteCoords,...
            BottomRightCornerX_AbsoluteCoords, BottomRightCornerY_AbsoluteCoords, ExtendTopLeftByThisManyPixels);
        
        
        if  TopLeftCornerHitTile_ColNum+1 <= MaxCol
            [ImageSubRegion_FromTile_TR] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TopLeftCornerHitTile_RowNum,  TopLeftCornerHitTile_ColNum+1, ...
                TopLeftCornerX_AbsoluteCoords, TopLeftCornerY_AbsoluteCoords,...
                BottomRightCornerX_AbsoluteCoords, BottomRightCornerY_AbsoluteCoords, 0);
        else
            ImageSubRegion_FromTile_TR = [];
        end
        
        if TopLeftCornerHitTile_RowNum+1 <= MaxRow
            [ImageSubRegion_FromTile_BL] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TopLeftCornerHitTile_RowNum+1,  TopLeftCornerHitTile_ColNum, ...
                TopLeftCornerX_AbsoluteCoords, TopLeftCornerY_AbsoluteCoords,...
                BottomRightCornerX_AbsoluteCoords, BottomRightCornerY_AbsoluteCoords, 0);
        else
            ImageSubRegion_FromTile_BL = [];
        end
        
        if (TopLeftCornerHitTile_ColNum+1 <= MaxCol) && (TopLeftCornerHitTile_RowNum+1 <= MaxRow)
            [ImageSubRegion_FromTile_BR] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TopLeftCornerHitTile_RowNum+1,  TopLeftCornerHitTile_ColNum+1, ...
                TopLeftCornerX_AbsoluteCoords, TopLeftCornerY_AbsoluteCoords,...
                BottomRightCornerX_AbsoluteCoords, BottomRightCornerY_AbsoluteCoords, 0);
        else
            ImageSubRegion_FromTile_BR = [];
        end
        
        [TL_MaxR_Extended, TL_MaxC_Extended] = size(ImageSubRegion_FromTile_TL);
        TL_MaxR = TL_MaxR_Extended - ExtendTopLeftByThisManyPixels;
        TL_MaxC = TL_MaxC_Extended - ExtendTopLeftByThisManyPixels;
        [TR_MaxR, TR_MaxC] = size(ImageSubRegion_FromTile_TR);
        [BL_MaxR, BL_MaxC] = size(ImageSubRegion_FromTile_BL);
        [BR_MaxR, BR_MaxC] = size(ImageSubRegion_FromTile_BR);
        
        ColorIndexOf_TL = 1;
        ColorIndexOf_TR = 2;
        ColorIndexOf_BL = 3;
        ColorIndexOf_BR_1 = 2;
        ColorIndexOf_BR_2 = 3;
        GrabImage(1:TL_MaxR_Extended, 1:TL_MaxC_Extended, ColorIndexOf_TL) = 255-ImageSubRegion_FromTile_TL;
        GrabImage(1:TR_MaxR , (TL_MaxC+1):(TL_MaxC+TR_MaxC), ColorIndexOf_TR) = 255-ImageSubRegion_FromTile_TR;
        GrabImage((TL_MaxR+1):(TL_MaxR+BL_MaxR) , 1:BL_MaxC, ColorIndexOf_BL) = 255-ImageSubRegion_FromTile_BL;        
        GrabImage((TR_MaxR+1):(TR_MaxR+BR_MaxR) , (BL_MaxC+1):(BL_MaxC+BR_MaxC), ColorIndexOf_BR_1) = 255-ImageSubRegion_FromTile_BR; 
        GrabImage((TR_MaxR+1):(TR_MaxR+BR_MaxR) , (BL_MaxC+1):(BL_MaxC+BR_MaxC), ColorIndexOf_BR_2) = 255-ImageSubRegion_FromTile_BR; %repeat
        
        figure(300);
        imshow(GrabImage);
                
        GrabImageTrimmed = uint8(zeros(GrabWidth, GrabHeight, 3));
        GrabImageTrimmed(1:GrabHeight, 1:GrabWidth, :) = GrabImage(1:GrabHeight, 1:GrabWidth, :);
        
        figure(100);
        subplot(1,2,2);
        imshow(GrabImageTrimmed);
       
        
    end
    
end
