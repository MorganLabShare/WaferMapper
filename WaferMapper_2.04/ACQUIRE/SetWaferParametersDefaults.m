function SetWaferParametersDefaults()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global GuiGlobalsStruct;

%default Wafer Parameters
GuiGlobalsStruct.WaferParameters.TileFOV_microns = 8000; %4mm
GuiGlobalsStruct.WaferParameters.TileWidth_pixels = 1000; %assumes square
GuiGlobalsStruct.WaferParameters.TileDwellTime_microseconds = 1.0;
GuiGlobalsStruct.WaferParameters.DownSampleFactorForFullWaferOverviewImage = 4;
GuiGlobalsStruct.WaferParameters.PerformBacklashDuringFullWaferMontage = 0;

GuiGlobalsStruct.WaferParameters.LowResFiducialFOV_microns = 3200; %Note this uses to be 4096 but at short WD this wont work. 3200 should work down to 3mm WD
GuiGlobalsStruct.WaferParameters.HighResFiducialFOV_microns = 256;
GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels = 1024;
GuiGlobalsStruct.WaferParameters.FiducialDwellTime_microseconds = 2.0;

GuiGlobalsStruct.WaferParameters.AutoMapFurtherDownsampleFactor = 2;
GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMinAngle = -14;
GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMaxAngle = 14;
GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryNumberOfAngles = 15;

GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns = 3072;
GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels = 4096;
GuiGlobalsStruct.WaferParameters.SectionOverviewDwellTime_microseconds = 1.0;
GuiGlobalsStruct.WaferParameters.PerformAutofocus = 0;

end

