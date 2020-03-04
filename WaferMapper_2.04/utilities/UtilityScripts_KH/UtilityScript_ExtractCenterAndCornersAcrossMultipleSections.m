function [] = UtilityScript_ExtractCenterAndCornersAcrossMultipleSections()

MontageStackDir = uigetdir('W:\Hayworth\','Pick the montage stack directory');
if MontageStackDir == 0
    return;
end

%Y:\Hayworth\MontageStack_JM_YR1C_w008_11_9_2011\w008_Sec1_Montage

DirAndWildCardStr = sprintf('%s\\*_Montage',MontageStackDir);
ListOfMontageDirectories = dir(DirAndWildCardStr)


OrderedArrayOfMontageDirectoryNames = [];
for i = 1:length(ListOfMontageDirectories)
    TempArray = strfind(ListOfMontageDirectories(i).name,'_');
    SectionNumStr = ListOfMontageDirectories(i).name(TempArray(end-1)+4:TempArray(end)-1);
    SectionNum = str2num(SectionNumStr);
    
    OrderedCellArrayOfMontageDirectoryNames{SectionNum} = ListOfMontageDirectories(i).name;
    
    
end

TargetDirectoryName = sprintf('%s\\ExtractedCenterAndCornersImageStack',MontageStackDir);
if ~exist(TargetDirectoryName,'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR)
    [Success,Message,MessageID] = mkdir(TargetDirectoryName);
    if ~Success
        MyStr = sprintf('Could not create directory: %s',TargetDirectoryName);
        uiwait(msgbox(MyStr));
        return;
    end
end

for SectionNum = 1:length(OrderedCellArrayOfMontageDirectoryNames)
    MontageDirName = OrderedCellArrayOfMontageDirectoryNames{SectionNum};
    
    if ~isempty(MontageDirName)

        MontageDir = sprintf('%s\\%s', MontageStackDir, MontageDirName);
        %disp(sprintf('Analizing: %s',  MontageDir));
        
        
        %[AgregateAllImage] = UtilityScript_ExtractCentersFromMontageDirectory(MontageDir);
        
        ExtractedCenterAndCornersImage_FileName = sprintf('%s\\ExtractedCenterAndCornersImage_%d.tif', TargetDirectoryName, SectionNum);
        [AgregateAllImage] = UtilityScript_ExtractCentersFromMontageDirectory(MontageDir);
        imwrite(AgregateAllImage, ExtractedCenterAndCornersImage_FileName, 'tif');
        disp(sprintf('Writing file: %s', ExtractedCenterAndCornersImage_FileName));
    end
end