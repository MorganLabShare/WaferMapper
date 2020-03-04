%UtilityScript_AnalizeRepeatedTakesOfFiducials

MainDirName = 'Z:\Hayworth\MasterUTSLDir\Cerebellum_JM_YR1C_ForPosTest_UTSL\w007\FiducialReimageTests';

XOffsetOfNewInPixels_Array = [];
YOffsetOfNewInPixels_Array = [];
TestNumArray = [];
n = 1;
for FiducialNum = 1:4
    
    ImageFileName = sprintf('Fiducial_0%d.tif', FiducialNum);
    DataFileName = sprintf('Fiducial_0%d.mat', FiducialNum);
    
    Trial01_ImageFileFullPath = sprintf('%s\\FiducialReimageTest01\\%s',MainDirName, ImageFileName);
    Fiducial01Image = imread(Trial01_ImageFileFullPath, 'tif');
    
    %Compare trials #2-#4 to trial #1
    for SubDirNum = 2:4
        SubDirName = sprintf('FiducialReimageTest0%d', SubDirNum);
        
        disp(sprintf('Fiducial# %d, SubDir# %d', FiducialNum, SubDirNum));
        DataFileFullPath = sprintf('%s\\%s\\%s',MainDirName, SubDirName, DataFileName);
        %disp(sprintf('     %s', DataFileFullPath));
        %         load(DataFileFullPath, 'Info');
        %         disp(sprintf('     Stage pos: (%d, %d)', Info.StageX_Meters, Info.StageY_Meters));
        
        CurrentTrial_ImageFileFullPath = sprintf('%s\\%s\\%s',MainDirName, SubDirName, ImageFileName);
        CurrentFiducialImage = imread(CurrentTrial_ImageFileFullPath, 'tif');
        
        AnglesInDegreesToTryArray = [0];
        [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = ...
            CalcPixelOffsetAndAngleBetweenTwoImages(Fiducial01Image, CurrentFiducialImage, AnglesInDegreesToTryArray);
        disp(sprintf('     XOffsetOfNewInPixels = %d, YOffsetOfNewInPixels = %d', XOffsetOfNewInPixels, YOffsetOfNewInPixels));
        XOffsetOfNewInPixels_Array(n) = XOffsetOfNewInPixels;
        YOffsetOfNewInPixels_Array(n) = YOffsetOfNewInPixels;
        TestNumArray(n) = n;
        n = n + 1;
    end
    
end

MicronsPerPixelConversionFactor = 0.25;

figure(1);
subplot(2,1,1);
plot(TestNumArray, MicronsPerPixelConversionFactor*XOffsetOfNewInPixels_Array);
title('X\_Offset\_Array');
ylabel('(microns)');
axis([1 12 -0.5 0.5])
subplot(2,1,2);
plot(TestNumArray, MicronsPerPixelConversionFactor*YOffsetOfNewInPixels_Array);
title('Y\_Offset\_Array');
ylabel('(microns)');
axis([1 12 -0.5 0.5])
xlabel('test number');

%Compute Statistics
MeanX = mean(MicronsPerPixelConversionFactor*XOffsetOfNewInPixels_Array);
StdX = std(MicronsPerPixelConversionFactor*XOffsetOfNewInPixels_Array);
RangeX = max(MicronsPerPixelConversionFactor*XOffsetOfNewInPixels_Array) - min(MicronsPerPixelConversionFactor*XOffsetOfNewInPixels_Array);
MeanY = mean(MicronsPerPixelConversionFactor*YOffsetOfNewInPixels_Array);
StdY = std(MicronsPerPixelConversionFactor*YOffsetOfNewInPixels_Array);
RangeY = max(MicronsPerPixelConversionFactor*YOffsetOfNewInPixels_Array) - min(MicronsPerPixelConversionFactor*YOffsetOfNewInPixels_Array);

disp(sprintf('X: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanX, StdX, RangeX));
disp(sprintf('Y: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanY, StdY, RangeY));

%[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = CalcPixelOffsetAndAngleBetweenTwoImages(OriginalImage, NewImage, AnglesInDegreesToTryArray)

% Info = 
% 
%                   WaferName: ''
%                       Label: ''
%                 FOV_microns: 256
%             ReadFOV_microns: 256.1856
%               IsMagOverride: 0
%                         Mag: 446.2716
%          ImageWidthInPixels: 1024
%         ImageHeightInPixels: 1024
%     DwellTimeInMicroseconds: 2
%               StageX_Meters: 0.0201
%               StageY_Meters: 0.0778
%                     stage_z: 0.0250
%                     stage_t: 0
%                     stage_r: 2.9593e-005
%                     stage_m: 0
%                ScanRotation: 359.9930
%             WorkingDistance: 0.0095
%                  Brightness: 66.8620
%                    Contrast: 47.7656
%                       StigX: 0.0850
%                       StigY: -1.4006
%               MontageTarget: [1x1 struct]