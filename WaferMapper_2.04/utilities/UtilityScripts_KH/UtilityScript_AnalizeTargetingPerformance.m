function UtilityScript_AnalizeTargetingPerformance()



%DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
WaferDirName = uigetdir('Z:\Hayworth\MasterUTSLDir\Cerebellum_JM_YR1C_ForPosTest_UTSL', 'Select wafer directory ''e.g. w007''');
if isequal(WaferDirName,0) 
    disp('User pressed cancel');
    return;
else
    disp(sprintf('User selected: %s', WaferDirName));
end

SectionOverviewsDirectory = sprintf('%s\\SectionOverviewsDirectory', WaferDirName);
SectionOverviewsAlignedWithTemplateDirectory = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory', WaferDirName);


PixelToStageCalibrationDirectory = sprintf('%s\\PixelToStageCalibrationDirectory', WaferDirName);
CalibrationFileName = sprintf('%s\\CalibrationFile.mat',PixelToStageCalibrationDirectory);
load(CalibrationFileName, 'MicronsPerPixel_FromCalibration', 'MicronsPerPixel_FromFibicsReadFOV');
MicronsPerPixel_FromCalibration
MicronsPerPixel_FromFibicsReadFOV


SectionNum = 1;

while true
    SectionOverview_DataFileName = sprintf('%s\\SectionOverview_%d.mat',SectionOverviewsDirectory,SectionNum);
    SectionOverviewAligned_DataFileName = sprintf('%s\\SectionOverviewAligned_%d.mat',SectionOverviewsAlignedWithTemplateDirectory,SectionNum);
    
    if exist(SectionOverviewAligned_DataFileName, 'file')
        disp(sprintf('Loading file: %s', SectionOverview_DataFileName));
        load(SectionOverview_DataFileName, 'Info');
        Section_Array(SectionNum).Info = Info;
        %         WaferName: ''
        %                       Label: '164'
        %                 FOV_microns: 4500
        %             ReadFOV_microns: 4.5128e+003
        %               IsMagOverride: 0
        %                         Mag: 25.3342
        %          ImageWidthInPixels: 4096
        %         ImageHeightInPixels: 4096
        %     DwellTimeInMicroseconds: 1.5000
        %               StageX_Meters: 0.0210
        %               StageY_Meters: 0.0418
        %                     stage_z: 0.0250
        %                     stage_t: 0
        %                     stage_r: 2.9593e-005
        %                     stage_m: 0
        %                ScanRotation: 0
        %             WorkingDistance: 0.0094
        %                  Brightness: 72.3321
        %                    Contrast: 56.0928
        %                       StigX: 0.0681
        %                       StigY: -0.5980
        %               MontageTarget: [1x1 struct]

        
        disp(sprintf('Loading file: %s', SectionOverviewAligned_DataFileName));
        load(SectionOverviewAligned_DataFileName, 'AlignmentParameters')
        Section_Array(SectionNum).AlignmentParameters = AlignmentParameters;
        
        
%         % AlignmentParameters =
%         %
%         %                 r_offset: -173.1808
%         %                 c_offset: 163.0473
%         %     AngleOffsetInDegrees: -1
%         


        SectionNum_Array(SectionNum) = SectionNum;
        StageX_Meters_Array(SectionNum) = Info.StageX_Meters;
        StageY_Meters_Array(SectionNum) = Info.StageY_Meters;
        
        %%%%%%%%%
        r_OA = AlignmentParameters.r_offset;
        c_OA = AlignmentParameters.c_offset;
        ROffset = - r_OA; %(r_TP + r_ROI - r_OA);
        COffset = - c_OA; %(c_TP + c_ROI - c_OA);
        x_pixels = -COffset;
        y_pixels = ROffset;
        
        %Then apply a rotation of this
        theta_rad = (pi/180)*AlignmentParameters.AngleOffsetInDegrees;
        cosTheta = cos(theta_rad);
        sinTheta = sin(theta_rad);
        x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
        y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;
        
        StageX_AfterAlignment_Meters = Info.StageX_Meters + ...
            x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000); 
        StageY_AfterAlignment_Meters = Info.StageY_Meters + ...
            y_prime_pixels*(MicronsPerPixel_FromCalibration/1000000); 
        
        StageX_AfterAlignment_Meters_Array(SectionNum) = StageX_AfterAlignment_Meters;
        StageY_AfterAlignment_Meters_Array(SectionNum) = StageY_AfterAlignment_Meters;
        
        r_offset_Array(SectionNum) = AlignmentParameters.r_offset;
        c_offset_Array(SectionNum) = AlignmentParameters.c_offset;
        AngleOffsetInDegrees_Array(SectionNum) = AlignmentParameters.AngleOffsetInDegrees;
        
        
        SectionNum = 1 + SectionNum;
    else
        disp('No more sections to process.');
        break;
    end
    

    
end

figure(1000);
subplot(3,1,1);
plot(SectionNum_Array, 1000*StageX_Meters_Array, 'r');
hold on;
plot(SectionNum_Array, 1000*StageY_Meters_Array, 'b');
hold off;
title('Stage Position in mm: X = red, Y = blue');
ylabel('(mm)');


MicronsPerPixelConversionFactor = Section_Array(1).Info.FOV_microns/Section_Array(1).Info.ImageWidthInPixels

subplot(3,1,2);
plot(SectionNum_Array, MicronsPerPixelConversionFactor*r_offset_Array, 'r');
hold on;
plot(SectionNum_Array, MicronsPerPixelConversionFactor*c_offset_Array, 'b');
hold off;
title('Section Overview Alignment: r_offset = red, c_offset = blue','Interpreter','none');
ylabel('(microns)');


%Compute Statistics
MeanX = mean(MicronsPerPixelConversionFactor*c_offset_Array);
StdX = std(MicronsPerPixelConversionFactor*c_offset_Array);
RangeX = max(MicronsPerPixelConversionFactor*c_offset_Array) - min(MicronsPerPixelConversionFactor*c_offset_Array);
MeanY = mean(MicronsPerPixelConversionFactor*r_offset_Array);
StdY = std(MicronsPerPixelConversionFactor*r_offset_Array);
RangeY = max(MicronsPerPixelConversionFactor*r_offset_Array) - min(MicronsPerPixelConversionFactor*r_offset_Array);

disp(sprintf('X: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanX, StdX, RangeX));
disp(sprintf('Y: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanY, StdY, RangeY));


subplot(3,1,3);
plot(SectionNum_Array, AngleOffsetInDegrees_Array);
title('Section Overview Alignment: AngleOffsetInDegrees');
ylabel('(deg)');
xlabel('Section Number');

figure(2000);
hold on;
for SectionNum = 1:length(StageX_Meters_Array)
    r_SectionOverviewCenter = -1000*StageY_Meters_Array(SectionNum); %converting to mm
    c_SectionOverviewCenter = -1000*StageX_Meters_Array(SectionNum);
    
    r_SectionOverviewAlignedCenter = -1000*StageY_AfterAlignment_Meters_Array(SectionNum); %converting to mm
    c_SectionOverviewAlignedCenter = -1000*StageX_AfterAlignment_Meters_Array(SectionNum);
    
    r_delta = r_SectionOverviewAlignedCenter - r_SectionOverviewCenter;
    c_delta = c_SectionOverviewAlignedCenter - c_SectionOverviewCenter;
    
    PlotScaling = 20;
    h1 = line([c_SectionOverviewCenter-1, c_SectionOverviewCenter+1],[r_SectionOverviewCenter, r_SectionOverviewCenter]);
    h2 = line([c_SectionOverviewCenter, c_SectionOverviewCenter],[r_SectionOverviewCenter-1, r_SectionOverviewCenter+1]);
    h4 = line([c_SectionOverviewCenter c_SectionOverviewCenter+(PlotScaling * c_delta)],...
        [r_SectionOverviewCenter r_SectionOverviewCenter+(PlotScaling * r_delta)]);
    set(h1,'Color',[1 0 0]);
    set(h2,'Color',[1 0 0]);
    set(h4,'Color',[0 0 1]);
    
    TextStr = sprintf('%d',SectionNum);
    h3 = text(c_SectionOverviewCenter, r_SectionOverviewCenter, TextStr);
    set(h3,'Color',[1 0 0]);
end
axis equal;
hold off;
xlabel('mm');
ylabel('mm');
   
%Copy of code that WaferMapper uses to move to target point
% ROffset = (r_TP + r_ROI - r_OA);
% COffset = (c_TP + c_ROI - c_OA);
% 
% x_pixels = -COffset;
% y_pixels = ROffset;
% 
% 
% %Then apply a rotation of this 
% theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees; 
% cosTheta = cos(theta_rad);
% sinTheta = sin(theta_rad);
% x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
% y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;
% 
% %%%END: NEW CODE
% 
% %now convert this to stage coordinates
% StageX_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview; 
% StageY_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview;
% StageX_Meters = StageX_Meters_CenterOriginalOverview + ...
%     x_prime_pixels*(MicronsPerPixel_FromCalibration/1000000); %NOTE used to be '-' changed 6-16-2011
% StageY_Meters = StageY_Meters_CenterOriginalOverview + ...
%     y_prime_pixels*(MicronsPerPixel_FromCalibration/1000000); %NOTE used to be '-' changed 6-16-2011            




