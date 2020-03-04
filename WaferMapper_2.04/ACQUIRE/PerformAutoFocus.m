%PerformAutoFocusStigFocus

%KH: Cludge to correct for auto focus changing contrast 8-3-2011
Current_Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');



%Note: This sequence of operations seems to work. Do not reduce
%delays without testing

%*** START: This sequence is desigend to release the SEM from Fibics control
CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_AutoFunction_ScanRate',GuiGlobalsStruct.MontageParameters.AutofunctionScanrate ); %6
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
pause(1);
%*** END

%pause(10); %KHKHKH REMOVE!!! This is to all autofocus to work in SE on bad tissue

%*** Auto focus
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',5000); %10000 KHKHKH
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(.5);
    %disp('Auto Focusing...');
end
pause(1);

%KH: Cludge to correct for auto focus changing contrast 8-3-2011
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_CONTRAST',Current_Contrast);
pause(1);

pause(2);

