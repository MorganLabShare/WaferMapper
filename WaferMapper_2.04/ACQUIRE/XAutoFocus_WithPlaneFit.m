function[ReturnedPlaneFitObject xFocusInfo] = XAutoFocus_WithPlaneFit%(RowDistanceBetweenTileCentersInMicrons, ColDistanceBetweenTileCentersInMicrons, SaveDir)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct;

% AutoFocusStartMag = 25000; %50000
% AutoFocusStartMag_ForStigGrid = 10000; %10000


%%  Simulate Montage Extremes

StageX_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
StageY_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');

NumRowTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileRows;
NumColTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileCols;
RowDistanceBetweenTileCentersInMicrons = GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons * ...
    (1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);
ColDistanceBetweenTileCentersInMicrons = GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons * ...
    (1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);


%Setup unit vectors in the
theta_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
theta_Radians = (pi/180)*theta_Degrees;
cosTheta = cos(theta_Radians);
sinTheta = sin(theta_Radians);

c_target_north_UnitVector = sinTheta;
r_target_north_UnitVector = -cosTheta;

c_target_east_UnitVector = cosTheta;
r_target_east_UnitVector = sinTheta;


tileCount = 0;
for RowIndex = [1 NumRowTiles] 
    for ColIndex = [1 NumColTiles]
        
        tileCount = tileCount+1;
        
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
                
                focusX(tileCount) = StageX_Meters;
                focusY(tileCount) = StageY_Meters;
    end
end

%%
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');


%% focus Stig focus on center point
centerX = mean(focusX);
centerY = mean(focusY);

GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(centerX,centerY,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash

StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
IsPerformAutoStig = true;
StartingMagForAS = round(StartingMagForAF/2);
focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;

centerFocusPosition = smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
centerWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');

%% focus on corners

for f = 1:length(focusX)
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',centerWD);
    
    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(focusX(f),focusY(f),stage_z,stage_t,stage_r,stage_m);
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.02)
    end
    wmBackLash
    
    IsPerformAutoStig = false;
    focOptions.IsDoQualCheck = false;
    focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
    
    cornerFocusPosition(f,:) = smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions);
    
    cornerWD(f,1) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
    
end

%% Check Corners

%%If the mean of diaganal extremes is much different then the center value,
%%Set the diaganals to equal the center value.

rawCorners = cornerWD;
abs((cornerWD(1)+cornerWD(4))/2-centerWD)*1000000

fitThresh = 100;
if (abs((cornerWD(1)+cornerWD(4))/2-centerWD)*1000000) > fitThresh
    cornerWD([1 4]) = centerWD;
    'poor fit'
end

if (abs((cornerWD(2)+cornerWD(3))/2-centerWD)*1000000) > fitThresh
    cornerWD([2 3]) = centerWD;
    'poor fit'
end


%% plane fit
allPoints = cat(1,centerFocusPosition,cornerFocusPosition);
allWD = cat(1,centerWD,cornerWD);



%generate plane fit object
ReturnedPlaneFitObject = fit( allPoints, allWD, 'poly11'); %'lowess'

%% Record Xfocusing
xFocusInfo.allPoints = allPoints;
xFousInfo.allWD = allWD;
xFocusInfo.rawCorners = rawCorners;
xFocusInfo.WDdif = (cornerWD - centerWD) * 1000000;


