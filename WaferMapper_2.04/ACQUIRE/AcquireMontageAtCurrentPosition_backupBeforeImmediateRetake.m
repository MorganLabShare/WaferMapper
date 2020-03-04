function[logBook] =  AcquireMontageAtCurrentPosition(WaferName, LabelStr,logBook)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct ;

%LogFile_WriteLine(['******Beginning section ' LabelStr])
bookName = GuiGlobalsStruct.CurrentLogBook ;


%%Determine if manual retake is required
doManualRetake = (sum(GuiGlobalsStruct.waferProgress.manualRetakeList == str2num(LabelStr)));


if exist([GuiGlobalsStruct.TempImagesDirectory '\watchQ.mat'])
    load([GuiGlobalsStruct.TempImagesDirectory '\watchQ.mat'], 'q')
else
    q.fileNum = 0;
end

tilesTaken = {};

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
pause(.2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get current stage position (this will be center of montage)
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


MontageDirName = sprintf('%s\\%s_Sec%s_Montage', GuiGlobalsStruct.TempImagesDirectory,WaferName, LabelStr);
if ~exist(MontageDirName,'dir')
    disp(sprintf('Creating directory: %s',MontageDirName));
    [success,message,messageid] = mkdir(MontageDirName);
end

StitchFigNum = 1234;
figure(StitchFigNum);
clf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pre allocate StageStitchedImage
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
%START: PERFORM AUTOFOCUS AT OFFSET POSITION
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage
    %Reset original WD + Stig
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
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if GuiGlobalsStruct.MontageParameters.IsPlaneFit
    %Reset original WD + Stig
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
    %Reset original WD + Stig
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
    [groupTiles focusPoints] = Focus_4square;  %return tiles belonging to a focus group and the location of their focus point in n by yx
    showDist = sqrt((focusPoints(1,1)-focusPoints(end,1)).^2 + (focusPoints(1,2)-focusPoints(end,2).^2))*1000;
    disp(sprintf('Max dist between focus points = %d',showDist))
    GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
    GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
        GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
else
    tileList = [];
    for RowIndex = 1:NumRowTiles
        for ColIndex = 1:NumColTiles
            tileList = cat(1,tileList,[RowIndex ColIndex]);
        end
    end
    groupTiles{1} = tileList;  %Generic tile list
end



%Store the WD directly after this GridAutoFocus command to use as starting
%point for all others
StartingPointWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
StartingPoint_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
StartingPoint_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');


StageX_Meters = StageX_Meters_CenterOfMontage;
StageY_Meters = StageY_Meters_CenterOfMontage;
MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
disp(MyStr);

GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash

%LogFile_WriteLine(sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters));
%END: PERFORM AUTOFOCUS AT OFFSET POSITION

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Take Montage Overview Image
IsTakeMontageOverviewImage = GuiGlobalsStruct.MontageParameters.IsAcquireOverviewImage;
if IsTakeMontageOverviewImage
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Montage Dropout
DropoutListFileName = sprintf('%s\\MontageTileDropOutList.txt',GuiGlobalsStruct.WaferDirectory);
if exist(DropoutListFileName,'file')
    DropOutListArray = dlmread(DropoutListFileName,',');
else
    DropOutListArray = [];
end
wmBackLash
%% Main montage loop
tileCount = 0;
for tileGroup = 1:    length(groupTiles)
    tileList = groupTiles{tileGroup}; %Generic tile list
    
    if GuiGlobalsStruct.MontageParameters.Is4square  % do four square focus
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
        if tileGroup == 1  % stig on first focus
            IsPerformAutoStig = true;
            StartingMagForAS = round(StartingMagForAF); %previously stiged at half resolution
            smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
            GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigX_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X'); %record this new value
            GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack(1+length(GuiGlobalsStruct.StigY_ArrayOfValuesRecordedSinceStartOfMontageStack)) = ...
                GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
        else
            IsPerformAutoStig = false;
            smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);

        end
        
    end
    
    
    for tL= 1:size(tileList,1)
        RowIndex = tileList(tL,1);
        ColIndex = tileList(tL,2);
        
        tileCount = tileCount+1;
        
        IsDropOut = false;
        [NumDropOuts, dummy] = size(DropOutListArray);
        for DropOutListIndex = 1:NumDropOuts
            if (DropOutListArray(DropOutListIndex, 1) == RowIndex) && (DropOutListArray(DropOutListIndex, 2) == ColIndex)
                IsDropOut = true;
            end
        end
        
        if ~IsDropOut
            
            ImageFileNameStr = sprintf('%s\\Tile_r%d-c%d_%s_sec%s.tif', MontageDirName, RowIndex, ColIndex, WaferName, zerobuf(LabelStr));
            
            
            if ~exist(ImageFileNameStr, 'file') | doManualRetake %do not take or move if already exists
                
                if  exist(ImageFileNameStr, 'file') %rename old tif to be retaken
                    NewFileName = [ImageFileNameStr(1:end-3) '_beforeManRetake.tif'];
                    movefile(ImageFileNameStr,NewFileName);
                end
                
                %%%% TAKE TILE IMAGE
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
                
                MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
                disp(MyStr);
                
                %move to tile and record current
                
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);
                GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
                while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                    
                    pause(.02)
                end
                wmBackLash
                
                
                
                %LogFile_WriteLine(sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters));
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Set the WD for this tile based on one of these three
                %options:
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
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                
                
                
                ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
                ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
                DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds; %.5;
                FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns; %4nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
                IsDoAutoRetakeIfNeeded = false;
                %Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
                %      FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
                IsMagOverride = false;
                MagForOverride = -1;
                WaferNameStr = WaferName;
                
                %%%ACQUIRE IMAGE
                
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
                    
                    while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
                        countCurrent = countCurrent+1;
                        if countCurrent<length(specimenCurrent)
                            specimenCurrent{countCurrent} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCM');
                            
                        end
                        pause(.1); %1
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
                
                %% Record qualities
                MyDownSampledImage = qualI;
                MyNewIndex = length(tilesTaken) + 1;
                tilesTaken{MyNewIndex} = ImageFileNameStr;% Add new image to list
                tilesTaken_RowNum(MyNewIndex) = RowIndex;
                tilesTaken_ColNum(MyNewIndex) = ColIndex;
                monQual(MyNewIndex) = qual.quality;
                disp(monQual)
                
                StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Text = ...
                    sprintf('%0.4g',qual.quality);
                if qual.quality >= GuiGlobalsStruct.MontageParameters.ImageQualityThreshold
                    StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [0 1 0];
                else
                    StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [1 0 0];
                end
                
                IsDisplay = true;
                if IsDisplay
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
                    imshow(256-StageStitchedImage,[0, 255]);
                    
                    
                    StageStitched_TextStringsArray(RowIndex, ColIndex).textX = StartC+(MaxSSTileC/2);
                    StageStitched_TextStringsArray(RowIndex, ColIndex).textY = StartR+(MaxSSTileR/2);
                    %StageStitched_TextStringsArray(RowIndex, ColIndex).Text = sprintf('(%d, %d)',RowIndex, ColIndex);
                    
                    
                    tic
                    UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray);
                    'finish display'
                    toc
                end %If Display
                %                 tic
                %                 safesave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')
                %                 'log after tile'
                %                 toc
            end %if file exists
            %         r_target_offset = r_target + TileCenterRowOffsetInPixels*r_target_north_UnitVector + TileCenterColOffsetInPixels*c_target_north_UnitVector;
            %         c_target_offset = c_target + TileCenterRowOffsetInPixels*r_target_east_UnitVector + TileCenterColOffsetInPixels*c_target_east_UnitVector;
            
        end
    end
end

%Save log file
safesave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')

%do update of ss display
figure(StitchFigNum);
clf;
imshow(256-StageStitchedImage,[0, 255]);
UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%RETAKE BAD IMAGES
if (GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage == true) & exist('monQual')
    
    %%Find bad files
    retakeTiles = {tilesTaken{find(monQual <= GuiGlobalsStruct.MontageParameters.ImageQualityThreshold)}}
    if (length(retakeTiles) > 0)
        
        %% Pick focus for retake
        if length(retakeTiles)<=5
            retakeFocusType = 1; % refocus individuals
        elseif length(retakeTiles) <(length(tilesTaken) * .75)
            retakeFocusType = 2; % plane fit X with stig in the middle
        else
            retakeFocusType = 3; % repeat focus stig focus for whole section
        end
        
        disp('About to retake the following tiles that did not pass the qual check:');
        for RetakeNum = 1:length(retakeTiles)
            disp(sprintf('   %s', retakeTiles{RetakeNum}));
        end
        disp(' ');
        
        if  retakeFocusType == 2  %% run an X plane fit
            %Reset original WD + Stig
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
        end  %if x focus
        
        if  retakeFocusType == 3 %% single FSF
            %Reset original WD + Stig
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
        end  %if 3 run single FSF
        
        
        
        for RetakeNum = 1:length(retakeTiles)
            for repeatRetake = 1:2  %try more than one retake
                
            ImageFileNameStr = retakeTiles{RetakeNum};
            DataFileNameStr = sprintf('%s.mat', ImageFileNameStr(1:length(ImageFileNameStr)-4));
            disp(sprintf('Retaking:   %s', ImageFileNameStr));
            LogFile_WriteLine(sprintf(' Retake %s', ImageFileNameStr));
            disp(sprintf('   Data file name:   %s', DataFileNameStr));
            
            %load in data file with position
            load(DataFileNameStr, 'Info');
            StageX_Meters = Info.StageX_Meters;
            StageY_Meters = Info.StageY_Meters;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %move to tile position
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            disp(MyStr);
            
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBacklash
            LogFile_WriteLine(sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %perform autofocus
            
            
            if repeatRetake == 1 
                
                
                if retakeFocusType == 1  % find individual focus for tile
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
                    pause(1); %1
                    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
                    IsPerformAutoStig = false; %false;
                    StartingMagForAS = StartingMagForAF; %round(StartingMagForAF/2);
                    focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
                    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
                    %%perform smart focus
                    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                    %Perform_AF_or_AFASAF(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                elseif retakeFocusType == 2  %grab focuses from Xfit
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
            else
                disp('First retake failed.  Refocussing with stig')
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',BestGuess_StigX);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',BestGuess_StigY);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
                pause(1); %1
                StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
                IsPerformAutoStig = true; %false;
                StartingMagForAS = StartingMagForAF; %round(StartingMagForAF/2);
                focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
                focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
                %%perform smart focus
                smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
                %Perform_AF_or_AFASAF(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
            end %if first retake
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %take image
            ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
            ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
            DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds; %.5;
            FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns; %4nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
            IsDoAutoRetakeIfNeeded = false;
            IsMagOverride = false;
            MagForOverride = -1;
            WaferNameStr = WaferName;
            LabelStr = LabelStr;
            
            %%Write to LogBook
            logBook = logImageInfo(logBook,ImageFileNameStr);
            logBook = logImageConditions(logBook,ImageFileNameStr);
            
            tic
            Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr,1);
            'acquire retake time'
            toc
            %%Wait for image to be finished
            
            tic
            if exist('acquisitionTime')
                pause(acquisitionTime + .1)
                sprintf('Waiting %.2f seconds for acquisition',acquisitionTime + .1)
            else
                startAcquisition = clock;
                while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
                    pause(.1); %1
                end
                stopAcquisition = clock;
                acquisitionTime = (datenum(stopAcquisition) - datenum(startAcquisition))*24 * 60 * 60
                
            end
            'wait time for retake'
            toc
            tic
            %% Check Quality
            checkFile = ImageFileNameStr;
            [qual qualI] = checkFileQual(checkFile);
            logBook = logQuality(logBook,checkFile,qual);
            MyDownSampledImage = qualI;
            MyNewIndex = find(strcmp(tilesTaken,checkFile),1);
            retakeQuality = qual.quality;
            monQual(MyNewIndex) = retakeQuality;
            
            'quality check time'
            toc
            tic
            StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Text = ...
                sprintf('%0.4g',qual.quality);
            if qual.quality >= GuiGlobalsStruct.MontageParameters.ImageQualityThreshold
                StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [0 1 0];
            else
                StageStitched_TextStringsArray(tilesTaken_RowNum(MyNewIndex), tilesTaken_ColNum(MyNewIndex)).Color = [1 0 0];
            end
            
            %Incorporate into stage stitched and display
            if IsDisplay
                %imread(ImageFileNameStr, 'tif', 'PixelRegion',{[START INCREMENT STOP], [START INCREMENT STOP]});
                MyImage = imread(ImageFileNameStr, 'tif', 'PixelRegion', {[1 Increment ImageHeightInPixels],[1 Increment ImageWidthInPixels]});
                
                %put in border. Remember this image is just for show, it
                %does not even compensate for the tile overlaps
                MyImage(1:BorderPixels,:) = 0;
                MyImage(end-BorderPixels+1:end,:) = 0;
                MyImage(:,1:BorderPixels) = 0;
                MyImage(:,end-BorderPixels+1:end) = 0;
                
                %Extract row anbd col numbers from file name
                A1 = findstr(ImageFileNameStr, 'Tile_r');
                RowStartIndex = A1(end)+ 6;
                A2 = findstr(ImageFileNameStr(RowStartIndex:end), '-c');
                RowEndIndex = RowStartIndex + A2(1) - 2;
                A3 = findstr(ImageFileNameStr, '-c');
                ColStartIndex = A3(end) + 2;
                A4 = findstr(ImageFileNameStr(ColStartIndex:end), '_');
                ColEndIndex = ColStartIndex + A4(1) - 2;
                RowStr = ImageFileNameStr(RowStartIndex:RowEndIndex);
                ColStr = ImageFileNameStr(ColStartIndex:ColEndIndex);
                RowIndex = str2num(RowStr);
                ColIndex = str2num(ColStr);
                
                
                
                [MaxSSTileR, MaxSSTileC] = size(MyImage);
                StartR = (MaxSSTileR*(RowIndex-1))+1;
                StartC = (MaxSSTileC*(ColIndex-1))+1;
                StageStitchedImage(StartR:StartR+MaxSSTileR-1, StartC:StartC+MaxSSTileC-1) = MyImage;
                figure(StitchFigNum);
                clf;
                title(MontageDirName);
                %subplot(NumRowTiles, NumColTiles, ColIndex + NumColTiles*(RowIndex-1));
                imshow(256-StageStitchedImage,[0, 255]);
                
                
                StageStitched_TextStringsArray(RowIndex, ColIndex).textX = StartC+(MaxSSTileC/2);
                StageStitched_TextStringsArray(RowIndex, ColIndex).textY = StartR+(MaxSSTileR/2);
                
                %check quality immediatly
                
                UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray);
                
                % break out of retake loop if quality is good enough
                if retakeQuality > GuiGlobalsStruct.MontageParameters.ImageQualityThreshold
                    break
                end
                
            end %repeat retake tile
            end %finish retake tile
            'retake display time'
            toc
        end  % run all retakes
        
        
    end  %if there are retakes to do
    
end % if retakes are permitted



StageStitchedImageFileNameStr = sprintf('%s\\StageStitched_%s_sec%s.tif', MontageDirName, WaferName, LabelStr);
imwrite(StageStitchedImage, StageStitchedImageFileNameStr, 'tif');

%if GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage == true
StageStitchedImageWithQualValsFileNameStr = sprintf('%s\\StageStitched_%s_sec%s_WithQualVals.tif', MontageDirName, WaferName, LabelStr);
saveas(StitchFigNum,StageStitchedImageWithQualValsFileNameStr,'tif');
%end


safesave([GuiGlobalsStruct.TempImagesDirectory '\logBooks\' bookName '.mat'],'logBook')
'log after tile'

%MOVE BACK TO ORIGINAL POSITION
StageX_Meters = StageX_Meters_CenterOfMontage;
StageY_Meters = StageY_Meters_CenterOfMontage;

MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
disp(MyStr);

GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
LogFile_WriteLine(sprintf('Moving stage to original position (%0.5g, %0.5g)',StageX_Meters,StageY_Meters));
wmBackLash


%% Check Current
if mod(str2num(LabelStr),20)==0
    checkCurrent(LabelStr)
    'checked Current'
end

end





function UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray)

for tR = 1:NumRowTiles
    for tC = 1:NumColTiles
        figure(StitchFigNum);
        
        textX = StageStitched_TextStringsArray(tR, tC).textX;
        textY = StageStitched_TextStringsArray(tR, tC).textY;
        MyText = StageStitched_TextStringsArray(tR, tC).Text;
        %TEXT(X,Y,'string')
        h = text(textX, textY, MyText);
        set(h,'Color', StageStitched_TextStringsArray(tR, tC).Color);
        set(h,'FontSize', 18);
    end
end

end

