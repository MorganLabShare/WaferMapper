%function[] = GoToMontageTargetPointRotationAndFOV()

global GuiGlobalsStruct

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

disp('Turning stage backlash ON in X and Y');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);

mtpr=GuiGlobalsStruct.MontageTarget.r
mtpc=GuiGlobalsStruct.MontageTarget.c


%%%START: NEW CODE
r_TP = GuiGlobalsStruct.MontageTarget.r - (0.5+(GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels/2)); %distance of TP from center of overview image
c_TP = GuiGlobalsStruct.MontageTarget.c - (0.5+(GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels/2));
r_OA = GuiGlobalsStruct.MontageTarget.Alignment_r_offset; %offset between defined TP and next section generated from the alignment algorithm
c_OA = GuiGlobalsStruct.MontageTarget.Alignment_c_offset;
if isfield(GuiGlobalsStruct.MontageTarget, 'AlignedTargetList_r_offset') %values from manual check and correct alignment gui
    r_ROI = -GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset;
    c_ROI = -GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset;
else
    r_ROI = 0;
    c_ROI = 0;
end




if isfield(GuiGlobalsStruct, 'MicronsPerPixel_FromCalibration_ForOverviewImages')
    MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MicronsPerPixel_FromCalibration_ForOverviewImages
else
    MicronsPerPixel_FromCalibration = GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
end



ROffset = (r_TP + r_ROI - r_OA); %should this be rtp+rroi+roa??q
COffset = (c_TP + c_ROI - c_OA);

x_pixels = -COffset;
y_pixels = ROffset;


%Then apply a rotation of this 
theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees; 
cosTheta = cos(theta_rad);
sinTheta = sin(theta_rad);
x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;

%%%END: NEW CODE

%%%%
%micronsperpixel = MicronsPerPixel_FromCalibration/1000000
%deltatx =x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000)
%%%%


%now convert this to stage coordinates
StageX_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview ;
StageY_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview;
StageX_Meters = StageX_Meters_CenterOriginalOverview + ...
    x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000) %NOTE used to be '-' changed 6-16-2011
StageY_Meters = StageY_Meters_CenterOriginalOverview + ...
    y_prime_pixels*(MicronsPerPixel_FromCalibration/1000000) %NOTE used to be '-' changed 6-16-2011

%Note: This function already applies the stage correction transformation
%and angle correction
ScanRot_Degrees = -GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees -...
    GuiGlobalsStruct.MontageTarget.MontageNorthAngle;



%NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
while ScanRot_Degrees > 360
    ScanRot_Degrees = ScanRot_Degrees - 360;
end

while ScanRot_Degrees < 0
    ScanRot_Degrees = ScanRot_Degrees + 360;
end

%%%%
% StageX_Meters= StageX_Meters-0.0002;
% StageY_Meters= StageY_Meters-0.0001;
%%%%

MoveStageToTargetWithScanRot(StageX_Meters, StageY_Meters, ScanRot_Degrees);

%EXIST('A','var')
if exist('handles', 'var')
    UpdateFullWaferDisplay(handles);
end

%Set fibics FOV to match target montage width
FOV_microns = GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons;
GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
pause(0.5);
GuiGlobalsStruct.MyCZEMAPIClass.Fibics_ReadFOV();




