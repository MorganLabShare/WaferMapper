function [ sm ] = startFibics()
%startFibics Activate ActiveX

sm = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass')
sm.InitialiseRemoting
sm.Set_PassedTypeSingle('AP_MAG',25);

end

