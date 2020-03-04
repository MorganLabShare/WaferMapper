function[logBook] = logImageConditions(logBook,ImageName)
%log all available image information

global GuiGlobalsStruct
% bookName = GuiGlobalsStruct.CurrentLogBook ;
% load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])

imagedata{1} =  ImageName;

%BEAM
imagedata{2} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
imagedata{3} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
imagedata{4} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MAG');
imagedata{5} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
imagedata{6} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SPOT');
imagedata{7} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_PIXEL_SIZE');
imagedata{8} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCM');
imagedata{9} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SPOTSIZE');
imagedata{10} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_IPROBE');
imagedata{11} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
imagedata{12} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
imagedata{13} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_ZOOM_FACTOR');
imagedata{14} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_TILT_ANGLE');

%SCANNING
imagedata{15} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
imagedata{16} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_PIXEL_SIZE');
imagedata{17} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_FRAME_TIME');
imagedata{18} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_FRAME_AVERAGE_COUNT');
imagedata{19} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_FRAME_iNT_COUNT');
imagedata{20} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_NR_COEFF');
imagedata{21} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WIDTH');
imagedata{22} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_HEIGHT');

%STAGE
imagedata{23} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
imagedata{24} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
imagedata{25} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
imagedata{26} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
imagedata{27} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');

%DIGITAL PARAMETERS
imagedata{28} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_NOISE_REDUCTION');
imagedata{29} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_DETECTOR_CHANNEL');
imagedata{30} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_DETECTOR_TYPE');

imagedata{31} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_ACTUALCURRENT');
imagedata{32} = datestr(clock);
imagedata{33} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_EXTCURRENT');


H = size(logBook.sheets.imageConditions.data,1);
W = length(imagedata);
logBook.sheets.imageConditions.data(H+1,1:W) = imagedata;

%% Save
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%     safeSave([GuiGlobalsStruct.TempImagesDirectory 'logBooks\' bookName '.mat'],'logBook')
