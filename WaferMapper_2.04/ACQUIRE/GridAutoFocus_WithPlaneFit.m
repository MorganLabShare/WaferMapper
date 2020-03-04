function ReturnedPlaneFitObject = GridAutoFocus_WithPlaneFit(RowDistanceBetweenTileCentersInMicrons, ColDistanceBetweenTileCentersInMicrons, SaveDir)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct;

% AutoFocusStartMag = 25000; %50000
% AutoFocusStartMag_ForStigGrid = 10000; %10000

AutoFocusStartMag = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag; %50000
AutoFocusStartMag_ForStigGrid = round(AutoFocusStartMag/2); %10000

%Assume that this function is started with close to correct value for these
%(will be used for starting point of each below)
StartingPoint_WD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
StartingPoint_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
StartingPoint_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');

%Hard code to do 3x3 grid
NumRowTiles = 3; %3; %6 %3
NumColTiles = 3;%3; %6 %3
NumRowTiles_ForStig = 2; %2;
NumColTiles_ForStig = 2; %2;

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);
pause(.2);

%Get current stage position (this will be center of montage)
StageX_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
StageY_Meters_CenterOfMontage = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');


%Setup unit vectors in the 
theta_Degrees = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
theta_Radians = (pi/180)*theta_Degrees;
cosTheta = cos(theta_Radians);
sinTheta = sin(theta_Radians);
    
c_target_north_UnitVector = sinTheta;
r_target_north_UnitVector = -cosTheta;

c_target_east_UnitVector = cosTheta;
r_target_east_UnitVector = sinTheta;

GuiGlobalsStruct.WD_StageX_array = [];
GuiGlobalsStruct.WD_StageY_array = [];
GuiGlobalsStruct.WD_array = [];
GuiGlobalsStruct.StigX_array = [];
GuiGlobalsStruct.StigY_array = [];


%*** START: This sequence is desigend to release the SEM from Fibics control
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(.5); %1
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
pause(.5); %1
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPoint_WD);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',StartingPoint_StigX);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',StartingPoint_StigY);
pause(.5); %1
%*** END

%%%% START: STIG GRID
IsDoStigGrid = true;
WD_array_DerivedFromFromStigGrid = [];
if IsDoStigGrid
    %First do grid for stigs (fills StigX_array and Stigy_array arrays)
    for RowIndex = 1:NumRowTiles_ForStig
        for ColIndex = 1:NumColTiles_ForStig
            
            TileCenterRowOffsetInMicrons = (RowIndex -((NumRowTiles_ForStig+1)/2)) * RowDistanceBetweenTileCentersInMicrons;
            TileCenterColOffsetInMicrons = (ColIndex -((NumColTiles_ForStig+1)/2)) * ColDistanceBetweenTileCentersInMicrons;
            
            RowOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_north_UnitVector + ...
                TileCenterColOffsetInMicrons*c_target_north_UnitVector;
            ColOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_east_UnitVector +...
                TileCenterColOffsetInMicrons*c_target_east_UnitVector;
            
            StageX_Meters = StageX_Meters_CenterOfMontage - ColOffsetInMicrons/1000000;
            StageY_Meters = StageY_Meters_CenterOfMontage - RowOffsetInMicrons/1000000;
            
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            disp(MyStr);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            %Make sure we start at original ~good values
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPoint_WD);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',StartingPoint_StigX);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',StartingPoint_StigY);
            pause(.5); %1
            
            
            Original_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
            Original_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
            
            %%%%% START: OLD CODE %%%%%
                        %*** Auto focus
                        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',AutoFocusStartMag_ForStigGrid); %10000
                        pause(.5); %1
                        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
                        pause(.5); %1
                        disp('Auto Focusing...');
                        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
                            pause(.2);  %.5
                            %disp('Auto Focusing...');
                        end
                        pause(.5); %1
            
                        %*** Auto stig
                        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_STIG');
                        pause(.5); %1
                        disp('Auto Stig...');
                        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
                            pause(.2); %.5
                            %disp('Auto Stig...');
                        end
                        pause(.5); %1
            %             %%%%% END: OLD CODE %%%%%
            
            %new code
%             StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
%             IsNeedToReleaseFromFibics = false;
%             IsPerformAutoStig = true;
%             StartingMagForAS = round(StartingMagForAF/2);
%             focOptions.IsDoQualCheck = GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF;
%             focOptions.QualityThreshold = GuiGlobalsStruct.MontageParameters.AFQualityThreshold;
%             Perform_AF_or_AFASAF(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, focOptions, IsNeedToReleaseFromFibics);
          
            
            
            %%% CHECK IF STIG WENT OUT OF NORMAL RANGE %%%
            %             if  (1 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X') - 1.5)) ||...
            %                     (1 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y') - (-2.1)))
            if  (5 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X') - 0.4)) ||...   %1.5
                    (5 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y') - (0.6)))  %(-2.1)
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',Original_StigX);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',Original_StigY);
            end
            
            
            GuiGlobalsStruct.StigX_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
            GuiGlobalsStruct.StigY_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
            WD_array_DerivedFromFromStigGrid(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        end
    end
    
    
    %compute the stig value from above and set these for rest of time
    StigX_median = median(reshape(GuiGlobalsStruct.StigX_array,1,NumRowTiles_ForStig*NumColTiles_ForStig));
    StigY_median = median(reshape(GuiGlobalsStruct.StigY_array,1,NumRowTiles_ForStig*NumColTiles_ForStig));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',StigX_median);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',StigY_median);
    
    %   Pick best stig val
    Xstigs = GuiGlobalsStruct.StigX_array(:);
    Ystigs = GuiGlobalsStruct.StigY_array(:);
    stigDist = sqrt((Xstigs - median(Xstigs)).^2 + (Ystigs - median(Ystigs)).^2);
    bestStig = find(stigDist == min(stigDist),1);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',Xstigs(bestStig));
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',Ystigs(bestStig));
    
    
    WD_median_DerivedFromFromStigGrid = median(reshape(WD_array_DerivedFromFromStigGrid, 1,NumRowTiles_ForStig*NumColTiles_ForStig));
    
end



%%%% END: STIG GRID

%Now do grid of auto focuses
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        
    
        TileCenterRowOffsetInMicrons = (RowIndex -((NumRowTiles+1)/2)) * RowDistanceBetweenTileCentersInMicrons;
        TileCenterColOffsetInMicrons = (ColIndex -((NumColTiles+1)/2)) * ColDistanceBetweenTileCentersInMicrons;
        
        RowOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_north_UnitVector + ...
            TileCenterColOffsetInMicrons*c_target_north_UnitVector;
        ColOffsetInMicrons = TileCenterRowOffsetInMicrons*r_target_east_UnitVector +...
            TileCenterColOffsetInMicrons*c_target_east_UnitVector;

        StageX_Meters = StageX_Meters_CenterOfMontage - ColOffsetInMicrons/1000000;
        StageY_Meters = StageY_Meters_CenterOfMontage - RowOffsetInMicrons/1000000;
        
        MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
        disp(MyStr);
        GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
        while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
            pause(.02)
        end
        wmBackLash
        GuiGlobalsStruct.WD_StageX_array(RowIndex, ColIndex) = StageX_Meters;
        GuiGlobalsStruct.WD_StageY_array(RowIndex, ColIndex) = StageY_Meters;
        

        %Make sure we start at original ~good value
        if IsDoStigGrid
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',WD_median_DerivedFromFromStigGrid); %+(3/1000000)*rand(1)use the value calculated above +/- 3 microns * rand
        else
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPoint_WD);
        end
        pause(.5); %1
        
        %*** Auto focus
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',AutoFocusStartMag); %10000 
        pause(.5); %1
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(.5); %1
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(.2); %.5
            disp('Auto Focusing...');
        end
        pause(.5); %1
        
        %Check if this is way off and repeat at same location if it is.
        %This is to overcome initial burn in problems
        WDResetThreshold = GuiGlobalsStruct.MontageParameters.WDResetThreshold;
        ResultingWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        if (abs(StartingPoint_WD - ResultingWorkingDistance) > WDResetThreshold) %if more than the working distance reset threshold try one more time
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPoint_WD);
            pause(.5); %1
            %*** Auto focus
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',AutoFocusStartMag); %10000
            pause(.5); %1
            GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
            pause(.5); %1
            while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
                pause(.2); %.5
                disp('Auto Focusing...');
            end
            pause(.5); %1
        end
        
        
        %record this WD
        GuiGlobalsStruct.WD_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        
        
        
        
    end
end

GuiGlobalsStruct.WD_PointsForPlaneFit_StageX = [];
GuiGlobalsStruct.WD_PointsForPlaneFit_StageY = [];
GuiGlobalsStruct.WD_PointsForPlaneFit_WD = [];

WD_median = median(reshape(GuiGlobalsStruct.WD_array,1,NumRowTiles*NumColTiles));
WD_mean = mean(reshape(GuiGlobalsStruct.WD_array,1,NumRowTiles*NumColTiles));
WD_std = std(reshape(GuiGlobalsStruct.WD_array,1,NumRowTiles*NumColTiles));
n = 0;
WD_accum = 0;
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        if abs(GuiGlobalsStruct.WD_array(RowIndex, ColIndex) - WD_median) < 20e-6 %any thing over 20 microns (used to be 5) off of median is considered an outlier and not used for plane fit%3*WD_std
            n = n+1;
            
            %record good points for plane fit
            GuiGlobalsStruct.WD_PointsForPlaneFit_StageX(n,1) = GuiGlobalsStruct.WD_StageX_array(RowIndex, ColIndex);
            GuiGlobalsStruct.WD_PointsForPlaneFit_StageY(n,1) = GuiGlobalsStruct.WD_StageY_array(RowIndex, ColIndex);
            GuiGlobalsStruct.WD_PointsForPlaneFit_WD(n,1) = GuiGlobalsStruct.WD_array(RowIndex, ColIndex);
        
            WD_accum = WD_accum + GuiGlobalsStruct.WD_array(RowIndex, ColIndex);
        end
    end
end

WD_mean = WD_accum/n;


%generate plane fit object
if length(GuiGlobalsStruct.WD_PointsForPlaneFit_StageX) >=3
    ReturnedPlaneFitObject = fit( [GuiGlobalsStruct.WD_PointsForPlaneFit_StageX, GuiGlobalsStruct.WD_PointsForPlaneFit_StageY], ...
        GuiGlobalsStruct.WD_PointsForPlaneFit_WD, 'poly11'); %'lowess'
else
    ReturnedPlaneFitObject = [];
end



GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',WD_median);
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',StigX_median);
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',StigY_median);


%MOVE BACK TO ORIGINAL POSITION
StageX_Meters = StageX_Meters_CenterOfMontage;
StageY_Meters = StageY_Meters_CenterOfMontage;

MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
disp(MyStr);
GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
    pause(.02)
end
wmBackLash
%Fields in GuiGlobalsStruct to save for InfoForGridAutoFocus
InfoForGridAutoFocus.WD_array = GuiGlobalsStruct.WD_array;
InfoForGridAutoFocus.StigX_array = GuiGlobalsStruct.StigX_array;
InfoForGridAutoFocus.StigY_array = GuiGlobalsStruct.StigY_array;
InfoForGridAutoFocus.WD_StageX_array = GuiGlobalsStruct.WD_StageX_array;
InfoForGridAutoFocus.WD_StageY_array = GuiGlobalsStruct.WD_StageY_array;
InfoForGridAutoFocus.WD_PointsForPlaneFit_StageX = GuiGlobalsStruct.WD_PointsForPlaneFit_StageX;
InfoForGridAutoFocus.WD_PointsForPlaneFit_StageY = GuiGlobalsStruct.WD_PointsForPlaneFit_StageY;
InfoForGridAutoFocus.WD_PointsForPlaneFit_WD = GuiGlobalsStruct.WD_PointsForPlaneFit_WD;
InfoForGridAutoFocusFileName = sprintf('%s\\InfoForGridAutoFocus.mat', SaveDir);
save(InfoForGridAutoFocusFileName, 'InfoForGridAutoFocus');

