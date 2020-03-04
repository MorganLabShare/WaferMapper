function PerformAutoFocusWithStartingWD(StartingPointWD)
global GuiGlobalsStruct;

%Note: This sequence of operations seems to work. Do not reduce
%delays without testing

%*** START: This sequence is desigend to release the SEM from Fibics control
%CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
pause(1);
%*** END


GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartingPointWD);
pause(1);

%*** Auto focus
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',5000); %10000 KHKHKH
pause(1);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(1);
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(.5);
    disp('Auto Focusing...');
end
pause(1);



pause(2);

