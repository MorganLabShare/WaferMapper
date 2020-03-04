function UtilityScript_CollectStageStitchedIntoNewFolder()

global GuiGlobalsStruct;

%DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
DirName = uigetdir('.', 'Select first montage directory:');
if isequal(DirName,0) 
    disp('User pressed cancel');
    return;
else
    disp(sprintf('User selected: %s', DirName));
end

%parse this name to remove the section number and all after  
%Z:\Hayworth\MasterUTSLDirectory\WormUTSL_02\w01\Test12_Montage_withIBSC\w01_Sec1_Montage
UnderscoreIndices = strfind(DirName, '_');
SlashIndices = strfind(DirName, '\');
DirNameWithoutLastNumber = DirName(1:UnderscoreIndices(end-1)) %this should take off 'Sec1_Montage'
%DirNameWithoutLastNumber = 'Z:\Hayworth\MasterUTSLDirectory\WormUTSL_02\w01\Test12_Montage_withIBSC\w01_'
WaferName = DirName(SlashIndices(end)+1:UnderscoreIndices(end-1)-1);
ParentDirectory = DirName(1:SlashIndices(end))

n = 1;
while true
    MontageDirName = sprintf('%sSec%03d_Montage',DirNameWithoutLastNumber,n);
    %disp(sprintf('Looking for %s', MontageDirName));
    if ~exist(MontageDirName, 'dir')
        break;
    else
        disp(MontageDirName);
    end
    n = n + 1;
end

TotalNumberOfMontageDirectories = n-1;
MyStr = sprintf('About to process %d directories', TotalNumberOfMontageDirectories);
uiwait(msgbox(MyStr));

% Code in the option later to move either stage-stitched images or tiles if there
% is a single tile per image
%TargetDirectoryName = sprintf('%s\\SingleTileStack\\',ParentDirectory);
TargetDirectoryName = sprintf('%s\\StageStitchedStack\\',ParentDirectory);
if ~exist(TargetDirectoryName,'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR)
    [Success,Message,MessageID] = mkdir(TargetDirectoryName);
    if ~Success
        MyStr = sprintf('Could not create directory: %s',TargetDirectoryName);
        uiwait(msgbox(MyStr));
        return;
    end
end

for SectionNum = 1:TotalNumberOfMontageDirectories
    %FileName = sprintf('%sSec%03d_Montage\\Tile_r1-c1_%s_sec%03d.tif',DirNameWithoutLastNumber,SectionNum,WaferName,SectionNum)
    FileName = sprintf('%sSec%03d_Montage\\StageStitched_%s_sec%03d.tif',DirNameWithoutLastNumber,SectionNum,WaferName,SectionNum);
    SectionNumStr = num2str(SectionNum+1000);
    SectionNumStr = SectionNumStr(2:end);
    %NewFileName = sprintf('%s\\Tile_r1-c1_%s.tif',TargetDirectoryName,SectionNumStr)
    NewFileName = sprintf('%s\\StageStitched_%s.tif',TargetDirectoryName,SectionNumStr);
    disp(sprintf('Copying file: %s', FileName));
    disp(sprintf('   to: %s', NewFileName));
    
    %[SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION)
    [Success,Message,MessageID] = copyfile(FileName, NewFileName);
    if ~Success
        MyStr = sprintf('Could not create file: %s',NewFileName);
        uiwait(msgbox(MyStr));
        return;
    end
end
