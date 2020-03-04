


function[logBook] =  AcquireMontageAtCurrentPosition(WaferName, LabelStr,logBook)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct ;

%LogFile_WriteLine(['******Beginning section ' LabelStr])
bookName = GuiGlobalsStruct.CurrentLogBook ;


%%Determine if manual retake is required
doManualRetake = (sum(GuiGlobalsStruct.waferProgress.manualRetakeList == str2num(LabelStr)));

% 
% if exist([GuiGlobalsStruct.TempImagesDirectory '\watchQ.mat'])
%     load([GuiGlobalsStruct.TempImagesDirectory '\watchQ.mat'], 'q')
% else
%     q.fileNum = 0;
% end

tilesTaken = {};

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
pause(.2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get current stage position (this will be center of montage)
StageX_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
StageY_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
MyStr = sprintf('(In AcquireMontageAtCurrentPosition) Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g, )'...
    ,StageX_Meters_CenterOfMontage,StageY_Meters_CenterOfMontage,stage_z,stage_t,stage_r, stage_m);
disp(MyStr);
disp(' ');


%% Get relevant Montage parameters
RowDistanceBetweenTileCentersInMicrons = GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons * ...
    (1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);
ColDistanceBetweenTileCentersInMicrons = GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons * ...
    (1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);
NumRowTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileRows;
NumColTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileCols;

%Setup unit vectors in the
theta_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
theta_Radians = (pi/180)*theta_Degrees;
cosTheta = cos(theta_Radians);
sinTheta = sin(theta_Radians);

c_target_north_UnitVector = sinTheta;
r_target_north_UnitVector = -cosTheta;

c_target_east_UnitVector = cosTheta;
r_target_east_UnitVector = sinTheta;

ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds; %.5;
FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns; %4nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
IsDoAutoRetakeIfNeeded = false;
IsMagOverride = false;
MagForOverride = -1;
WaferNameStr = WaferName;

MontageDirName = sprintf('%s\\%s_Sec%s_Montage', GuiGlobalsStruct.TempImagesDirectory,WaferName, LabelStr);
if ~exist(MontageDirName,'dir')
    disp(sprintf('Creating directory: %s',MontageDirName));
    [success,message,messageid] = mkdir(MontageDirName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Montage Dropout
DropoutListFileName = sprintf('%s\\MontageTileDropOutList.txt',GuiGlobalsStruct.WaferDirectory);
if exist(DropoutListFileName,'file')
    'Using drop out list'
    DropOutListArray = dlmread(DropoutListFileName,',')
else
    DropOutListArray = [];
end

%% Get tile information
%listTileNames, listStageX_Meters, listStageY_Meters(t) ,listTakeImage(t)

allTiles = [];
%record rows, cols
for RowIndex = 1:NumRowTiles
    allTiles = cat(1,allTiles,[ones(NumColTiles,1)*RowIndex (1:NumColTiles)']);
end
for t = 1:size(allTiles,1)
    RowIndex = allTiles(t,1);
    ColIndex = allTiles(t,2);
    
    IsDropOut = false;
    [NumDropOuts, dummy] = size(DropOutListArray);
    for DropOutListIndex = 1:NumDropOuts
        if (DropOutListArray(DropOutListIndex, 1) == RowIndex) && (DropOutListArray(DropOutListIndex, 2) == ColIndex)
            IsDropOut = true;
        end
    end
    
    
    ImageFileNameStr = sprintf('%s\\Tile_r%d-c%d_%s_sec%s.tif', MontageDirName, RowIndex, ColIndex, WaferName, zerobuf(LabelStr));
    listTileNames{t} = ImageFileNameStr;  %record list of file names
    
    listTakeImage(t) = (~exist(ImageFileNameStr, 'file') | doManualRetake) & ~IsDropOut;
    
    %%%% GET IMAGE POSITIONs
    TileCenterRowOffsetInMicrons = (RowIndex -((NumRowTiles+1)/2)) * RowDistanceBetweenTileCentersInMicrons;
    TileCenterColOffsetInMicrons = (ColIndex -((NumColTiles+1)/2)) * ColDistanceBetweenTileCentersInMicrons;
    
    %Handle additional offset of full montage
    RowOffsetFromAlignTargetMicrons = -GuiGlobalsStruct.MontageTarget.YOffsetFromAlignTargetMicrons;
    ColOffsetFromAlignTargetMicrons = GuiGlobalsStruct.MontageTarget.XOffsetFromAlignTargetMicrons;
    TileCenterRowOffsetInMicrons = TileCenterRowOffsetInMicrons + RowOffsetFromAlignTargetMicrons;
    TileCenterColOffsetInMicrons = TileCenterColOffsetInMicrons + ColOffsetFromAlignTargetMicrons;
    
    RowOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_north_UnitVector + ...
        TileCenterColOffsetInMicrons*c_target_north_UnitVector;
    ColOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_east_UnitVector +...
        TileCenterColOffsetInMicrons*c_target_east_UnitVector;
    
    StageX_Meters = StageX_Meters_CenterOfMontage - ColOffsetInMicrons/1000000;
    StageY_Meters = StageY_Meters_CenterOfMontage - RowOffsetInMicrons/1000000;
    
    listStageX_Meters(t) = StageX_Meters;
    listStageY_Meters(t) = StageY_Meters;
end

groupTiles{1} = find(listTakeImage);  %Generic tile list

%%
StitchFigNum = 1234;
figure(StitchFigNum);
clf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pre allocate StageStitchedImage


ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels;
MaxSSTileR = 256;
Increment = floor(ImageWidthInPixels/MaxSSTileR); %produce 256x256 images
MaxSSTileC = MaxSSTileR; %tiles are square
StageStitchedImage = uint8(255*ones(MaxSSTileR*NumRowTiles, MaxSSTileC*NumColTiles));
DummyTile = 255*ones(MaxSSTileR, MaxSSTileC);
BorderPixels = 3;
DummyTile(1:BorderPixels,:) = 0;
DummyTile(end-BorderPixels+1:end,:) = 0;
DummyTile(:,1:BorderPixels) = 0;
DummyTile(:,end-BorderPixels+1:end) = 0;
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        StartR = (MaxSSTileR*(RowIndex-1))+1;
        StartC = (MaxSSTileC*(ColIndex-1))+1;
        StageStitchedImage(StartR:StartR+MaxSSTileR-1, StartC:StartC+MaxSSTileC-1) = DummyTile;
        
        StageStitched_TextStringsArray(RowIndex, ColIndex).textX = 0;
        StageStitched_TextStringsArray(RowIndex, ColIndex).textY = 0;
        StageStitched_TextStringsArray(RowIndex, ColIndex).Text= '';
        StageStitched_TextStringsArray(RowIndex, ColIndex).HandleToText = [];
        StageStitched_TextStringsArray(RowIndex, ColIndex).Color = [1 1 0];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% START: PERFORM AUTOFOCUS AT OFFSET POSITION
AFCenterRowOffsetInMicrons = -GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns;
AFCenterColOffsetInMicrons = GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns;

AFRowOffsetInMicrons = AFCenterRowOffsetInMicrons*r_target_north_UnitVector + ...
    AFCenterColOffsetInMicrons*c_target_north_UnitVector;
AFColOffsetInMicrons = AFCenterRowOffsetInMicrons*r_target_east_UnitVector +...
    AFCenterColOffsetInMicrons*c_target_east_UnitVector;

StageX_Meters = StageX_Meters_CenterOfMontage - AFColOffsetInMicrons/1000000;
StageY_Meters = StageY_Meters_CenterOfMontage - AFRowOffsetInMicrons/1000000;

MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
disp(MyStr);

GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash

%%start recording focus points
lastFocusPoint = [StageX_Meters StageY_Meters];

%LogFile_WriteLine(sprintf('Moving stage to x=%0.5g, y=%0.5g,scanrot=%5.5g',StageX_Meters,StageY_Meters, theta_Degrees));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage
    %Reset original WD
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
    pause(1);
    %PerformAutoFocus;
    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
    IsPerformAutoStig = false;
    StartingMagForAS = round(StartingMagForAF/2);
    focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
    
    lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage
    %reset original WD + Stig
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
    BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
    BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
    pause(1);
    %PerformAutoFocusStigFocus;
    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
    IsPerformAutoStig = true;
    StartingMagForAS = round(StartingMagForAF); %previously stiged at half resolution
    focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
    
    lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if GuiGlobalsStruct.MontageParameters.IsPlaneFit
    %reset original WD + Stig
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
    BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
    BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
    pause(1);
    RowDistanceBetweenTileCentersInMicrons_ForGridAutoFocus = GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons; %50; %150;
    ColDistanceBetweenTileCentersInMicrons_ForGridAutoFocus = GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons; %50; %150;
    
    ReturnedPlaneFitObject = GridAutoFocus_WithPlaneFit(RowDistanceBetweenTileCentersInMicrons_ForGridAutoFocus, ColDistanceBetweenTileCentersInMicrons_ForGridAutoFocus, MontageDirName);
    
    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
end


if GuiGlobalsStruct.MontageParameters.IsXFit
    %reset original WD + Stig
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
    BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
    BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
    pause(1);
    RowDistanceBetweenTileCentersInMicrons_ForGridAutoFocus = GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons; %50; %150;
    ColDistanceBetweenTileCentersInMicrons_ForGridAutoFocus = GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons; %50; %150;
    
    %ReturnedPlaneFitObject = GridAutoFocus_WithPlaneFit(RowDistanceBetweenTileCentersInMicrons_ForGridAutoFocus, ColDistanceBetweenTileCentersInMicrons_ForGridAutoFocus, MontageDirName);
    [ReturnedPlaneFitObject planeFitInfo] = XAutoFocus_WithPlaneFit
    planeFitInfo.section = LabelStr;
    if isfield(logBook,'planeFit')
        logBook.planeFit(length(logBook.planeFit)+1).planeFitInfo = planeFitInfo;
    else
        logBook.planeFit(1).planeFitInfo = planeFitInfo;
    end
    
    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
end


if GuiGlobalsStruct.MontageParameters.Is4square
    %% determine Tile order
    %% determine Focus points
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
    BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
    BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
    [groupTiles focusPoints] = Focus_4square(listStageX_Meters,listStageY_Meters,allTiles,listTakeImage);  %return tiles belonging to a focus group and the location of their focus point in n by yx
    
    showDist = sqrt((focusPoints(1,1)-focusPoints(end,1)).^2 + (focusPoints(1,2)-focusPoints(end,2).^2))*1000;
    disp(sprintf('Max dist between focus points = %d',showDist))
    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
    
end


%Store the WD directly after this GridAutoFocus command to use as starting
%point for all others
StartingPointWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
StartingPoint_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
StartingPoint_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');



%% Auto Brightness Contrast
% % if ~isfield(GuiGlobalsStruct.MontageParameters,'IsAutoBrightnessContrast')
% %     GuiGlobalsStruct.MontageParameters.IsAutoBrightnessContrast= 0;
% % end
% Force the Auto Brightness and Contrast to not happen for now
GuiGlobalsStruct.MontageParameters.IsAutoBrightnessContrast = 0;
if GuiGlobalsStruct.MontageParameters.IsAutoBrightnessContrast    
    
     %Reset original WD
     focBeforeAutoBC = 1;
     if focBeforeAutoBC
         GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',GuiGlobalsStruct.MontageParameters.AFStartingWD);
         pause(.1);
         %PerformAutoFocus;
         StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
         IsPerformAutoStig = false;
         StartingMagForAS = round(StartingMagForAF/2);
         focOptions.IsDoQualCheck = 0;%GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
         focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
         smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);         
         lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
             GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
     end
     
     disp('Checking Brightness Contrast')
     autoBrightCon
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Take Montage Overview Image
IsTakeMontageOverviewImage = GuiGlobalsStruct.MontageParameters.IsAcquireOverviewImage;
if IsTakeMontageOverviewImage
    
    StageX_Meters = StageX_Meters_CenterOfMontage;
    StageY_Meters = StageY_Meters_CenterOfMontage;
    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
    disp(MyStr);
    
    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.02)
    end
    wmBackLash
    
    FOV_microns = GuiGlobalsStruct.MontageParameters.MontageOverviewImageFOV_microns;
    ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.MontageOverviewImageWidth_pixels;
    ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.MontageOverviewImageHeight_pixels;
    DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.MontageOverviewImageDwellTime_microseconds
    IsDoAutoRetakeIfNeeded = false;
    IsMagOverride = false;
    MagForOverride = -1;
    WaferNameStr = WaferName;
    LabelStr = LabelStr;
    
    ImageFileNameStr = sprintf('%s\\MontageOverviewImage_%s_sec%s.tif', MontageDirName, WaferName, LabelStr);
    Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
        FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
    
end


%% Set up for retakes
if GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage
    numTileAttempts = 3;  %allow double retakes
else
    numTileAttempts = 1;
end
numRetakes = 0; % keep track of retakes per section


%% Main montage loop
tileCount = 0;
didStig = 0;
for tileGroup = 1:    length(groupTiles)
    tileList = groupTiles{tileGroup}; %Generic tile list
    tileList = nearestSpiral(tileList,0,listStageX_Meters,listStageY_Meters,lastFocusPoint);
    disp(['Tile list = ' sprintf('%d ',tileList)])

    
    if GuiGlobalsStruct.MontageParameters.Is4square & ~isempty(tileList) % do four square focus
        disp(sprintf('Going to focus point for focus group %d',tileGroup))
        %% Move to first focus point
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',150);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);
        GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(focusPoints(tileGroup,1),focusPoints(tileGroup,2),stage_z,stage_t,stage_r,stage_m);
        while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
            pause(.02)
        end
        wmBackLash
        pause(1)
        
        StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
        focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
        focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
        
        %% Focus for group
        
        if didStig  % stig on first focus
            IsPerformAutoStig = false;
            smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
            lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
        else
            IsPerformAutoStig = true;
            StartingMagForAS = round(StartingMagForAF); %previously stiged at half resolution
            smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
            GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
            GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
            lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
            didStig = 1; %remember that stig was done
        end
        
    end
    
    
    
    for t= 1:length(tileList)
        tL = tileList(t);
        RowIndex = allTiles(tL,1);
        ColIndex = allTiles(tL,2);
        
        tileCount = tileCount+1;
        
        ImageFileNameStr = listTileNames{tL};
        maxRetakeNum = 30; 
        if numRetakes>maxRetakeNum
            numTileAttempts = 1;
        end
        
        for tileAttempt = 1:numTileAttempts  %number of times to try taking good image
            if tileAttempt>2
                numRetakes = numRetakes + 1;
            end
            
            disp(sprintf('%s attempt number %d',ImageFileNameStr,tileAttempt))
%             if  exist(ImageFileNameStr, 'file') %rename old tif to be retaken
%                 NewFileName = [ImageFileNameStr(1:end-3) '_beforeManRetake.tif'];
%                 movefile(ImageFileNameStr,NewFileName);
%             end
            
            %move to tile and record current
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(listStageX_Meters(tL),listStageY_Meters(tL),stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            
            
            %% Double check possition
            
            actual_stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
            actual_stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
            if (actual_stage_x ~= listStageX_Meters(tL)) || (actual_stage_y ~= listStageY_Meters(tL))
                disp('Warning stage not in position, trying to move again')
                GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(listStageX_Meters(tL),listStageY_Meters(tL),stage_z,stage_t,stage_r,stage_m);
                while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                    pause(.02)
                end
                wmBackLash
            end
            
            
            %% Do autofocus if necessary
            if tileAttempt == 1;
                if GuiGlobalsStruct.MontageParameters.IsAFOnEveryTile
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
                    pause(1); %1
                    %PerformAutoFocus;
                    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
                    IsPerformAutoStig = false;
                    StartingMagForAS = round(StartingMagForAF/2);
                    focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
                    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
                    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                end
                
                if GuiGlobalsStruct.MontageParameters.IsAFASAFOnEveryTile
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
                    BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
                    BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
                    pause(1); %1
                    %PerformAutoFocusStigFocus;
                    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
                    IsPerformAutoStig = true;
                    StartingMagForAS = round(StartingMagForAF/2);
                    focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
                    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
                    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
                    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if GuiGlobalsStruct.MontageParameters.IsPlaneFit | GuiGlobalsStruct.MontageParameters.IsXFit
                    if ~isempty(ReturnedPlaneFitObject)
                        NewWD = ReturnedPlaneFitObject(StageX_Meters,StageY_Meters);
                        %NewWD = ReturnedPlaneFitObject(StageX_Meters_CenterOfMontage,StageY_Meters_CenterOfMontage); %KH THIS ONLY DOWS AVERAGE AT CENTER!!!!!!!!!
                        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',NewWD);
                        pause(1); %1
                    else
                        %%ErrorFileNameStr = sprintf('%s\\Error_PlaneFitReturnedEmptyMatrix_SkippingSection.mat', MontageDirName);
                        return; %KH added 11-14-2011 to skip entire section if plane fit failed
                    end
                end
            else % if image is a retake
                if tileAttempt <3
                    IsPerformAutoStig = false;
                else
                    IsPerformAutoStig = true;
                end
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
                BestGuess_StigX = median(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end))); %takes median value of last 5 stigs
                BestGuess_StigY = median(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack((max(1,end-(GuiGlobalsStruct.NumOfStigValuesToMedianOver-1)):end)));
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
                pause(1); %1
                %PerformAutoFocusStigFocus;
                StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
                StartingMagForAS = round(StartingMagForAF/2);
                focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
                focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
                smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                    GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
                GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                    GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
                lastFocusPoint = [GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X') ...
                    GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y')];
                tileList = nearestSpiral(tileList,t,listStageX_Meters,listStageY_Meters,lastFocusPoint)
                
            end
            
            %% ACQUIRE IMAGE
            
            logBook = logImageInfo(logBook,ImageFileNameStr);
            logBook = logImageConditions(logBook,ImageFileNameStr);
            
            Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr,1);
            
            pause(.01)
            
            
            %% Wait for Fibics to finish being busy
            
            if 0 %exist('acquisitionTime')
                pause(acquisitionTime + .1)
                sprintf('Waiting %.2f seconds for acquisition',acquisitionTime + .1)
            else
                startAcquisition = clock;
                specimenCurrent = cell(1,500);
                specimenCurrent{1} = ImageFileNameStr;
                countCurrent = 1;
                
                while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)  %% record current
                    countCurrent = countCurrent+1;
                    if countCurrent<length(specimenCurrent)
                        specimenCurrent{countCurrent} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCM');
                        
                    end
                    pause(1); %1
                end
                stopAcquisition = clock;
                acquisitionTime = (datenum(stopAcquisition) - datenum(startAcquisition))*24 * 60 * 60
                
                %log specimenCurrent
                if exist('logBook','var')
                    logBook.sheets.specimenCurrent.data(size( logBook.sheets.specimenCurrent.data,1)+1,...
                        1:length(specimenCurrent)) = (specimenCurrent);
                end
                
                
            end
            %GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);
            
            %% Check Quality
            tic
            checkFile = ImageFileNameStr;
            [qual qualI] = checkFileQual(checkFile);
            logBook = logQuality(logBook,checkFile,qual);
            'qualcheck'
            toc
            
            % Record qualities
            MyDownSampledImage = qualI;
            MyNewIndex = length(tilesTaken) + 1;
            tilesTaken{MyNewIndex} = ImageFileNameStr;% Add new image to list
            tilesTaken_RowNum(MyNewIndex) = RowIndex;
            tilesTaken_ColNum(MyNewIndex) = ColIndex;
            currentText = StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Text ;
            StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Text = ...
                sprintf('%0.3g %d',qual.quality,tileAttempt)
            if qual.quality >= GuiGlobalsStruct.MontageParameters.ImageQualityThreshold
                StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [0 1 0];
            else
                StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [1 0 0];
            end
            
            IsDisplay = true;
            if IsDisplay
                startDisplay = datenum(clock);
                %imread(ImageFileNameStr, 'tif', 'PixelRegion',{[START INCREMENT STOP], [START INCREMENT STOP]});
                MyImage = imread(ImageFileNameStr, 'tif', 'PixelRegion', {[1 Increment ImageHeightInPixels],[1 Increment ImageWidthInPixels]});
                
                %put in border. Remember this image is just for show, it
                %does not even compensate for the tile overlaps
                MyImage(1:BorderPixels,:) = 0;
                MyImage(end-BorderPixels+1:end,:) = 0;
                MyImage(:,1:BorderPixels) = 0;
                MyImage(:,end-BorderPixels+1:end) = 0;
                
                [MaxSSTileR, MaxSSTileC] = size(MyImage);
                StartR = (MaxSSTileR*(RowIndex-1))+1;
                StartC = (MaxSSTileC*(ColIndex-1))+1;
                StageStitchedImage(StartR:StartR+MaxSSTileR-1, StartC:StartC+MaxSSTileC-1) = MyImage;
                figure(StitchFigNum);
                clf;
                title(MontageDirName);
                %subplot(NumRowTiles, NumColTiles, ColIndex + NumColTiles*(RowIndex-1));
                imshow(256-StageStitchedImage,[0, 255],'InitialMagnification','fit');
                
                
                StageStitched_TextStringsArray(RowIndex, ColIndex).textX = StartC+(MaxSSTileC/2);
                StageStitched_TextStringsArray(RowIndex, ColIndex).textY = StartR+(MaxSSTileR/2);
                %StageStitched_TextStringsArray(RowIndex, ColIndex).Text = sprintf('(%d, %d)',RowIndex, ColIndex);
                StageStitched_TextStringsArray(RowIndex, ColIndex).title = LabelStr;

                tic
                UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray);
                tic
                StageStitchedImageWithQualValsFileNameStrForFigure = sprintf('%s\\StageStitched_%s_sec%s_WithQualVals.fig', MontageDirName, WaferName, LabelStr);
                
                %try save(StitchFigNum,StageStitchedImageWithQualValsFileNameStrForFigure)
                try saveas(StitchFigNum,StageStitchedImageWithQualValsFileNameStrForFigure,'fig');
                catch err
                    disp('failed to save stage stitched')
                end
                displayTime = (datenum(clock) - startDisplay)*24 * 60 *60;
                disp(sprintf('Display took %f seconds',displayTime));
            end %If Display
            
            %% break out of retake loop if passes quality check
            if qual.quality > GuiGlobalsStruct.MontageParameters.ImageQualityThreshold
                break
            end
        end %retake loop
    end %if file exists
    %         r_target_offset = r_target + TileCenterRowOffsetInPixels*r_target_north_UnitVector + TileCenterColOffsetInPixels*c_target_north_UnitVector;
    %         c_target_offset = c_target + TileCenterRowOffsetInPixels*r_target_east_UnitVector + TileCenterColOffsetInPixels*c_target_east_UnitVector;
    
end
%Save log file
safesave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')

%do update of ss display
figure(StitchFigNum);
clf;
imshow(256-StageStitchedImage,[0, 255],'InitialMagnification','fit');
tic
%%%%
%UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray);
%'UpdateTextOnStageStitched'
%%%%
toc
StageStitchedImageFileNameStr = sprintf('%s\\StageStitched_%s_sec%s.tif', MontageDirName, WaferName, LabelStr);
imwrite(StageStitchedImage, StageStitchedImageFileNameStr, 'tif');

%if GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage == true
StageStitchedImageWithQualValsFileNameStr = sprintf('%s\\StageStitched_%s_sec%s_WithQualVals.tif', MontageDirName, WaferName, LabelStr);
saveas(StitchFigNum,StageStitchedImageWithQualValsFileNameStr,'tif');
%end


safesave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')
'log after tile'

%% Check Current
if mod(str2num(LabelStr),1)==0
    checkCurrent(LabelStr)
    'checked Current'
end


