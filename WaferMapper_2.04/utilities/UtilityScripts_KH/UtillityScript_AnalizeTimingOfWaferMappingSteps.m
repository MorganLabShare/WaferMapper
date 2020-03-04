%UtillityScript_AnalizeTimingOfWaferMappingSteps



%DIRECTORYNAME = UIGETDIR(STARTPATH,
%TITLE)
%UTSLDirName = uigetdir('Z:\Hayworth\MasterUTSLDir\Cerebellum_JM_YR1C_UTSL', 'Select UTSL directory');
UTSLDirName = uigetdir('Z:\Hayworth\MasterUTSLDir\ZF_Sample1_UTSL', 'Select UTSL directory');
if isequal(UTSLDirName,0)
    disp('User pressed cancel');
    return;
else
    disp(sprintf('User selected: %s', UTSLDirName));
end

WaferNamesArray = {'w05', 'w06', 'w07', 'w08', 'w09', 'w10', 'w11'};

for WaferIndex = 1:length(WaferNamesArray)
    
    WaferDirName = sprintf('%s\\%s',UTSLDirName, WaferNamesArray{WaferIndex});
    
    FileName_Array(1).name = sprintf('%s\\LowResFiducialsDirectory\\Fiducial_01.mat', WaferDirName);
    FileName_Array(2).name = sprintf('%s\\LowResFiducialsDirectory\\Fiducial_04.mat', WaferDirName);
    FileName_Array(3).name = sprintf('%s\\HighResFiducialsDirectory\\Fiducial_04.mat', WaferDirName);
    FileName_Array(4).name = sprintf('%s\\ExampleSectionImageDirectory\\ExampleSectionImage.tif', WaferDirName);
    FileName_Array(5).name = sprintf('%s\\ExampleSectionImageDirectory\\ExampleSectionImageCropped.tif', WaferDirName);
    FileName_Array(6).name = sprintf('%s\\ExampleSectionImageDirectory\\ExampleSectionImage_Thresholded.tif', WaferDirName);
    FileName_Array(7).name = sprintf('%s\\FullWaferTileImages\\CoarseSectionList.mat', WaferDirName);
    FileName_Array(8).name = sprintf('%s\\PixelToStageCalibrationDirectory\\CalibrationFile.mat', WaferDirName);
    %Find last section overview image
    SectionNum = 1;
    while true
        SectionOverviewFileName = sprintf('%s\\SectionOverviewsDirectory\\SectionOverview_%d.mat', WaferDirName, SectionNum);
        if ~exist(SectionOverviewFileName, 'file')
            break;
        end
        SectionNum = SectionNum + 1;
    end
    FileName_Array(9).name = sprintf('%s\\SectionOverviewsDirectory\\SectionOverview_%d.mat', WaferDirName, SectionNum-1);
    FileName_Array(10).name = sprintf('%s\\SectionOverviewTemplateDirectory\\SectionOverviewTemplate.tif', WaferDirName);
    FileName_Array(11).name = sprintf('%s\\SectionOverviewTemplateDirectory\\SectionOverviewTemplateCroppedFilledPeriphery.tif', WaferDirName);
    FileName_Array(12).name = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_1.mat', WaferDirName);
    FileName_Array(13).name = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%d.mat', WaferDirName, SectionNum-1);
    
    FileName_Array(14).name = sprintf('%s\\FullWaferTileImages\\TileR001_C001.mat', WaferDirName);
    FileName_Array(15).name = sprintf('%s\\FullWaferTileImages\\FullMapData.mat', WaferDirName);
    
    
    %Find all file creation times
    for i = 1:length(FileName_Array)
        if ~exist(FileName_Array(i).name, 'file')
            disp(sprintf('Could not find: %s', FileName_Array(i).name));
        end
        D = dir(FileName_Array(i).name);
        FileName_Array(i).DateNum = D.datenum;
        
    end
    
    disp(sprintf('Timing for Wafer: %s', WaferDirName));
    
    %Display time differences
    TimeArray(WaferIndex, 1) = (FileName_Array(2).DateNum - FileName_Array(1).DateNum)*24*60*60;
    disp(sprintf('   Time to Acquire low res. Fiducials = %0.5g seconds', TimeArray(WaferIndex, 1)));
    
    TimeArray(WaferIndex, 2) = (FileName_Array(3).DateNum - FileName_Array(2).DateNum)*24*60*60;
    disp(sprintf('   Time to Acquire high res. Fiducials = %0.5g seconds', TimeArray(WaferIndex, 2)));
    
    TimeArray(WaferIndex, 3) = (FileName_Array(4).DateNum - FileName_Array(3).DateNum)*24*60*60;
    disp(sprintf('   Time to Acquire ExampleSectionImage Fiducials = %0.5g seconds', TimeArray(WaferIndex, 3)));
    
    TimeArray(WaferIndex, 4) = (FileName_Array(5).DateNum - FileName_Array(4).DateNum)*24*60*60;
    disp(sprintf('   Time to Crop example image = %0.5g seconds', TimeArray(WaferIndex, 4)));
    
    TimeArray(WaferIndex, 5) = (FileName_Array(6).DateNum - FileName_Array(5).DateNum)*24*60*60;
    disp(sprintf('   Time to Threshold Images = %0.5g seconds', TimeArray(WaferIndex, 5)));
    
    TimeArray(WaferIndex, 6) = (FileName_Array(7).DateNum - FileName_Array(6).DateNum)*24*60*60;
    disp(sprintf('   Time to Auto Map All Sections = %0.5g seconds', TimeArray(WaferIndex, 6)));
    
    TimeArray(WaferIndex, 7) = (FileName_Array(8).DateNum - FileName_Array(7).DateNum)*24*60*60;
    disp(sprintf('   Time to Perform Pixel To Stage Calibration = %0.5g seconds', TimeArray(WaferIndex, 7)));
    
    TimeArray(WaferIndex, 8) = (FileName_Array(9).DateNum - FileName_Array(8).DateNum)*24*60*60;
    disp(sprintf('   Time to Acquire Section Overviews = %0.5g seconds', TimeArray(WaferIndex, 8)));
    
    TimeArray(WaferIndex, 9) = (FileName_Array(11).DateNum - FileName_Array(10).DateNum)*24*60*60;
    disp(sprintf('   Time to Crop Section Template Image = %0.5g seconds', TimeArray(WaferIndex, 9)));
    
    TimeArray(WaferIndex, 10) = (FileName_Array(13).DateNum - FileName_Array(12).DateNum)*24*60*60;
    disp(sprintf('   Time to Align Section Overviews (unless first or last is corrected) = %0.5g seconds', TimeArray(WaferIndex, 10)));
    
    TimeArray(WaferIndex, 11) = (FileName_Array(15).DateNum - FileName_Array(14).DateNum)*24*60*60;
    disp(sprintf('   Time to acquire SEM full wafer montage  = %0.5g seconds', TimeArray(WaferIndex, 11)));
end

