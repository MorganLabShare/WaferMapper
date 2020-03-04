function [TileConfiguration] = UtilityScript_PlotStitchOutlinesForMontageDir(MontageDirInput)

if nargin < 1
    IsCalledAsSubFunction = false;
else
    IsCalledAsSubFunction = true;
end

if ~IsCalledAsSubFunction
    MontageDir = uigetdir('F:\JM_YR1C_Data\w010_Sec1_Montage','Pick the montage directory');
    if MontageDir == 0
        return;
    end
else
    MontageDir = MontageDirInput; 
end

disp(sprintf('MontageDir = %s', MontageDir));


TileConfigurationTextFileName = sprintf('%s\\TileConfiguration.txt.registered', MontageDir);
disp(sprintf('TileConfigurationTextFileName = %s', TileConfigurationTextFileName));
if ~exist(TileConfigurationTextFileName, 'file')
    disp(sprintf('%s does not exist. Exiting.', TileConfigurationTextFileName));
    return;
end

disp(sprintf('Opening file: %s', TileConfigurationTextFileName));
fid = fopen(TileConfigurationTextFileName);

while 1
    tline = fgetl(fid);
    if strcmp(tline, '# Define the image coordinates')
        break;
    end
    
end


while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break;
    end
    disp(tline);
    SemicolonIndexArray = strfind(tline, ';');
    if length(SemicolonIndexArray) ~= 2
        disp(sprintf('Parse error. Exiting.'));
        fclose(fid); 
        return;
    end
    
    %F:/JM_YR1C_Data/w010_Sec1_Montage/Tile_r3-c5_w010_sec1.tif; ; (46473.395, 23493.02)
    %parse for file name
    FileNameStr = tline(1:SemicolonIndexArray(1)-1);
    CoordStr = tline(SemicolonIndexArray(2)+1:end);
    disp(sprintf('   FileNameStr = %s', FileNameStr));
    [pathstr, JustFileName, Extension] = fileparts(FileNameStr);
    JustFileName = sprintf('%s%s', JustFileName, Extension);
    disp(sprintf('   JustFileName = %s', JustFileName));
    
    
    IndexArray01 = strfind(FileNameStr, 'Tile_r');
    PostfixStr = FileNameStr(IndexArray01(end):end);
    IndexArray02 = strfind(PostfixStr, 'Tile_r');
    IndexArray03 = strfind(PostfixStr, '-c');
    RowStr = PostfixStr(IndexArray02(1)+6:IndexArray03(1)-1);
    RowNum = str2double(RowStr);
    disp(sprintf('   RowNum = %d', RowNum));
    PostfixStr02 = PostfixStr(IndexArray03(1)+2:end);
    IndexArray04 = strfind(PostfixStr02, '_');
    ColStr = PostfixStr02(1:IndexArray04(1)-1);
    ColNum = str2double(ColStr);
    disp(sprintf('   ColNum = %d', ColNum));
    
    
    %parse for coordinates
    disp(sprintf('   CoordStr = %s', CoordStr));
    FirstParenthesisIndexArray = strfind(CoordStr, '(');
    CommaIndexArray = strfind(CoordStr, ',');
    LastParenthesisIndexArray = strfind(CoordStr, ')');
    XCoordStr = CoordStr(FirstParenthesisIndexArray(1)+1:CommaIndexArray(1)-1);
    XCoord = str2double(XCoordStr);
    disp(sprintf('   XCoordStr = %0.8g', XCoord));
    YCoordStr = CoordStr(CommaIndexArray(1)+1:LastParenthesisIndexArray(1)-1);
    YCoord = str2double(YCoordStr);
    disp(sprintf('   YCoordStr = %0.8g', YCoord));
    
    
    TileConfiguration.TileArray(RowNum, ColNum).JustFileName = JustFileName;
    TileConfiguration.TileArray(RowNum, ColNum).XCoord = XCoord;
    TileConfiguration.TileArray(RowNum, ColNum).YCoord = YCoord;
end
      
disp('Closing file.');
fclose(fid);   


%Finally read the size of the first file
FirstFileNameAndPath = sprintf('%s\\%s', MontageDir, TileConfiguration.TileArray(1, 1).JustFileName);
disp(sprintf('   FirstFileNameAndPath = %s', FirstFileNameAndPath));

%INFO = IMFINFO(FILENAME,FMT)
info = imfinfo(FirstFileNameAndPath, 'tif');
TileConfiguration.TileWidthInPixels = info(1).Width;
TileConfiguration.TileHeightInPixels = info(1).Height;


figure(100);
clf;
set(gca, 'YDir', 'reverse');
Width = TileConfiguration.TileWidthInPixels;
Height = TileConfiguration.TileHeightInPixels;
[MaxRow, MaxCol] = size(TileConfiguration.TileArray);
for RowNum = 1:MaxRow
    for ColNum = 1:MaxCol
        CenterX = TileConfiguration.TileArray(RowNum, ColNum).XCoord;
        CenterY = TileConfiguration.TileArray(RowNum, ColNum).YCoord;
        
        DrawBox(CenterX, CenterY, Width, Height)
        
        
    end
end

end

function DrawBox(CenterX, CenterY, Width, Height)
    disp('In DrawBox........');
    LeftX =  CenterX - floor(Width/2);
    RightX = LeftX + Width;
    TopY = CenterY - floor(Height/2);
    BottomY = TopY + Height;
    
    line([LeftX LeftX],[TopY BottomY]); %left line
    line([RightX RightX],[TopY BottomY]); %right line
    line([LeftX RightX],[TopY TopY]); %top line
    line([LeftX RightX],[BottomY BottomY]); %bottom line
    
end
