function [ sm ] = startFibics()
%startFibics Activate ActiveX

sm = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass')
sm.InitialiseRemoting
sm.Set_PassedTypeSingle('AP_MAG',25);
sm.Fibics_Initialise();
sprintf(' Fibics Initializing, pausing 15 seconds...')
pause(15)

FibicsON = 1;

end

