function GridAutoFocus(NumRowTiles, NumColTiles, RowDistanceBetweenTileCentersInMicrons, ColDistanceBetweenTileCentersInMicrons)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct;

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

GuiGlobalsStruct.WD_array = [];
GuiGlobalsStruct.StigX_array = [];
GuiGlobalsStruct.StigY_array = [];

for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        
        %%%% TAKE TILE IMAGE
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
        
        %*** START: This sequence is desigend to release the SEM from Fibics control
        CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
        pause(1);
        %*** END
        
        %*** Auto focus
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',10000); %10000 KHKHKH
        pause(1);
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(1);
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(.5);
            disp('Auto Focusing...');
        end
        pause(1);
        
        Original_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
        Original_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
        
        %*** Auto stig
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_STIG');
        pause(1);
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(.5);
            disp('Auto Stig...');
        end
        pause(1);
        
        %%% CHECK IF STIG WENT OUT OF NORMAL RANGE %%%
        if  (1 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X') - 1.5)) ||...
                (1 < abs(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y') - (-2.1)))
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',Original_StigX);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',Original_StigY);
        end
            
        
        %*** Auto focus
        GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
        pause(1);
        while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
            pause(.5);
            disp('Auto Focusing...');
        end
        
        GuiGlobalsStruct.WD_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        GuiGlobalsStruct.StigX_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
        GuiGlobalsStruct.StigY_array(RowIndex, ColIndex) = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
        
        MyStr = sprintf('WD_array(%d, %d) = %d',RowIndex, ColIndex, GuiGlobalsStruct.WD_array(RowIndex, ColIndex));
        disp(MyStr);
        
        
        
    end
end


WD_mean = mean(reshape(GuiGlobalsStruct.WD_array,1,NumRowTiles*NumColTiles));
WD_std = std(reshape(GuiGlobalsStruct.WD_array,1,NumRowTiles*NumColTiles));
n = 0;
WD_accum = 0;
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        if abs(GuiGlobalsStruct.WD_array(RowIndex, ColIndex) - WD_mean) < 3*WD_std
            n = n+1;
            WD_accum = WD_accum + GuiGlobalsStruct.WD_array(RowIndex, ColIndex);
        end
    end
end
if n > 0
    WD_mean = WD_accum/n;
else
    disp('All WD measurements outside three standard deviations');
end

StigX_mean = mean(reshape(GuiGlobalsStruct.StigX_array,1,NumRowTiles*NumColTiles));
StigX_std = std(reshape(GuiGlobalsStruct.StigX_array,1,NumRowTiles*NumColTiles));
n = 0;
StigX_accum = 0;
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        if abs(GuiGlobalsStruct.StigX_array(RowIndex, ColIndex) - StigX_mean) < 3*StigX_std
            n = n+1;
            StigX_accum = StigX_accum + GuiGlobalsStruct.StigX_array(RowIndex, ColIndex);
        end
    end
end
if n > 0
    StigX_mean = StigX_accum/n;
else
    disp('All StigX measurements outside three standard deviations');
end

StigY_mean = mean(reshape(GuiGlobalsStruct.StigY_array,1,NumRowTiles*NumColTiles));
StigY_std = std(reshape(GuiGlobalsStruct.StigY_array,1,NumRowTiles*NumColTiles));
n = 0;
StigY_accum = 0;
for RowIndex = 1:NumRowTiles
    for ColIndex = 1:NumColTiles
        if abs(GuiGlobalsStruct.StigY_array(RowIndex, ColIndex) - StigY_mean) < 3*StigY_std
            n = n+1;
            StigY_accum = StigY_accum + GuiGlobalsStruct.StigY_array(RowIndex, ColIndex);
        end
    end
end
if n > 0
    StigY_mean = StigY_accum/n;
else
    disp('All StigY measurements outside three standard deviations');
end

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',WD_mean);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',StigX_mean);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',StigY_mean);


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


