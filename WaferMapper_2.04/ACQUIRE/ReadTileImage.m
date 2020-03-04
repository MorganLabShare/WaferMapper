function A = ReadTileImage(R, C)

global GuiGlobalsStruct;

R_str = sprintf('%d',1000+R);
C_str = sprintf('%d',1000+C);

%A = IMREAD(FILENAME,FMT)
%TileR024_C019.tif
MyFileName = sprintf('%s\\TileR%s_C%s.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory,R_str(2:4),C_str(2:4));

if exist(MyFileName, 'file')
    MyStr = sprintf('Reading in image tile %s', MyFileName);
    disp(MyStr);
    A = imread(MyFileName);
else
    A = zeros(GuiGlobalsStruct.FullMapData.ImageHeightInPixels, GuiGlobalsStruct.FullMapData.ImageWidthInPixels);

    FileNotFoundIconImage = imread('FileNotFoundIcon.tif','tif');
    size(FileNotFoundIconImage)
    [MaxR, MaxC] = size(FileNotFoundIconImage);
    A(floor(end/2)+1:floor(end/2)+MaxR, floor(end/2)+1:floor(end/2)+MaxC) = 255*FileNotFoundIconImage;
    
    
end




