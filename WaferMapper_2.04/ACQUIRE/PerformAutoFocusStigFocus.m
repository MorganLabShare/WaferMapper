%PerformAutoFocusStigFocus


%Note: This sequence of operations seems to work. Do not reduce
%delays without testing

%KH: Cludge to correct for auto focus changing contrast 8-3-2011
%Current_Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');


%*** START: This sequence is desigend to release the SEM from Fibics control
CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
pause(1);
%*** END

%*** Auto focus
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',20000);
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(.5);
    disp('Auto Focusing...');
end
pause(1);

%*** Auto stig
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_STIG');
pause(1);
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(.5);
    disp('Auto Stig...');
end
pause(1);

%*** Auto focus
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(.5);
    disp('Auto Focusing...');
end

%KH: Cludge to correct for auto focus changing contrast 8-3-2011
%GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_CONTRAST',Current_Contrast);
%
pause(2);

