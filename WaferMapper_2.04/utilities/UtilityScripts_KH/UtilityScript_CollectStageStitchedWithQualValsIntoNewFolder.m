function UtilityScript_CollectStageStitchedWithQualValsIntoNewFolder()

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
DirNameWithoutLastNumber = DirName(1:UnderscoreIndices(end-1)); %this should take off 'Sec1_Montage'
%DirNameWithoutLastNumber = 'Z:\Hayworth\MasterUTSLDirectory\WormUTSL_02\w01\Test12_Montage_withIBSC\w01_'
WaferName = DirName(SlashIndices(end)+1:UnderscoreIndices(end-1)-1);
ParentDirectory = DirName(1:SlashIndices(end))

StartSecNum = 1;  
uiwait(msgbox(sprintf('Start section set to = %d', StartSecNum)));

n = StartSecNum;
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

TotalNumberOfMontageDirectories = n-StartSecNum;
MyStr = sprintf('About to process %d directories', TotalNumberOfMontageDirectories);
uiwait(msgbox(MyStr));

%TargetDirectoryName = sprintf('%s\\StageStitchedStackWithQualVals',ParentDirectory);
TargetDirectoryName = sprintf('%sStageStitchedStackWithQualVals',ParentDirectory); %ChangeForMerlin???
if ~exist(TargetDirectoryName,'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR)
    [Success,Message,MessageID] = mkdir(TargetDirectoryName);
    if ~Success
        MyStr = sprintf('Could not create directory: %s',TargetDirectoryName);
        uiwait(msgbox(MyStr));
        return;
    end
end
    

for SectionNum = StartSecNum:(TotalNumberOfMontageDirectories+StartSecNum-1)
    %StageStitched_w01_sec22_WithQualVals.tif
    FileName = sprintf('%sSec%03d_Montage\\StageStitched_%s_sec%03d_WithQualVals.tif',DirNameWithoutLastNumber,SectionNum,WaferName,SectionNum);
    SectionNumStr = num2str(SectionNum+1000);
    SectionNumStr = SectionNumStr(2:end);
    NewFileName = sprintf('%s\\StageStitchedWithQualVals_%s.tif',TargetDirectoryName,SectionNumStr);
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
