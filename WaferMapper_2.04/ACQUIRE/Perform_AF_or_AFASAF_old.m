function [] = Perform_AF_or_AFASAF(StartingMagForAF, IsPerformAutoStig, StartingMagForAS, IsNeedToReleaseFromFibics)

global GuiGlobalsStruct;

LogFile_WriteLine('Starting autofocus');

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('DP_IMAGE_STORE',0); %'0' is 1024 * 768



if ~exist('IsNeedToReleaseFromFibics', 'var')
    IsNeedToReleaseFromFibics = true;
end

CurrentWorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
startStigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
startStigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');



if IsNeedToReleaseFromFibics
    %*** START: This sequence is desigend to release the SEM from Fibics control
    GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
    pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_ABORT_AUTO');
    pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',CurrentWorkingDistance);
    pause(0.5);
    %*** END
end

%*** Auto focus
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',StartingMagForAF);
pause(0.5);
GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
pause(0.5);
disp('Auto Focusing...');
while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
    pause(0.5);
end
pause(0.5);

if IsPerformAutoStig
    %*** Auto stig
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',StartingMagForAS);
    pause(0.5);
    GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_STIG');
    pause(0.5);
    
    disp('Auto Stig...');
    while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
        pause(1);
    end
    pause(0.5);
    
    %*** Auto focusP
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_Mag',StartingMagForAF);
    pause(0.5);
    
    GuiGlobalsStruct.MyCZEMAPIClass.Execute('CMD_AUTO_FOCUS_FINE');
    pause(0.5);
    disp('Auto Focusing...');
    while ~strcmp('Idle',GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_AUTO_FUNCTION'))
        pause(1);
        
    end
    
    pause(0.5);
    
    ResultStigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
    ResultStigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
    LogFile_WriteLine(sprintf('AutoStig produced X = %0.5g and Y = %0.5g',ResultStigX, ResultStigY));
    
end


end




