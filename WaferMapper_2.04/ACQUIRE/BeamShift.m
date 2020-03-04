function BeamShift( X_Microns, Y_Microns )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
 
global GuiGlobalsStruct;

PercentUnitsPerMicron = 8.7; %Note: This was derived from a set of calibration images taken on the Zeiss Sigma at mags 573x to 4580x 
                             %      (seemed independent of mag over these
                             %      ranges and same in X and Y directions)

XBeamShiftPercent = X_Microns*PercentUnitsPerMicron;
if XBeamShiftPercent > 100
    XBeamShiftPercent  =100;
end
if XBeamShiftPercent < -100
    XBeamShiftPercent  = -100;
end


YBeamShiftPercent = Y_Microns*PercentUnitsPerMicron;
if YBeamShiftPercent > 100
    YBeamShiftPercent  =100;
end
if YBeamShiftPercent < -100
    YBeamShiftPercent  = -100;
end


GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_BEAMSHIFT_X',XBeamShiftPercent);
pause(.5);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_BEAMSHIFT_Y',YBeamShiftPercent);
pause(.5);



end

