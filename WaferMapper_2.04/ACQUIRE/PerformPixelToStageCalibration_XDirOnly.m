function [  ] = PerformPixelToStageCalibration_XDirOnly(handles)
global GuiGlobalsStruct;


%to do: actual calibration stuff

ImageFileNameStr = sprintf('%s\\PixelToStageCalibrationImage.tif',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
disp(sprintf('Loading file: %s', ImageFileNameStr));
BaseImage = imread(ImageFileNameStr, 'tif');
ImageInfoFileNameStr = [ImageFileNameStr(1:end-4), '.mat'];
disp(sprintf('Loading file: %s', ImageInfoFileNameStr));
load(ImageInfoFileNameStr, 'Info');
% Info = 
%                 FOV_microns: 4096
%             ReadFOV_microns: 4.0460e+003
%          ImageWidthInPixels: 4096
%               StageX_Meters: 0.0596
%               StageY_Meters: 0.0598
BaseImage_StageX_Meters = Info.StageX_Meters;
BaseImage_StageY_Meters = Info.StageY_Meters;
ReadFOV_microns = Info.ReadFOV_microns;
ImageWidthInPixels = Info.ImageWidthInPixels;


ImageFileNameStr_ShiftedInX = [ImageFileNameStr(1:end-4), '_ShiftedInX.tif'];
disp(sprintf('Loading file: %s', ImageFileNameStr_ShiftedInX));
BaseImage_ShiftedInX = imread(ImageFileNameStr_ShiftedInX, 'tif');  
ImageInfoFileNameStr = [ImageFileNameStr_ShiftedInX(1:end-4), '.mat'];
disp(sprintf('Loading file: %s', ImageInfoFileNameStr));
load(ImageInfoFileNameStr, 'Info');
BaseImage_ShiftedInX_StageX_Meters = Info.StageX_Meters;
BaseImage_ShiftedInX_StageY_Meters = Info.StageY_Meters;

h_fig = figure;
[MaxR, MaxC] = size(BaseImage);
QuaterImageWidthPixels = floor(MaxC/4);
XPixelShiftArray = QuaterImageWidthPixels + (-75:75); %KH changed from: QuaterImageWidthPixels + (-50:50);
for i = 1:length(XPixelShiftArray)
    Im(:,:,1) = BaseImage(:,1:2*QuaterImageWidthPixels);
    Im(:,:,2) = BaseImage_ShiftedInX(:,(XPixelShiftArray(i)+1):(XPixelShiftArray(i)+2*QuaterImageWidthPixels));
    Im(:,:,3) = 0*Im(:,:,1);
    
    Im1 = double(Im(:,:,1));
    Im2= double(Im(:,:,2));
    
    
    
    
    subplot(1,2,1);
    imshow(Im);
    
    
    ImageDifference(i) = sum(sum(abs(Im1 - Im2)));
    
    subplot(1,2,2);
    plot(ImageDifference);
    drawnow;
    pause(.1);
end

[dummy, IndexOfMin] = min(ImageDifference)

XPixelShift = XPixelShiftArray(IndexOfMin)
XStageShift_Microns = (BaseImage_ShiftedInX_StageX_Meters - BaseImage_StageX_Meters)*1000000

MicronsPerPixel_FromCalibration = XStageShift_Microns/XPixelShift;
disp(sprintf('MicronsPerPixel_FromCalibration = %0.5g', MicronsPerPixel_FromCalibration));
MicronsPerPixel_FromFibicsReadFOV = ReadFOV_microns/ImageWidthInPixels;
disp(sprintf('MicronsPerPixel_FromFibicsReadFOV = %0.5g', MicronsPerPixel_FromFibicsReadFOV));
PercentDifference = 100*((MicronsPerPixel_FromCalibration/MicronsPerPixel_FromFibicsReadFOV)-1);
disp(sprintf('PercentDifference = %0.5g', PercentDifference));

CalibrationFileNameStr = sprintf('%s\\CalibrationFile.mat',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
save(CalibrationFileNameStr, 'MicronsPerPixel_FromCalibration', 'MicronsPerPixel_FromFibicsReadFOV');


MyStr = sprintf('Calibration Results: \n  um/pix (from calibration) = %0.5g\n  um/pix (from Fibics) = %0.5g\n  Percent difference = %0.5g%%',...
    MicronsPerPixel_FromCalibration, MicronsPerPixel_FromFibicsReadFOV, PercentDifference);
uiwait(msgbox(MyStr,'modal'));

if ishandle(h_fig)
    close(h_fig);
end

end

