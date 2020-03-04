function[goodMatch,logBook] = GoToTargetPointWithImageBasedStageCorrection(DoAutoFocusAfterGoToMontageTargetMove,logBook)

global GuiGlobalsStruct
disp('In GoToTargetPointWithImageBasedStageCorrection');


%Note this script assumes the global GuiGlobalsStruct.MontageTarget is
%correctly filled in:
% GuiGlobalsStruct.MontageTarget
%
% ans =
%
%                                        r: 1014
%                                        c: 976
%                        MontageNorthAngle: 0
%             LowResForAlignWidthInMicrons: 200
%            LowResForAlignHeightInMicrons: 200
%                MontageTileWidthInMicrons: 65.5360
%               MontageTileHeightInMicrons: 65.5360
%                         NumberOfTileRows: 1
%                         NumberOfTileCols: 1
%                       PercentTileOverlap: 6
%                          MicronsPerPixel: 1
%     StageX_Meters_CenterOriginalOverview: 0.0247
%     StageY_Meters_CenterOriginalOverview: 0.0556
%               OverviewImageWidthInPixels: 2048
%              OverviewImageHeightInPixels: 2048
%                       Alignment_r_offset: 44.0653
%                       Alignment_c_offset: 75.8567
%           Alignment_AngleOffsetInDegrees: 13
%                                 LabelStr: '7'
%%
WaferName = GuiGlobalsStruct.WaferName;
WaferNameIndex = find(strcmp(GuiGlobalsStruct.AlignedTargetList.ListOfWaferNames,WaferName));

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Contrast',GuiGlobalsStruct.MontageParameters.IBSCContrast);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Brightness',GuiGlobalsStruct.MontageParameters.IBSCBrightness);


GoToMontageTargetPointRotationAndFOV;


if exist('DoAutoFocusAfterGoToMontageTargetMove','var')
    if DoAutoFocusAfterGoToMontageTargetMove
        %smartFocus(300);
        WDResetThreshold = 1000;
        %%%%
        smartFocus(1000);
        %%%%
        ResultingWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        pause(0.5);
        if abs(GuiGlobalsStruct.MontageParameters.AFStartingWD - ResultingWorkingDistance) > WDResetThreshold
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
            pause(0.5);
            smartFocus(500); %give it another try
            if (abs(GuiGlobalsStruct.MontageParameters.AFStartingWD - ResultingWorkingDistance) > WDResetThreshold)
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
            end
        end
    end
end


%NOTE: I DO NOT WANT TO GO TO THE SCAN ROTATION OF THE MONTAGE SINCE THE
%IMAGE BASED STAGE CORRECTION IMAGE IS BASED ON A NON-ROTATED ROI. I simply subtract the
% montage north angle off here.
ScanRot_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
Stored_FOV_microns = GuiGlobalsStruct.MyCZEMAPIClass.Fibics_ReadFOV(); %ALSO STORE FOV TO PUT BACK AT END
ScanRot_Degrees = ScanRot_Degrees + GuiGlobalsStruct.MontageTarget.MontageNorthAngle; %has to be '+'?
%NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
while ScanRot_Degrees > 360
    ScanRot_Degrees = ScanRot_Degrees - 360;
end
while ScanRot_Degrees < 0
    ScanRot_Degrees = ScanRot_Degrees + 360;
end
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);








LabelStr = GuiGlobalsStruct.MontageTarget.LabelStr;
SectionIndex = str2num(LabelStr);


MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);

%************************************
%Take another image the same resolution and size as the
%AlignedTargetList image (which is just a crop of the original section
%overview)
MicronsPerPixel = MySection.SectionOveriewInfo.ReadFOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
FOV_microns = (MySection.half_w*2)*MicronsPerPixel;
GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
pause(0.5);
GuiGlobalsStruct.MyCZEMAPIClass.Fibics_ReadFOV();

if ~exist(GuiGlobalsStruct.TempImagesDirectory,'dir')
    mkdir(GuiGlobalsStruct.TempImagesDirectory);
end

%%KH removed 8-27-2011
%PerformAutoFocus;

IBSCdir = [GuiGlobalsStruct.TempImagesDirectory '\IBSC'];
if ~exist(IBSCdir,'dir')
    mkdir(IBSCdir)
end

TempImageFileNameStr = sprintf('%s\\IBSC_%s_%s.tif',  IBSCdir,WaferName,zeroBuf(MySection.LabelStr));


%NOTE: Need to delete the original if it exists since we are checking if it
%exists to move on. (THIS IS NOW HANDLED DIRECTLY 
%IN THE Fibics_AcquireImage() function
% if exist(TempImageFileNameStr, 'file')
%     delete(TempImageFileNameStr);
% end
% pause(1);

%%
ImageWidthInPixels = MySection.half_w*2+1;%8192;
ImageHeightInPixels = MySection.half_h*2+1;%8192;
DwellTimeInMicroseconds = 5; %2
%Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
%      FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, TempImageFileNameStr,...
    FOV_microns, true, false, -1,  WaferName, zeroBuf(MySection.LabelStr));
pause(1);

%load this just aquired image
IsReadOK = false;
while ~IsReadOK
    IsReadOK = true;
    try
        CurrentImage = imread(TempImageFileNameStr, 'tif');
        
        DetectorStr = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_DETECTOR_TYPE');
        
        if strcmp(DetectorStr, 'InLens') || strcmp(DetectorStr, 'SE2')
            IsNeedToInvert = true;
        else
            IsNeedToInvert = false;
        end
        if IsNeedToInvert
            CurrentImage = 255-CurrentImage;
        end
        
    catch MyException
        IsReadOK = false;
        %disp(sprintf('   imread exception: %s',MyException.identifier));
        pause(.1);
    end
end

%Load the cooresponding AlignedTargetList image
ImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
    GuiGlobalsStruct.AlignedTargetListDir , WaferName,  MySection.LabelStr);
ImageFileNameStr;
OriginalImage = imread(ImageFileNameStr, 'tif');

ImageFile_x3LargerROI_NameStr = sprintf('%s\\LowResAligned_x3LargerROI_%s_Section_%s.tif',...
    GuiGlobalsStruct.AlignedTargetListDir , WaferName,  MySection.LabelStr);
OriginalImage_x3LargerROI = imread(ImageFile_x3LargerROI_NameStr, 'tif');

H_gaussian = fspecial('gaussian',[3 15],2);%fspecial('gaussian',[9 9],5); %fspecial('gaussian',[5 5],1.5);
OriginalImage_Filtered = imfilter(OriginalImage,H_gaussian);
OriginalImage_x3LargerROI_Filtered = imfilter(OriginalImage_x3LargerROI,H_gaussian);
CurrentImage_Filtered = imfilter(CurrentImage,H_gaussian);



CurrentImage_Filtered = imadjust(CurrentImage_Filtered);
OriginalImage_x3LargerROI_Filtered = imadjust(OriginalImage_x3LargerROI_Filtered);

% %START: JOSH'S FILTER
OriginalImage_x3LargerROI_Filtered = 256 - OriginalImage_x3LargerROI_Filtered;
% [OriginalImage_x3LargerROI_Filtered] = mexHatVessle(OriginalImage_x3LargerROI_Filtered,2,20);
% OriginalImage_x3LargerROI_Filtered = 255*(OriginalImage_x3LargerROI_Filtered/max(max(OriginalImage_x3LargerROI_Filtered)));
%[CurrentImage_Filtered] = mexHatVessle(CurrentImage_Filtered,2,100);
% CurrentImage_Filtered = 255*(CurrentImage_Filtered/max(max(CurrentImage_Filtered)));
% 


[FilteredWidth, FilteredHeight] = size(CurrentImage_Filtered);
%Must crop so this is still centered (Tasrget width is 3*FilteredWidth)


OriginalImage_x3LargerROI_Filtered = ...
    OriginalImage_x3LargerROI_Filtered(  floor(1+((end-3*FilteredWidth)/2)):floor(1+((end-3*FilteredWidth)/2))+ ((3*FilteredWidth)-1),...
    floor(1+((end-3*FilteredHeight)/2)):floor(1+((end-3*FilteredHeight)/2))+ ((3*FilteredHeight)-1));



OriginalImage_x3LargerROI_Filtered = uint8(OriginalImage_x3LargerROI_Filtered);
CurrentImage_Filtered = uint8(CurrentImage_Filtered);
% %END: JOSH'S FILTER

IsDisplay_IBSC_Figure = false;
if IsDisplay_IBSC_Figure
    IBSC_Figure_Handle = figure(987);
    subplot(1,2,1);
    imshow(OriginalImage_x3LargerROI_Filtered,[0,255]);
    title('OriginalImage_x3LargerROI_Filtered');
    
    subplot(1,2,2);
    imshow(CurrentImage_Filtered,[0,255]);
    title('CurrentImage_Filtered');
end

IsNeedToDoScale = true;
IBSC_ScaleFactorFile_NameStr = sprintf('%s\\IBSC_ScaleFactorFile.mat',...
    GuiGlobalsStruct.WaferDirectory);
if exist(IBSC_ScaleFactorFile_NameStr, 'file')
   IsNeedToDoScale = false;  %if file exist and is less that 6000 minutes old then keep old
   load(IBSC_ScaleFactorFile_NameStr, 'IBSC_ScaleFactor');
% 
%     D = dir(IBSC_ScaleFactorFile_NameStr); 
%     
%     
%     %Need to make dummy file and read its time since server time is
%     %different from running computer time by several minutes
%     DummyFile_NameStr = sprintf('%s\\DummyFile.mat',...
%         GuiGlobalsStruct.AlignedTargetListDir);
%     DummyVar = 0;
%     save(DummyFile_NameStr, 'DummyVar');
%     IsDoneWriting = false;
%     pause(0.5);
%     while ~exist(DummyFile_NameStr, 'file')
%         pause(0.5);
%     end
%     D_dummy = dir(DummyFile_NameStr); 
%     
%     
%     TimeDiffInMinutes = (datenum(D_dummy.date) - datenum(D.date)) * 24 * 60;  %datenum is in days, I am converting to minutes
%     
%     if TimeDiffInMinutes < 60000 %60 minutes
%         IsNeedToDoScale = false;  %if file exist and is less that 6000 minutes old then keep old
%     end
%     
%     if ~IsNeedToDoScale
%         h_figMsgBox = msgbox(sprintf('Using IBSC_ScaleFactor = %0.5g, Time since last IBSC scale check = %0.5g minutes', IBSC_ScaleFactor, TimeDiffInMinutes));
%     else
%         h_figMsgBox = msgbox(sprintf('Performing scale check. Time since last IBSC scale check = %0.5g minutes', TimeDiffInMinutes));
%     end
%     %MakeTone(1000, .1, .1); pause(.1); MakeTone(1000, .1, .1); %MakeTone(SoundFrequency, SoundDuration, SoundAmplitude)
%     disp('BEEP')
%     pause(2);
%     if ishandle(h_figMsgBox)
%         close(h_figMsgBox);
%     end
%     
    
else
    disp(sprintf('%s found. Performing scale check.', IBSC_ScaleFactorFile_NameStr));
end
    

if IsNeedToDoScale
    disp('Checking Scale')
    %function [ FinalBestScale ] = DetermineBestScaleBetweenImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI,  ReImagedImage)
    [ IBSC_ScaleFactor ] = DetermineBestScaleBetweenImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI_Filtered,  CurrentImage_Filtered);
    save(IBSC_ScaleFactorFile_NameStr, 'IBSC_ScaleFactor');
    IBSC_ScaleFactor
end


[OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled] = ...
    EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI_Filtered, CurrentImage_Filtered, IBSC_ScaleFactor);

%Temporary resize
[fixY fixX] = size(OriginalImage_x3LargerROI_Filtered_Scaled);
fixY = round(fixY/3); fixX = round(fixX/3);

OriginalImage_x3LargerROI_Filtered_Scaled = OriginalImage_x3LargerROI_Filtered_Scaled(fixY+1:fixY*2,fixX+1:fixX*2);

AnglesInDegreesToTryArray = [-1, -0.5,0, .5, 1];;
disp('CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal')
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
    CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal(OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled, AnglesInDegreesToTryArray)


%%%%
% AnglesInDegreesToTryArray = [-1, -0.5,0, .5, 1];
% [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
%     CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI_Filtered, CurrentImage_Filtered, AnglesInDegreesToTryArray)

 

%KH new code start
ScanRot_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
Alpha_rad = (pi/180)*ScanRot_Degrees;
cosAlpha = cos(Alpha_rad);
sinAlpha = sin(Alpha_rad);
XOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*cosAlpha - YOffsetOfNewInPixels*sinAlpha;
YOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*sinAlpha + YOffsetOfNewInPixels*cosAlpha;
%KH new code end

%uiwait(msgbox('Inspect these...'));


%***********
%Use this offset to move the stage into optimal position to align
%with previous section's image
disp('HERE IS COMPUTED OFFSET:');
StageX_Microns_Offset = XOffsetOfNewInPixels_Transformed*MicronsPerPixel;
StageY_Microns_Offset = YOffsetOfNewInPixels_Transformed*MicronsPerPixel;
MyStr = sprintf('StageX_Microns_Offset = %d, StageY_Microns_Offset = %d',StageX_Microns_Offset, StageY_Microns_Offset);
disp(MyStr);
StageX_Meters_Offset = StageX_Microns_Offset/1000000;
StageY_Meters_Offset = StageY_Microns_Offset/1000000;

disp('Getting stage position');
StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g, )'...
    ,StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r, stage_m);
disp(MyStr);
disp(' ');


%%Log IBSC info
if ~exist(GuiGlobalsStruct.CurrentLogBook)
    logBook = logBookCreate;
    logBook = logScopeConditions(logBook);
end
logBook = logIBSC(logBook,StageX_Microns_Offset,StageY_Microns_Offset, AngleOffsetOfNewInDegrees,...
    FigureOfMerit,XOffsetOfNewInPixels, YOffsetOfNewInPixels)


%%Check for succesful match
goodMatch = (abs(StageX_Meters_Offset)<250e-6) && (abs(StageY_Meters_Offset)<250e-6) && (FigureOfMerit > 0.4)
%%
%do not apply this offset if greater than 250 microns (If we are greater
%than 250 microns off than the IBSC is probably screwing up

    disp(sprintf('******** IBSC offsets are less than 250um, performing stage movement ********'));
    
    StageX_Meters = StageX_Meters - StageX_Meters_Offset;
    StageY_Meters = StageY_Meters - StageY_Meters_Offset;
    
    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
    disp(MyStr);
    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.1)
    end
    pause(1)
    wmBackLash
    
%     GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_STAGE_BACKLASH');
%     while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
%         pause(.1)
%     end
%     pause(1);
    
if ~goodMatch
    disp(sprintf('********!!! IBSC faild to find match********'));
    
end

%undo the removal of the montage north angle scan rotation
ScanRot_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
ScanRot_Degrees = ScanRot_Degrees - GuiGlobalsStruct.MontageTarget.MontageNorthAngle; %has to be '-'?
%NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
while ScanRot_Degrees > 360
    ScanRot_Degrees = ScanRot_Degrees - 360;
end
while ScanRot_Degrees < 0
    ScanRot_Degrees = ScanRot_Degrees + 360;
end
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',ScanRot_Degrees);
GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(Stored_FOV_microns); %put back FOV

%%%%  Reset Brightness contrast for high res imaging
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Brightness',GuiGlobalsStruct.MontageParameters.ImageBrightness);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Contrast',GuiGlobalsStruct.MontageParameters.ImageContrast);


if exist('IBSC_Figure_Handle','var')
    if ishandle(IBSC_Figure_Handle)
        close(IBSC_Figure_Handle);
    end
end