function [WD_mm] = Get_WD_mm()

global GuiGlobalsStruct;

WD_mm = 1000*GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');