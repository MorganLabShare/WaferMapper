clear all;


MyDir = 'Z:\Hayworth\MasterUTSLDir\DummyTestUTSL\w007';
D = dir(MyDir);


NewArray = [];
n = 1;
for i =1:length(D)
    SubDir = D(i).name;
    if length(SubDir) >= length('PixelToStageCalibrationDirectory');
        disp(sprintf('%s',D(i).name));
        FileName = sprintf('%s\\%s\\PixelToStageCalibrationImage.mat',MyDir,SubDir);
        load(FileName, 'Info');
        
        %This is what is stored in CalibrationFile.mat file
        %save(CalibrationFileNameStr, 'MicronsPerPixel_FromCalibration', 'MicronsPerPixel_FromCalibration_XDir', 'MicronsPerPixel_FromCalibration_YDir', 'MicronsPerPixel_FromFibicsReadFOV');
        FileName_ForCalibrationFile = sprintf('%s\\%s\\CalibrationFile.mat',MyDir,SubDir);
        load(FileName_ForCalibrationFile);
        
        
        DateNumArray(n) = D(i).datenum;
        NewArray(n).name = D(i).name;
        NewArray(n).DateNum = D(i).datenum;
        NewArray(n).Info = Info;
        NewArray(n).MicronsPerPixel_FromCalibration = MicronsPerPixel_FromCalibration;
        NewArray(n).MicronsPerPixel_FromCalibration_XDir = MicronsPerPixel_FromCalibration_XDir;
        NewArray(n).MicronsPerPixel_FromCalibration_YDir = MicronsPerPixel_FromCalibration_YDir;
        NewArray(n).MicronsPerPixel_FromFibicsReadFOV = MicronsPerPixel_FromFibicsReadFOV;


        n = n + 1;
    end
end

disp(' ');
disp('**************');
disp(' ');

[SortedDateNumArray SortedIndexArray] = sort(DateNumArray);
for i = 1:length(SortedIndexArray)
    MyIndex = SortedIndexArray(i);
    
    TimeArray_MinutesFromFirst(i) = 24*60*(NewArray(MyIndex).DateNum - NewArray(SortedIndexArray(1)).DateNum);
    WD_Array(i) = 1000*NewArray(MyIndex).Info.WorkingDistance;
    Mag_Array(i) = NewArray(MyIndex).Info.Mag;
    ReadFOV_microns_Array(i) = NewArray(MyIndex).Info.ReadFOV_microns;
    MicronsPerPixel_FromCalibration_Array(i) = NewArray(MyIndex).MicronsPerPixel_FromCalibration;
    MicronsPerPixel_FromFibicsReadFOV_Array(i) = NewArray(MyIndex).MicronsPerPixel_FromFibicsReadFOV;
    
    PercentCalFromFibics_Array(i) = 100*((NewArray(MyIndex).MicronsPerPixel_FromCalibration/NewArray(MyIndex).MicronsPerPixel_FromFibicsReadFOV)-1);
    PercentMagDiffFromFirstMag_Array(i) = 100*((NewArray(MyIndex).Info.Mag/NewArray(SortedIndexArray(1)).Info.Mag)-1);
    
    CalculatedResolutionFromMag_Array(i) = (100*1000)/(NewArray(MyIndex).Info.Mag * 4096); 
    
    
    disp(sprintf('name = %s', NewArray(MyIndex).name));
    disp(sprintf('     WD = %dmm', WD_Array(i)));
    disp(sprintf('     Mag = %0.5g', Mag_Array(i)));
    disp(sprintf('     ReadFOV_microns = %d', ReadFOV_microns_Array(i)));

    
    
end

figure(1000);
subplot(5,1,1);
plot(TimeArray_MinutesFromFirst,WD_Array,'-o');
title('Working Distance (mm)');
ylabel('WD (mm)');

subplot(5,1,2);
plot(TimeArray_MinutesFromFirst,Mag_Array,'-o');
title('Magnification (read from SmartSEM API)');
ylabel('Mag');

subplot(5,1,3);
plot(TimeArray_MinutesFromFirst,MicronsPerPixel_FromFibicsReadFOV_Array,'b-o');
hold on;
plot(TimeArray_MinutesFromFirst,MicronsPerPixel_FromCalibration_Array,'r-o');
ylabel('Resol.(um/pix)');
title('Fibics Read um/pix(blue),   Calibration from stage move um/pix(red)');
ylabel('Resol.(um/pix)');
hold off;

subplot(5,1,4);
plot(TimeArray_MinutesFromFirst,PercentCalFromFibics_Array,'-o');
title('Error percent (Calibration resol. vs. Fibics resol.)');
ylabel('Error(%)');

subplot(5,1,5);
plot(TimeArray_MinutesFromFirst,PercentMagDiffFromFirstMag_Array,'-o');
title('Error percent (Mag vs. first mag)');
ylabel('Error(%)');

xlabel('Time (in minutes from first)');

figure(2000);
plot(TimeArray_MinutesFromFirst,MicronsPerPixel_FromFibicsReadFOV_Array,'b-o');
hold on;
plot(TimeArray_MinutesFromFirst,MicronsPerPixel_FromCalibration_Array,'r-o');
ylabel('Resol.(um/pix)');
plot(TimeArray_MinutesFromFirst,CalculatedResolutionFromMag_Array,'g-o');
title('Fibics Read um/pix(blue),   Calibration from stage move um/pix(red),   Calculated um/pix from Mag(green)');
ylabel('Resol.(um/pix)');
hold off;

% Info = 
% 
%                   WaferName: ''
%                       Label: ''
%                 FOV_microns: 4500
%             ReadFOV_microns: 4.5128e+003
%               IsMagOverride: 0
%                         Mag: 25.5990
%          ImageWidthInPixels: 4096
%         ImageHeightInPixels: 4096
%     DwellTimeInMicroseconds: 3
%               StageX_Meters: 0.0627
%               StageY_Meters: 0.0621
%                     stage_z: 0.0250
%                     stage_t: 0
%                     stage_r: 2.9593e-005
%                     stage_m: 0
%                ScanRotation: 0
%             WorkingDistance: 0.0094
%                  Brightness: 64.3712
%                    Contrast: 61.6117
%                       StigX: -0.2079
%                       StigY: -1.0727
%               MontageTarget: [1x1 struct]