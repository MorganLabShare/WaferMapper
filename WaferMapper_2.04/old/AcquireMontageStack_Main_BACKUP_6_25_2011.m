function [  ] = AcquireMontageStack_Main(handles)
%This function will do all types of montage stack acquition and ask user
%which one is to be done
%Types:
%1. Acquire single test image at each position
%2. Acquire single test image at each position with image based stage correction
%3. Acquire montage at each positon
%4. Acquire montage at each positon with image based stage correction

global GuiGlobalsStruct;

YesNoAnswerToAcquireSingleTestImages = questdlg('Do you want to just acquire single test images?', 'Question', 'Yes', 'No', 'No');
YesNoAnswerToUseImagedBasedStageCorrection = questdlg('Do you want to use image based stage correction?', 'Question', 'Yes', 'No', 'No');

%%Determine what wafer is loaded
WaferNameIndex = 0;
for i = 1:length(GuiGlobalsStruct.ListOfWaferNames)
    WaferName = GuiGlobalsStruct.ListOfWaferNames{i};
    WaferDirName = sprintf('%s\\%s',...
        GuiGlobalsStruct.UTSLDirectory, WaferName);
    if strcmp(GuiGlobalsStruct.WaferDirectory, WaferDirName)
        WaferNameIndex = i;
    end
end
if WaferNameIndex == 0
    MyStr = sprintf('Could not find index of current wafer in loaded target points.');
    uiwait(msgbox(MyStr));
    return;
end
WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex};
MyStr = sprintf('Loaded wafer = %s.', WaferName);
uiwait(msgbox(MyStr));


%Create a new directory in this wafer to hold all these images
IsDoingRetakes = false;
% InputDlgAnswer = inputdlg('Enter name for new directory to store images (will create subdirectory under wafer directory)');
% NewNameStr = InputDlgAnswer{1};
% NewDirPath = sprintf('%s\\%s', GuiGlobalsStruct.WaferDirectory, NewNameStr);

[dirname] = uigetdir(GuiGlobalsStruct.WaferDirectory, 'Enter name for new directory to store images...');
if dirname == 0
    disp('User Cancled');
    return;
else
    NewDirPath = dirname;
end

GuiGlobalsStruct.TempImagesDirectory = NewDirPath;
if ~exist(NewDirPath,'dir')
    [success,message,messageid] = mkdir(NewDirPath);
    if success == 1
        
    else
        msgbox(message);
    end
else
    MyStr = sprintf('Directory (%s) already exists. Will take new images only for those image files that do not already exist in the dir.',NewDirPath);
    uiwait(msgbox(MyStr));
    IsDoingRetakes = true;
end


DropoutListFileName = sprintf('%s\\MontageTileDropOutList.txt',GuiGlobalsStruct.WaferDirectory);
if exist(DropoutListFileName,'file')
    DropOutListArray = dlmread(DropoutListFileName,',');
else
    DropOutListArray = [];
end

%Note: to perfrom this there has to be an AlignedTargetList loaded
if ~isfield(GuiGlobalsStruct,'AlignedTargetList')
    uiwait(msgbox('Must load an AlignedTargetList first'));
    return;
end
%Walk through all sections
for SectionIndex = 1:length(GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray)
    %from the loaded GuiGlobalsStruct.AlignedTargetList get the current
    %section's information
    MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
    
    %Load this information into GuiGlobalsStruct.MontageTarget parameters
    GuiGlobalsStruct.MontageTarget.MicronsPerPixel = MySection.SectionOveriewInfo.ReadFOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageX_Meters;
    GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageY_Meters;
    GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = MySection.SectionOveriewInfo.ImageHeightInPixels;
    
    GuiGlobalsStruct.MontageTarget.Alignment_r_offset = MySection.AlignmentParameters.r_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_c_offset = MySection.AlignmentParameters.c_offset;
    

    %KH New code for putting in the offset calculated in the AlignedTargetList
    r_offset = MySection.YOffsetOfNewInPixels;  %offset calculated in the AlignedTargetList
    c_offset = - MySection.XOffsetOfNewInPixels; %offset calculated in the AlignedTargetList
    GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset = r_offset;
    GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset = c_offset;
    
    
    GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = MySection.AlignmentParameters.AngleOffsetInDegrees;
    GuiGlobalsStruct.MontageTarget.LabelStr = MySection.LabelStr;
    LabelStr = GuiGlobalsStruct.MontageTarget.LabelStr;
    
    
    %%%START: Code to check if there are any images needing to be taken
    AreThereAnyImagesToTakeOnThisSection = false;
    if ~IsDoingRetakes
        AreThereAnyImagesToTakeOnThisSection = true; %main dir did not even exist
    else
        NumRowTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileRows;
        NumColTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileCols;
        if (NumRowTiles == 1) && (NumColTiles == 1) %if single image montage then put in main directory
            MontageDirName = GuiGlobalsStruct.TempImagesDirectory;
        else
            MontageDirName = sprintf('%s\\%s_Sec%s_Montage', GuiGlobalsStruct.TempImagesDirectory,WaferName, GuiGlobalsStruct.MontageTarget.LabelStr);
        end
        
        disp(sprintf('Checking if exist:%s', MontageDirName));
        if ~exist(MontageDirName,'dir')
            disp(sprintf('   Does not exist:%s', MontageDirName));
            AreThereAnyImagesToTakeOnThisSection = true; %montage dir did not even exist
        end
        
        for RowIndex = 1:NumRowTiles
            for ColIndex = 1:NumColTiles
                
                IsDropOut = false;
                [NumDropOuts, dummy] = size(DropOutListArray);
                for DropOutListIndex = 1:NumDropOuts
                    if (DropOutListArray(DropOutListIndex, 1) == RowIndex) && (DropOutListArray(DropOutListIndex, 2) == ColIndex)
                        IsDropOut = true;
                    end
                end
                
                if (NumRowTiles == 1) && (NumColTiles == 1)
                    ImageFileNameStr = sprintf('%s\\Image_%s.tif', MontageDirName, LabelStr);
                else
                    %Tile_r1-c1_VMat2_sec01.tif
                    ImageFileNameStr = sprintf('%s\\Tile_r%d-c%d_%s_sec%s.tif', MontageDirName, RowIndex, ColIndex, WaferName, LabelStr);
                end
                
                
                if ~IsDropOut
                    disp(sprintf('Checking if exist:%s', ImageFileNameStr));
                    if ~exist(ImageFileNameStr)
                        disp(sprintf('   Does not exist:%s', ImageFileNameStr));
                        AreThereAnyImagesToTakeOnThisSection = true; %file does not exist so we should take
                    end
                end
            end
        end  
    end
    %%%END: Code to check if there are any images needing to be taken
    
    if AreThereAnyImagesToTakeOnThisSection
        
        if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
            GoToTargetPointWithImageBasedStageCorrection;
        else
            GoToMontageTargetPointRotationAndFOV;
        end
        %NOTE: at then end of each of these the microscope is left in the scan
        %rotation and FOV of the montage setup
        
        if strcmp(YesNoAnswerToAcquireSingleTestImages, 'Yes')
            if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
                %PerformAutoFocus already performed within GoToTargetPointWithImageBasedStageCorrection function
            else
                PerformAutoFocus;
                %GridAutoFocus(NumRowTiles, NumColTiles, RowDistanceBetweenTileCentersInMicrons, ColDistanceBetweenTileCentersInMicrons)
                
            end
            
            ImageFileNameStr = sprintf('%s\\TestDownsampledOverviewImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, MySection.LabelStr);
            if ~exist(ImageFileNameStr)    
                disp(sprintf('Acquiring image file: %s',ImageFileNameStr));
                ImageWidthInPixels = 1024;%16384;%; %1024
                ImageHeightInPixels = 1024;%16384;%; %1024
                DwellTimeInMicroseconds = 2;
                FOV_microns = 100; %40.96; %40nm pixel
                IsDoAutoRetakeIfNeeded = false;
                %Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
                %      FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
                IsMagOverride = false;
                MagForOverride = -1;
                WaferNameStr = WaferName;
                LabelStr = MySection.LabelStr;
                Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                    FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
            end
        else
            %         if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
            %             %PerformAutoFocus already performed within GoToTargetPointWithImageBasedStageCorrection function
            %         else
            %             PerformAutoFocus;
            %         end
            
            %NOTE: performs offset autofocus within this function
            AcquireMontageAtCurrentPosition(WaferName, GuiGlobalsStruct.MontageTarget.LabelStr);
        end
    end
end

end


