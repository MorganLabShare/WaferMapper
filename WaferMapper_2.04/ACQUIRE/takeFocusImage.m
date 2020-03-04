function[q,FileNameStr] = takeFocusImage(focOptions, ImageParams)
tic
global GuiGlobalsStruct

% % if exist('focOptions')
% %     if isfield(focOptions,'WD')
% %         %As of 6-28-2013, this is not called anywhere else in WaferMapper.
% %         %Commenting out to see whether it causes any errors if it is
% %         %removed.
% %         GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',focOptions.WD);
% %     end
% %     
% % end

MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;


TPN = 'C:\Documents and Settings\Administrator\My Documents\My Pictures\tempData';
    
if ~exist(TPN,'dir')
    mkdir(TPN)
end

if exist('ImageParams', 'var')
    FOV_microns = ImageParams.FOV_microns;
    ImageWidthInPixels = ImageParams.ImageWidthInPixels;
    ImageHeightInPixels = ImageParams.ImageHeightInPixels;
    DwellTimeInMicroseconds = ImageParams.DwellTimeInMicroseconds;
    
else
    %use default params
    FOV_microns = 12;%4
    ImageWidthInPixels = 3000;
    ImageHeightInPixels = 3000;
    DwellTimeInMicroseconds = .2;
end

FileNameStr = [TPN '\TestFocus2.tif'];
delete(FileNameStr)

%% Take picture
MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns); %Always set the FOV even if you are overriding with mag (might be used in some way inside Fibics)
pause(0.5); %1
MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
    DwellTimeInMicroseconds,FileNameStr);
while(MyCZEMAPIClass.Fibics_IsBusy)
    pause(.2); %1
end

%% Evaluate picture
IsReadOK = false;
while ~IsReadOK
    IsReadOK = true;
    startCheck = datenum(clock);
    try
        MyDownSampledImage = imread(FileNameStr, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
    catch MyException
        IsReadOK = false;
        pause(0.5);
    end
    if ((datenum(clock)-startCheck)* 60 * 24)>1  %give up after a minute
        'File cannot be read'
        break
    end
end

if IsReadOK
q = checkFileQual(FileNameStr);
else
    q.quality = 0;
end

toc
