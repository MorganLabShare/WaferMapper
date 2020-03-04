function [AgregateAllImage] = UtilityScript_ExtractCentersFromMontageDirectory(MontageDirInput)


if nargin < 1
    IsCalledAsSubFunction = false;
else
    IsCalledAsSubFunction = true;
end

if ~IsCalledAsSubFunction
    MontageDir = uigetdir('W:\Hayworth\stack_w009\','Pick the montage directory');
    if MontageDir == 0
        return;
    end
else
    MontageDir = MontageDirInput; 
end

MaxR = 1;
MaxC = 1;

n = 1;
DirAndWildCardStr = sprintf('%s\\*.tif',MontageDir);
ListOfTifFiles = dir(DirAndWildCardStr);
for i = 1:length(ListOfTifFiles)
    FileName = ListOfTifFiles(i).name;
    if length(FileName) >= 5
        if strcmp('Tile_',FileName(1:5))
            %disp(sprintf('Loading file: %s',FileName));
            FileNameAndPath = sprintf('%s\\%s', MontageDir, FileName);
            

            
            %Tile_r1-c6_AW01_sec65
            TempArray = strfind(FileName,'_');
            SubStr = FileName(TempArray(1)+2:end);
            TempArray2 = strfind(SubStr,'-');
            RowStr = SubStr(1:TempArray2(1)-1);
            TempArray3 = strfind(SubStr,'_');
            ColStr = SubStr(TempArray2(1)+2:TempArray3(1)-1);
            
     
            R = str2num(RowStr);
            C = str2num(ColStr);
            
            if MaxR < R
               MaxR = R; 
            end
            if MaxC < C
               MaxC = C; 
            end
            
            if ~IsCalledAsSubFunction
                disp(sprintf('File: %s, (r,c) = (%d, %d)',FileName, R, C));
            end
                
            ArrayOfSubImages(n).FileNameAndPath = FileNameAndPath;
            ArrayOfSubImages(n).R = R;
            ArrayOfSubImages(n).C = C;
            
            
            
            n = n+1;
        end
    end
end


SizeSubImage = 200;
AgregateImage_Center = uint8(zeros(MaxR*SizeSubImage, MaxC*SizeSubImage));
AgregateImage_TopLeft = AgregateImage_Center;
AgregateImage_TopRight = AgregateImage_Center;
AgregateImage_BottomLeft = AgregateImage_Center;
AgregateImage_BottomRight = AgregateImage_Center;
DummyBarArray = uint8(zeros(30, MaxC*SizeSubImage));
for n = 1:length(ArrayOfSubImages)
    %INFO = IMFINFO(FILENAME,FMT)      
    
    ImageFileInfo = imfinfo(ArrayOfSubImages(n).FileNameAndPath, 'tif');
    R = ArrayOfSubImages(n).R;
    C = ArrayOfSubImages(n).C;
    if ~IsCalledAsSubFunction
        disp(sprintf(' Processing File: %s, (r,c) = (%d, %d)',ArrayOfSubImages(n).FileNameAndPath, R, C));
    end
    
    %for agregate images
    R_Start = ((R-1)*SizeSubImage)+1;
    C_Start = ((C-1)*SizeSubImage)+1;
    
    %AgregateImage_Center
    %'PixelRegion',    {ROWS, COLS}
    ROWS = [floor(ImageFileInfo(1).Height/2) - (SizeSubImage/2), floor(ImageFileInfo(1).Height/2) + (SizeSubImage/2)-1];
    COLS = [floor(ImageFileInfo(1).Width/2) - (SizeSubImage/2), floor(ImageFileInfo(1).Width/2) + (SizeSubImage/2)-1];
    ArrayOfSubImages(n).SubImage_Center = imread(ArrayOfSubImages(n).FileNameAndPath, 'tif', 'PixelRegion',    {ROWS, COLS});
    AgregateImage_Center(R_Start:R_Start+SizeSubImage-1, C_Start:C_Start+SizeSubImage-1) = 255-ArrayOfSubImages(n).SubImage_Center;
    
    
    %AgregateImage_TopLeft
    ROWS = [1, SizeSubImage];
    COLS = [(ImageFileInfo(1).Width - SizeSubImage)+1, ImageFileInfo(1).Width];
    ArrayOfSubImages(n).SubImage_TopLeft = imread(ArrayOfSubImages(n).FileNameAndPath, 'tif', 'PixelRegion',    {ROWS, COLS});
    AgregateImage_TopLeft(R_Start:R_Start+SizeSubImage-1, C_Start:C_Start+SizeSubImage-1) = 255-ArrayOfSubImages(n).SubImage_TopLeft;
    
    %AgregateImage_TopRight
    ROWS = [1, SizeSubImage];
    COLS = [1, SizeSubImage];
    ArrayOfSubImages(n).SubImage_TopRight = imread(ArrayOfSubImages(n).FileNameAndPath, 'tif', 'PixelRegion',    {ROWS, COLS});
    AgregateImage_TopRight(R_Start:R_Start+SizeSubImage-1, C_Start:C_Start+SizeSubImage-1) = 255-ArrayOfSubImages(n).SubImage_TopRight;
    
    %AgregateImage_BottomLeft
    ROWS = [(ImageFileInfo(1).Height - SizeSubImage)+1, ImageFileInfo(1).Height];
    COLS = [1, SizeSubImage];
    ArrayOfSubImages(n).SubImage_BottomLeft = imread(ArrayOfSubImages(n).FileNameAndPath, 'tif', 'PixelRegion',    {ROWS, COLS});
    AgregateImage_BottomLeft(R_Start:R_Start+SizeSubImage-1, C_Start:C_Start+SizeSubImage-1) = 255-ArrayOfSubImages(n).SubImage_BottomLeft;
    
    %AgregateImage_BottomRight
    ROWS = [(ImageFileInfo(1).Height - SizeSubImage)+1, ImageFileInfo(1).Height];
    COLS = [(ImageFileInfo(1).Width - SizeSubImage)+1, ImageFileInfo(1).Width];
    ArrayOfSubImages(n).SubImage_BottomRight = imread(ArrayOfSubImages(n).FileNameAndPath, 'tif', 'PixelRegion',    {ROWS, COLS});
    AgregateImage_BottomRight(R_Start:R_Start+SizeSubImage-1, C_Start:C_Start+SizeSubImage-1) = 255-ArrayOfSubImages(n).SubImage_BottomRight;
    
    
    if ~IsCalledAsSubFunction
        figure(4632);
        subplot(3,3,1);
        imshow(AgregateImage_TopLeft);
        subplot(3,3,3);
        imshow(AgregateImage_TopRight);
        subplot(3,3,5);
        imshow(AgregateImage_Center);
        subplot(3,3,7);
        imshow(AgregateImage_BottomLeft);
        subplot(3,3,9);
        imshow(AgregateImage_BottomRight);
    end

%     figure(1);
%     C + (R-1)*MaxC
%     subplot(MaxR, MaxC, C + (R-1)*MaxC);
%     imshow(255-ArrayOfSubImages(n).SubImage_Center);
%     pause(0.1);
%     
%     figure(2);
%     C + (R-1)*MaxC
%     subplot(MaxR, MaxC, C + (R-1)*MaxC);
%     imshow(255-ArrayOfSubImages(n).SubImage_TopLeft);
%     pause(0.1);
    
end



 
AgregateAllImage = [AgregateImage_TopLeft; DummyBarArray; AgregateImage_TopRight; DummyBarArray; AgregateImage_Center; DummyBarArray; AgregateImage_BottomLeft; DummyBarArray; AgregateImage_BottomRight];
