function [ImageSubRegion] = GetSubRegionOfTileGivenAbsoluteMontageCoords(TileConfiguration, TileRowNum,  TileColNum, TopLeftCornerX, TopLeftCornerY, BottomRightCornerX, BottomRightCornerY, ExtendBottomRightCornerByThisManyPixels)

disp(sprintf('In GetSubRegionOfTileGivenAbsoluteMontageCoords. TileRowNum = %d, TileColNum = %d', TileRowNum, TileColNum));

TopLeftPixelInTile_X_InGlobalCoords = TopLeftCornerX;
if TopLeftPixelInTile_X_InGlobalCoords < TileConfiguration.TileArray(TileRowNum, TileColNum).MinX
    TopLeftPixelInTile_X_InGlobalCoords = TileConfiguration.TileArray(TileRowNum, TileColNum).MinX;
end
TopLeftPixelInTile_X = ( TopLeftPixelInTile_X_InGlobalCoords - TileConfiguration.TileArray(TileRowNum, TileColNum).XCoord) + ...
    TileConfiguration.TileWidthInPixels/2;


TopLeftPixelInTile_Y_InGlobalCoords = TopLeftCornerY;
if TopLeftPixelInTile_Y_InGlobalCoords < TileConfiguration.TileArray(TileRowNum, TileColNum).MinY
    TopLeftPixelInTile_Y_InGlobalCoords = TileConfiguration.TileArray(TileRowNum, TileColNum).MinY;
end
TopLeftPixelInTile_Y = ( TopLeftPixelInTile_Y_InGlobalCoords - TileConfiguration.TileArray(TileRowNum, TileColNum).YCoord) + ...
    TileConfiguration.TileHeightInPixels/2;


BottomRightPixelInTile_X_InGlobalCoords = BottomRightCornerX;
if BottomRightPixelInTile_X_InGlobalCoords > TileConfiguration.TileArray(TileRowNum, TileColNum).MaxX
    BottomRightPixelInTile_X_InGlobalCoords = TileConfiguration.TileArray(TileRowNum, TileColNum).MaxX;
end
BottomRightPixelInTile_X = (BottomRightPixelInTile_X_InGlobalCoords - TileConfiguration.TileArray(TileRowNum, TileColNum).XCoord)+ ...
    TileConfiguration.TileWidthInPixels/2;

BottomRightPixelInTile_Y_InGlobalCoords = BottomRightCornerY;
if BottomRightPixelInTile_Y_InGlobalCoords > TileConfiguration.TileArray(TileRowNum, TileColNum).MaxY
    BottomRightPixelInTile_Y_InGlobalCoords = TileConfiguration.TileArray(TileRowNum, TileColNum).MaxY;
end
BottomRightPixelInTile_Y = (BottomRightPixelInTile_Y_InGlobalCoords - TileConfiguration.TileArray(TileRowNum, TileColNum).YCoord)+ ...
    TileConfiguration.TileHeightInPixels/2;




disp(sprintf('TopLeftPixelInTile_X = %0.8g', TopLeftPixelInTile_X));
disp(sprintf('TopLeftPixelInTile_Y = %0.8g', TopLeftPixelInTile_Y));
disp(sprintf('BottomRightPixelInTile_X = %0.8g', BottomRightPixelInTile_X));
disp(sprintf('BottomRightPixelInTile_Y = %0.8g', BottomRightPixelInTile_Y));

if (TopLeftPixelInTile_X < 1) || (TopLeftPixelInTile_X > TileConfiguration.TileWidthInPixels)
    ImageSubRegion = [];
elseif (TopLeftPixelInTile_Y < 1) || (TopLeftPixelInTile_Y > TileConfiguration.TileHeightInPixels)
    ImageSubRegion = [];
elseif (BottomRightPixelInTile_X < 1) || (BottomRightPixelInTile_X > TileConfiguration.TileWidthInPixels)
    ImageSubRegion = [];
elseif (BottomRightPixelInTile_Y < 1) || (BottomRightPixelInTile_Y > TileConfiguration.TileHeightInPixels)
    ImageSubRegion = [];
else
    %'PixelRegion'    {ROWS, COLS}
    ImageSubRegion = imread(TileConfiguration.TileArray(TileRowNum, TileColNum).FullPathName, 'tif', ...
        'PixelRegion', ...
        {[round(TopLeftPixelInTile_Y), round(BottomRightPixelInTile_Y+ExtendBottomRightCornerByThisManyPixels)], ...
        [round(TopLeftPixelInTile_X), round(BottomRightPixelInTile_X+ExtendBottomRightCornerByThisManyPixels)]}  );
end

end


