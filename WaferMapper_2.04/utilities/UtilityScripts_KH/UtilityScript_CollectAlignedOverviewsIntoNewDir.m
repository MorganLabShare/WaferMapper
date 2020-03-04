function UtilityScript_CollectAlignedOverviewsIntoNewDir()

global GuiGlobalsStruct;

%DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
TargetDirName = uigetdir('.', 'Pick the directory you want to put the aligned overviews in...');
if isequal(TargetDirName,0) 
    disp('User pressed cancel');
    return;
else
    disp(sprintf('User selected: %s', TargetDirName));
end


NumOfSectionInUTSL = 0;
for WaferIndex = 1:length(GuiGlobalsStruct.ListOfWaferNames)
    DirStr = sprintf('%s\\%s\\SectionOverviewsAlignedWithTemplateDirectory',GuiGlobalsStruct.UTSLDirectory, GuiGlobalsStruct.ListOfWaferNames{WaferIndex});
    
    NumOfSectionInWafer = 0;
    IsMoreSectionsInWafer = true;
    while(IsMoreSectionsInWafer)
        NumOfSectionInWafer = NumOfSectionInWafer + 1;
        NumOfSectionInUTSL = NumOfSectionInUTSL + 1;
        FileName = sprintf('SectionOverviewAligned_%d.tif',NumOfSectionInWafer);
        FileNameAndFullPath = sprintf('%s\\%s',DirStr, FileName);
        disp(FileNameAndFullPath);
        
        
        TempStr = sprintf('%d', 10000 + NumOfSectionInUTSL);
        NewFileName = sprintf('SectionOverviewAligned_%s.tif',TempStr(2:end));
        NewFileNameAndFullPath = sprintf('%s\\%s',TargetDirName, NewFileName);
        disp(NewFileNameAndFullPath);
        
        if (exist(NewFileNameAndFullPath, 'file'))
            disp(sprintf('   %s already exists. Skiping.', NewFileNameAndFullPath));
        else
            %[SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE)
            copyfile(FileNameAndFullPath, NewFileNameAndFullPath);
        end
        
        NextFileName = sprintf('SectionOverviewAligned_%d.tif',NumOfSectionInWafer+1);
        NextFileNameAndFullPath = sprintf('%s\\%s',DirStr, NextFileName);
        if (~exist(NextFileNameAndFullPath, 'file'))
            IsMoreSectionsInWafer = false;
        end
    end

end

