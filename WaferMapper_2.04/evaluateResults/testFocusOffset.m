
MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;

%% Get folder
TPN = GetMyDir
%%
FileNameStr = [TPN 'focusTestImage-1.tif'];
ImageWidthInPixels = 5000;
ImageHeightInPixels = 5000;
FOV_microns = 20;
DwellTimeInMicroseconds = .05;

MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns); %Always set the FOV even if you are overriding with mag (might be used in some way inside Fibics)

focusWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
newWD = focusWD * 1000000 -1;
newWD = newWD /1000000;

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',newWD);
pause(1)
MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
    DwellTimeInMicroseconds,FileNameStr);
pause(ImageWidthInPixels * ImageHeightInPixels * .7 * DwellTimeInMicroseconds/1000000)
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',focusWD);
