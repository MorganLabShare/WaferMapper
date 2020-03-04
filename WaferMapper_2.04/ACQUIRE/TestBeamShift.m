
BeamShiftArray = [-100, -50, 0, 50, 100];
for i = 1:5
    XBeamShiftPercent = BeamShiftArray(i);
    
    if XBeamShiftPercent >= 0
        MySignStr = 'Positive';
    else
        MySignStr = 'Negative';
    end
    MyFileName = sprintf('C:\\Users\\Hayworth\\WaferMapper\\Image_XBeamShiftPercent_%s_%d.tif',MySignStr,abs(XBeamShiftPercent));
    
    
    disp(MyFileName);
    
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_BEAMSHIFT_X',XBeamShiftPercent);
    pause(1);
    
    FOV_microns = 25.6; %25nm per pixel %102.4; %100nm per pixel
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns);
    pause(1);
    
    ImageWidthInPixels = 1024;
    ImageHeightInPixels = 1024;
    DwellTimeInMicroseconds = 2;
    Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,...
        DwellTimeInMicroseconds,MyFileName);
    pause(1);
    
end