function UtilityScript_CollectFijiStitchedIntoNewFolder()

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

MyAnswer = inputdlg('Section to start at?', 'Start section dialog', 1, {'1'});
if ~isempty(MyAnswer) 
    StartSecNum = str2double(MyAnswer{1}); %NaN if invalid or blank
else
    return; %is empty if user canceled
end
% StartSecNum = 1;
% uiwait(msgbox(sprintf('Start section set to = %d', StartSecNum)));

n = StartSecNum;
while true
    MontageDirName = sprintf('%sSec%d_Montage',DirNameWithoutLastNumber,n);
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
TargetDirectoryName = sprintf('%sFijiStitchedStack',ParentDirectory); %ChangeForMerlin???
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
    %FijiStitched_1.tif
    FileName = sprintf('%sSec%d_Montage\\FijiStitched_%d.tif',DirNameWithoutLastNumber,SectionNum,SectionNum);
    SectionNumStr = num2str(SectionNum+1000);
    SectionNumStr = SectionNumStr(2:end);
    NewFileName = sprintf('%s\\FijiStitched_%s.tif',TargetDirectoryName,SectionNumStr);
    disp(sprintf('Copying file: %s', FileName));
    disp(sprintf('   to: %s', NewFileName));
    
    %[SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION)
    [Success,Message,MessageID] = copyfile(FileName, NewFileName);
    
    %CmdStr = sprintf('move %s %s', FileName, TargetFileName);
    CmdStr = sprintf('copy %s %s', FileName, NewFileName);
    disp(CmdStr);
    dos(CmdStr);
    
%     if ~Success
%         MyStr = sprintf('Could not create file: %s',NewFileName);
%         uiwait(msgbox(MyStr));
%         return;
%     end
end
