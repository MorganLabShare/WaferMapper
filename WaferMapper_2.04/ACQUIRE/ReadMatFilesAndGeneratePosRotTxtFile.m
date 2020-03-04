%ReadMatFilesAndGeneratePosRotTxtFile

DirName = 'Z:\Hayworth\MasterUTSLDirectory\CortexUTSL004\Wafer006\TempImagesDirectory';

for i = 1:1
    DataFileName = sprintf('%s\\HighResStackImage_%d.mat',DirName,i);
    disp( DataFileName);
    load(DataFileName)
end

