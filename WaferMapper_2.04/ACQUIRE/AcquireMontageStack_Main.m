function [  ] = AcquireMontageStack_Main(handles)
%This function will do all types of montage stack acquition and ask user
%which one is to be done
%Types:
%1. Acquire single test image at each position
%2. Acquire single test image at each position with image based stage correction
%3. Acquire montage at each positon
%4. Acquire montage at each positon with image based stage correction

global GuiGlobalsStruct;



%%%%%%%%
YesNoAnswerToUseManuallyCorrectedPositionFiles = questdlg('Base acquition on files in ManuallyCorrectedStagePositionsDirectory?', 'Question', 'Yes', 'No', 'No');

if strcmp(YesNoAnswerToUseManuallyCorrectedPositionFiles, 'No')
    YesNoAnswerToUseImagedBasedStageCorrection = questdlg('Do you want to use image based stage correction?', 'Question', 'Yes', 'No', 'No');
else
    YesNoAnswerToUseImagedBasedStageCorrection = 'No';
end

if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
    YesNoAnswerToPerformAutoFocusDuringIBSC = questdlg('Do you want to perform an Auto Focus during IBSC?', 'Question', 'Yes', 'No', 'No');
end


%Note: Setting Autofunction Scanrate here
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_AutoFunction_ScanRate',GuiGlobalsStruct.MontageParameters.AutofunctionScanrate); 
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_IMAGE_STORE',GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore); 
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Brightness',GuiGlobalsStruct.MontageParameters.ImageBrightness);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Contrast',GuiGlobalsStruct.MontageParameters.ImageContrast); 

%WD_AtAcquitionStart, StigX_AtAcquitionStart, and StigY_AtAcquitionStart
%have been removed from this version of WaferMapper as of 6-28-2013

%These variables are designed to keep a best guess starting point for the
%WD and stig
GuiGlobalsStruct.NumOfStigValuesToMedianOver = 5;
GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack = [];
GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack = [];
GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1:GuiGlobalsStruct.NumOfStigValuesToMedianOver) = GuiGlobalsStruct.MontageParameters.StartingStigX;
GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1:GuiGlobalsStruct.NumOfStigValuesToMedianOver) = GuiGlobalsStruct.MontageParameters.StartingStigY;



GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);


WaferName = GuiGlobalsStruct.WaferName;
MyStr = sprintf('Loaded wafer = %s.', WaferName);
%uiwait(msgbox(MyStr));


%Create a new directory in this wafer to hold all these images
IsDoingRetakes = true; %just assume we are always doing retakes


[dirname] = GetMyDir;%uigetdir(GuiGlobalsStruct.WaferDirectory, 'Choose or create a directory to store images in...');

dirname = dirname(1:end-1);
if dirname == 0
    disp('User Cancled');
    return;
else
    NewDirPath = dirname;
end


StartSecNum = 1;
GuiGlobalsStruct.TempImagesDirectory = NewDirPath;

LogFile_Create(GuiGlobalsStruct.TempImagesDirectory);

%Create LogBook
logBook = logBookCreate;
logBook = logScopeConditions(logBook);

DropoutListFileName = sprintf('%s\\MontageTileDropOutList.txt',GuiGlobalsStruct.WaferDirectory);
if exist(DropoutListFileName,'file')
    DropOutListArray = dlmread(DropoutListFileName,',');
else
    DropOutListArray = [];
end

%Note: these two ways should yield the same list of numbers but I might put
%drop out sections in the future
atlWaferNameIndex = find(strcmp(GuiGlobalsStruct.AlignedTargetList.ListOfWaferNames,WaferName))
if strcmp(YesNoAnswerToUseManuallyCorrectedPositionFiles, 'No')
    %Note: to perfrom this there has to be an AlignedTargetList loaded
    if ~isfield(GuiGlobalsStruct,'AlignedTargetList')
        uiwait(msgbox('Must load an AlignedTargetList first'));
        return;
    end
    
    ArrayOfSectionIndexes = 1:length(GuiGlobalsStruct.AlignedTargetList.WaferArray(atlWaferNameIndex).SectionArray);
else
    
    ArrayOfSectionIndexes = 1:length(GuiGlobalsStruct.CoarseSectionList);
end

%% Generate or retrieve wafer progress
waferProgressFileName = [GuiGlobalsStruct.TempImagesDirectory '\' WaferName 'Progress.mat']
if exist(waferProgressFileName,'file')
    load(waferProgressFileName);
else
    waferProgress.do(ArrayOfSectionIndexes) = 1;
    waferProgress.done(ArrayOfSectionIndexes) = 0;
end


%% Keep checking for more sections
stopimaging=1;
while stopimaging == 1 %loop 
    %pause(1)
  

%%Apply manually identified retakes
manualRetakeListFileName = [GuiGlobalsStruct.TempImagesDirectory '\manualRetakeList.mat'];
if exist(manualRetakeListFileName,'file')
    load(manualRetakeListFileName)
    delete(manualRetakeListFileName)
    waferProgress.do(:) = 0;
    manualRetakeList = manualRetakeList(manualRetakeList<=(length(GuiGlobalsStruct.CoarseSectionList)));
   ArrayOfSectionIndexes = manualRetakeList;
else
    manualRetakeList = [];
end

waferProgress.do(manualRetakeList) = 1;
waferProgress.manualRetakeList = manualRetakeList;
GuiGlobalsStruct.waferProgress = waferProgress;


ArrayOfSectionIndexes = find(waferProgress.do);  

%% Walk through all sections

for i = StartSecNum:length(ArrayOfSectionIndexes)
    
safeSave(waferProgressFileName,'waferProgress')
logBook.waferProgress = waferProgress;

    % stop running sections if there is a new retake list
    if exist(manualRetakeListFileName,'file') 
        break
    end

    
    SectionIndex = ArrayOfSectionIndexes(i)
    
    if strcmp(YesNoAnswerToUseManuallyCorrectedPositionFiles, 'No')
        %from the loaded GuiGlobalsStruct.AlignedTargetList get the current
        %section's information
        MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(atlWaferNameIndex).SectionArray(SectionIndex);
        
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
        GuiGlobalsStruct.MontageTarget.LabelStr = zeroBuf(MySection.LabelStr);
        
    else %if using ManuallyCorrectedPositionFiles then all of above are not used
        GuiGlobalsStruct.MontageTarget.LabelStr = zeroBuf(GuiGlobalsStruct.CoarseSectionList(SectionIndex).Label);
    end
    
    LabelStr = zeroBuf(GuiGlobalsStruct.MontageTarget.LabelStr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%START: Code to check if there are any images needing to be taken
    AreThereAnyImagesToTakeOnThisSection = false;
    if ~IsDoingRetakes
        'Not is doing retakes'
        AreThereAnyImagesToTakeOnThisSection = true; %main dir did not even exist
    else
        sectionStartTime = clock;
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
            GuiGlobalsStruct.RowIndex = RowIndex;
            for ColIndex = 1:NumColTiles
                GuiGlobalsStruct.ColIndex = ColIndex;
                
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
    
    %Above checks if the image file exists. If we are taking off of
    %manually corrected it may be that the manual file does not exits as
    %well. This is checked here:
    if strcmp(YesNoAnswerToUseManuallyCorrectedPositionFiles, 'Yes')
        ManuallyCorrectedPositionFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,SectionIndex);
        if ~exist(ManuallyCorrectedPositionFileNameStr, 'file')
            AreThereAnyImagesToTakeOnThisSection = false;
        else
            load(ManuallyCorrectedPositionFileNameStr, 'Info');
        end
    end
    
    %%Determine if manual retake is required
    doManualRetake = (sum(manualRetakeList == SectionIndex));
    if ~isempty(manualRetakeList)
        AreThereAnyImagesToTakeOnThisSection = false;
    end
    
    if AreThereAnyImagesToTakeOnThisSection | doManualRetake
        
        %KH change 9-30-2011
        %NOTE: If we are doing retakes then you should rename the existing
        %  StageStitched_w007_sec1.tif files
        OriginalStageStitchedImageFileNameStr = sprintf('%s\\StageStitched_%s_sec%s.tif', MontageDirName, WaferName, GuiGlobalsStruct.MontageTarget.LabelStr);
        if exist(OriginalStageStitchedImageFileNameStr,'file')
            CopyNum = 1;
            CopyOfOriginalStageStitchedImageFileNameStr =...
                sprintf('%s\\StageStitched_%s_sec%s_Copy%d.tif', MontageDirName, WaferName, GuiGlobalsStruct.MontageTarget.LabelStr,CopyNum);
            while exist(CopyOfOriginalStageStitchedImageFileNameStr,'file')
                CopyNum = CopyNum + 1;
                CopyOfOriginalStageStitchedImageFileNameStr =...
                    sprintf('%s\\StageStitched_%s_sec%s_Copy%d.tif', MontageDirName, WaferName, GuiGlobalsStruct.MontageTarget.LabelStr,CopyNum);
            end
            %COPYFILE(SOURCE,DESTINATION,MODE)
            copyfile(OriginalStageStitchedImageFileNameStr, CopyOfOriginalStageStitchedImageFileNameStr);
        end
        
        
        if strcmp(YesNoAnswerToUseManuallyCorrectedPositionFiles, 'No')
            if strcmp(YesNoAnswerToUseImagedBasedStageCorrection, 'Yes')
                if strcmp(YesNoAnswerToPerformAutoFocusDuringIBSC, 'Yes')
                    DoAutoFocusAfterGoToMontageTargetMove = true; %used in GoToTargetPointWithImageBasedStageCorrection function
                else
                    DoAutoFocusAfterGoToMontageTargetMove = false;
                end
                
                [goodMatch, logBook] = GoToTargetPointWithImageBasedStageCorrection(DoAutoFocusAfterGoToMontageTargetMove,logBook)
                %Check current position without initial move and then move
                %stage to correct
                %%%%
                %[goodMatch, logBook] = CheckTargetPointWithImageBasedStageCorrection(DoAutoFocusAfterGoToMontageTargetMove,logBook)
                %%%%
                
%                 if ~goodMatch  %Try refocusing
%                     CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
%                     
%                     %*** START: This sequence is desigend to release the SEM from Fibics control
%                     GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
%                     pause(0.5)
%                     GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
%                     while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
%                         pause(0.1);
%                     end
%                     
%                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
%                     pause(0.1);
%                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_AutoFunction_ScanRate',1);
%                     pause(0.1);
%                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_IMAGE_STORE',2)
%                     pause(0.1);
%                     GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
%                     pause(0.1);
%                     while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
%                         pause(0.1);
%                     end
%                    [goodMatch logBook] = GoToTargetPointWithImageBasedStageCorrection(DoAutoFocusAfterGoToMontageTargetMove,logBook);
%                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
% 
%                 end % if IBSC doesnt work
                
%                 if ~goodMatch %reinitialize stage
%                     logBook = logIBSC(logBook,1000,1000, 1000,0,1000, 1000)
%                     reinitializeStage;
%                   [goodMatch logBook] = GoToTargetPointWithImageBasedStageCorrection(DoAutoFocusAfterGoToMontageTargetMove,logBook);
%                 
%                 end %if  IBS + refocus doesnt work, 
%               
              %%%%
                if ~goodMatch %reinitialize stage
                    GoToMontageTargetPointRotationAndFOV;
                 
                 end 
              %%%%  
            else %if not use Imagebased stage correction
                GoToMontageTargetPointRotationAndFOV;
            end
        else
            %goto ManuallyCorrectedPositionFile position
            IsUseStageCorrection = true;
            StageX_Meters = Info.StageX_Meters;
            StageY_Meters = Info.StageY_Meters;
            stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
            stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
            stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
            stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
            
            %If there was no stage transform during the original save
            %then you should apply the current stage transform (if one
            %exists) to this stored position
            if isempty(Info.StageTransformAtTimeOfSave)
                IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
                if IsUseStageCorrection
                    disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                    [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                    disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
                end
            else %if there was a stage transform during the original save then first apply the inverse  of the original saved transform,
                % then apply the current transform
                disp(sprintf('Before inv transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tforminv(Info.StageTransformAtTimeOfSave,[StageX_Meters],[StageY_Meters]);
                disp(sprintf('After inv transform (%d, %d)',StageX_Meters, StageY_Meters));
                IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
                if IsUseStageCorrection
                    disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                    [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                    disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
                end
            end
            
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             LogFile_WriteLine(sprintf('Moving stage to center of montage x = %0.5g and y = %0.5g',StageX_Meters,StageY_Meters));
%             disp(MyStr);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            ScanRot_Degrees = Info.ScanRotation + GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
            
            
            %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
            while ScanRot_Degrees > 360
                ScanRot_Degrees = ScanRot_Degrees - 360;
            end
            while ScanRot_Degrees < 0
                ScanRot_Degrees = ScanRot_Degrees + 360;
            end
            
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);
        end
        
        %Reset initial WD using AFStartingWDd from Montage Parameters
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
        
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',GuiGlobalsStruct.MontageParameters.StartingStigX);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',GuiGlobalsStruct.MontageParameters.StartingStigY);
        pause(.1)
       
    
        
        %NOTE: at then end of each of these the microscope is left in the scan
        %rotation and FOV of the montage setup
        logBook = AcquireMontageAtCurrentPosition(WaferName,LabelStr,logBook);
        logBook.waferProgress = waferProgress;
        logBook = logSec2Excel(logBook);

    end
    sectionStopTime = clock

    SectionDirectory = sprintf('%s\\%s_Sec%s_Montage', GuiGlobalsStruct.TempImagesDirectory,WaferName, LabelStr);
    waferProgress.done(SectionIndex) = 1;
    waferProgress.do(SectionIndex) = 0;
    
    safeSave(waferProgressFileName,'waferProgress');
    finished = clock;
    safeSave([SectionDirectory '\finished.mat'],'finished')

end
stopimaging=0;
%checkCurrent('0')
disp('Finished Acquiring montage stack.')


end
