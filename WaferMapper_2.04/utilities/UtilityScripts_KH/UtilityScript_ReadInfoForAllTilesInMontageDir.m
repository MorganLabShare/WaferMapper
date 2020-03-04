function [ArrayOfTileInfos] = UtilityScript_ReadInfoForAllTilesInMontageDir(MontageDirInput)


if nargin < 1
    IsCalledAsSubFunction = false;
else
    IsCalledAsSubFunction = true;
end

if ~IsCalledAsSubFunction
    MontageDir = uigetdir('Z:\Hayworth\MasterUTSLDir\Cortex\w007\MontageStack_08\','Pick the montage directory');
    if MontageDir == 0
        return;
    end
else
    MontageDir = MontageDirInput; 
end

MaxR = 1;
MaxC = 1;

n = 1;
DirAndWildCardStr = sprintf('%s\\*.mat',MontageDir);
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
                
            ArrayOfTileInfos(n).FileNameAndPath = FileNameAndPath;
            ArrayOfTileInfos(n).R = R;
            ArrayOfTileInfos(n).C = C;
            
            
            
            n = n+1;
        end
    end
end



for n = 1:length(ArrayOfTileInfos)
    %INFO = IMFINFO(FILENAME,FMT)      
    
    
    R = ArrayOfTileInfos(n).R;
    C = ArrayOfTileInfos(n).C;
    
    disp(sprintf(' Loading File: %s, (r,c) = (%d, %d)',ArrayOfTileInfos(n).FileNameAndPath, R, C));
    load(ArrayOfTileInfos(n).FileNameAndPath, 'Info');
    ArrayOfTileInfos(n).Info = Info;
    %disp(sprintf('   Info.ScanRotation = %0.5g', Info.ScanRotation));
    
    
    
    
    
end


