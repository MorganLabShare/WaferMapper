function FibicsScaleTest(NumImagesToTake)
% 
global GuiGlobalsStruct; 
FibicsScaleTestDirectory = 'Z:\Hayworth\FibicsScaleTestDirectory';


% WD_Read_Array = [];
% FOV_microns_Array = [];
% ReadFOV_microns_Array = [];
% ResultingMag_Array = [];
% for i = 1:NumImagesToTake
%     NumStr = sprintf('%d',(1000 + i));
%     ImageFileNameStr = sprintf('%s\\Image_%s.tif',FibicsScaleTestDirectory,NumStr(2:4));
%     DataFileNameStr = sprintf('%s\\Image_%s.mat',FibicsScaleTestDirectory,NumStr(2:4));
%     
%     uiwait(msgbox('Do something to mag then press OK.'));
%     
%     disp(sprintf('Acquiring image: %s', ImageFileNameStr));
%     
%     StartTimeOfImageAcquire = tic;
%     %Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
%     %     FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
%     ImageWidthInPixels = 1024;
%     ImageHeightInPixels = 1024;
%     DwellTimeInMicroseconds = 2;
%     FOV_microns = 256;
%     IsDoAutoRetakeIfNeeded = false;
%     IsMagOverride = false; %KH changed from true on 10-18-2011 %true; %NOTE: WE ARE USING ORIGINAL MAG AND NOT COUNTING ON FIBICS FOV
%     MagForOverride = 1;
%     WaferNameStr = '';
%     LabelStr = '';
%     
%     Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
%         FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
%     
%     while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
%         pause(.2);
%     end
%     disp(sprintf('   Image Aquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
%     
%     
%     pause(0.5);
%     
%     load(DataFileNameStr, 'Info');
%     
%     FOV_microns_Array(i) = Info.FOV_microns; %This is the requested FOV
%     ReadFOV_microns_Array(i) = Info.ReadFOV_microns; 
%     ResultingMag_Array(i) = Info.Mag;
%     WD_Read_Array(i) = Info.WorkingDistance;
%     
%     figure(1747);
%     subplot(3,1,1);
%     plot(WD_Read_Array*1000, 'o-');
%     ylabel('WD (mm)')
%     title('WD\_Test\_Array (mm)');
%     subplot(3,1,2);
%     plot(ReadFOV_microns_Array, 'o-');
%     ylabel('microns)')
%     title('ReadFOV\_microns\_Array');
%     subplot(3,1,3);
%     plot(ResultingMag_Array, 'o-');
%     ylabel('mag)')
%     title('ResultingMag\_Array');
% 
%     
% end

i = 1;
NumStr = sprintf('%d',(1000 + i));
ImageFileNameStr = sprintf('%s\\Image_%s.tif',FibicsScaleTestDirectory,NumStr(2:4));
FirstImage = imread(ImageFileNameStr, 'tif');
Scale_Array = [];
for i = 1:NumImagesToTake
    NumStr = sprintf('%d',(1000 + i));
    ImageFileNameStr = sprintf('%s\\Image_%s.tif',FibicsScaleTestDirectory,NumStr(2:4));
    CurrentImage = imread(ImageFileNameStr, 'tif');
    
    DSFactor = 4; %KH Note this used to be '2' but I changed it to make it run faster   %2;
    FirstImageDS = imresize(FirstImage,1/DSFactor,'bilinear'); %Must down sample by 8x to prevent out of memory error on fibics computer
    CurrentImageDS = imresize(CurrentImage,1/DSFactor,'bilinear');
    
    [ MiddleScale ] = DetermineBestScaleBetweenImages(FirstImageDS,  CurrentImageDS);
    Scale_Array(i) = MiddleScale;
    
    figure(2747);
    plot(Scale_Array, 'o-');
    ylabel('scale')
    title('Scale\_Array');
    
end