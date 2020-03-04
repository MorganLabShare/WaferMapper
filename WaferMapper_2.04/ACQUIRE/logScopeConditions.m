function[logBook] = logScopeConditions(logBook)


global GuiGlobalsStruct

%bookName = GuiGlobalsStruct.CurrentLogBook ;
%load([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'])

%% Gun

scopedata{1} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_ACTUALKV');
scopedata{2} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_ACTUALCURRENT');
scopedata{3} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNSHIFT_X');
scopedata{4} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNSHIFT_Y');
scopedata{5} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNTILT_X');
scopedata{6} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNTILT_Y');
scopedata{7} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNALIGN_X');
scopedata{8} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_GUNALIGN_Y');
scopedata{9} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_EXTCURRENT');
scopedata{10} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MANUALEXT');
scopedata{11} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MANUALKV');
scopedata{12} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_FILAMENT_AGE');

%% Beam
scopedata{13} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BEAMSHIFT_X');
scopedata{14} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BEAMSHIFT_Y');
scopedata{15} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BEAM_OFFSET_X');
scopedata{16} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BEAM_OFFSET_Y');

%% APERATURE
scopedata{17} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_APERTURESIZE');
scopedata{18} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_APERTURE_ALIGN_X');
scopedata{19} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_APERTURE_ALIGN_Y');
scopedata{20} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_APERTUREPOSN_X');
scopedata{21} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_APERTUREPOSN_Y');

%% VACUUM
scopedata{22} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SYSTEM_VAC');
scopedata{23} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_COLUMN_VAC');
scopedata{24} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CHAMBER_PRESSURE');

%% GENERAL
scopedata{25} =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('SV_USER_NAME');


H = size(logBook.sheets.scopeConditions.data,1);
W = length(scopedata)
logBook.sheets.scopeConditions.data(H+1,1:W) = scopedata;

%% Save
%     safeSave([GuiGlobalsStruct.UTSLDirectory '\logBooks\' bookName '.mat'],'logBook')
%    safeSave([GuiGlobalsStruct.TempImagesDirectory 'logBooks\' bookName '.mat'],'logBook')
