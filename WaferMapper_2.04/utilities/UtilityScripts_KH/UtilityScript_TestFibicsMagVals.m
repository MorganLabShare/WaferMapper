%UtilityScript_TestFibicsMagVals


ImageWidthInPixels = 1024;
ImageHeightInPixels = 1024;
DwellTimeInMicroseconds = 2;

FOV_microns = 360; %3200
IsDoAutoRetakeIfNeeded = false;
IsMagOverride = false;
MagForOverride = 100;
WaferNameStr = 'DummyWafer';
LabelStr = '1';



WD_Test_Array = linspace(8, 11, 13)/1000; %linspace(6, 13, 11)/1000;
WD_Read_Array = [];
FOV_microns_Array = [];
ReadFOV_microns_Array = [];
ResultingMag_Array = [];
for i=1:length(WD_Test_Array)
    
%     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',20000);
%     pause(1);
%     ImageWidthInPixels_ForDummy = 10000;
%     DwellTimeInMicroseconds_ForDummy = 0.1;
%     FOV_microns_ForDummy = 40;
%     Fibics_AcquireImage(ImageWidthInPixels_ForDummy, ImageWidthInPixels_ForDummy, DwellTimeInMicroseconds_ForDummy, 'Z:\Hayworth\PostionTestStuff\MagTestDir\MyDummyImage.tif',...
%                         FOV_microns_ForDummy, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
%     pause(1);
%     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',30);
%     pause(1);
    


    %PerformAutoFocus;
    %pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD', WD_Test_Array(i));
    %pause(0.5);
    ImageFileNameStr = sprintf('Z:\\Hayworth\\PostionTestStuff\\MagTestDir\\MyTestImage_%d.tif', i);
    DataFileNameStr = sprintf('Z:\\Hayworth\\PostionTestStuff\\MagTestDir\\MyTestImage_%d.mat', i);
    
  
    
    Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
                        FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
    
    pause(0.5);
    
    load(DataFileNameStr, 'Info');
    
    FOV_microns_Array(i) = Info.FOV_microns; %This is the requested FOV
    ReadFOV_microns_Array(i) = Info.ReadFOV_microns; 
    ResultingMag_Array(i) = Info.Mag;
    WD_Read_Array(i) = Info.WorkingDistance;
    
    figure(1747);
    subplot(3,1,1);
    plot(WD_Read_Array*1000, 'o-');
    ylabel('WD (mm)')
    title('WD\_Test\_Array (mm)');
    subplot(3,1,2);
    plot(WD_Read_Array*1000, ReadFOV_microns_Array, 'o-');
    ylabel('microns)')
    xlabel('WD (mm)')
    title('ReadFOV\_microns\_Array');
    subplot(3,1,3);
    plot(WD_Read_Array*1000, ResultingMag_Array, 'o-');
    ylabel('mag)')
    xlabel('WD (mm)')
    title('ResultingMag\_Array');
    
    
    
end
                    
