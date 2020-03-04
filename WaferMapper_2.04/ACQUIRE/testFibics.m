
sm = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass');
sm.InitialiseRemoting;
sm.Set_PassedTypeSingle('AP_MAG',25);
sm.Fibics_Initialise();
%sprintf(' Fibics Initializing, pausing 15 seconds...')
pause(15);

FibicsON = 1;

sm.Fibics_WriteFOV(10);
FibicsBusy = sm.Fibics_IsBusy();
'FibicsBusy';
testimage = sm.Fibics_AcquireImage(1024,1024,1,'test.tif');

FileNameStr = 'G:\joshm\utilityData\testFibics.tif';
sm.Fibics_AcquireImage(1024,1024,1,FileNameStr);
