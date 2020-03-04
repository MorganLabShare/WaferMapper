function SetSectionOverviewProcessingParametersDefaults()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global GuiGlobalsStruct;

%default Wafer Parameters
GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle = 0;
GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement = 8;
GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps = 4;
 
end

