%function[] = autoBrightCon()

global GuiGlobalsStruct
MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
tic
%% Set up Variables
%DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds;
DwellTimeInMicroseconds = .1;
FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
FileName = 'C:\temp\tempBC.tif';
MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns); %Always set the FOV even if you are overriding with mag (might be used in some way inside Fibics)
pause(0.1); %1

%% Get first brigh/con
firstBrightness =  MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
firstContrast =  MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
newBright = firstBrightness;
newCon = firstContrast;
imagePix = 1024;
lowThresh = .01; %percent allowed to saturate
highThresh = .01; %percent allowed to saturate
changeBright = .5;
changeCon = .5;
lastChangeCon = 0;
lastChangeBright = 0;

%% Start checking contrast
for r = 1:1000
    
    
    %%Get Pic
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_AcquireImage(imagePix,imagePix,DwellTimeInMicroseconds,FileName);
    while(MyCZEMAPIClass.Fibics_IsBusy)
        pause(.1); %1
    end
    
    try
        I = double(imread(FileName));
    catch err
    end
    
    
    
    %%Analyze Pic
    histI = hist(I(:),0:1:254);
    
    %bar(histI),pause(.01)
    
    numLow = histI(1);
    numHigh = histI(end);
    numGoodLow = sum(histI(1:10));
    numGoodHigh = sum(histI(end-9:end));
    medI = median(I(:));
    stdI = std(I(:));
    
    tooLow = (numLow/imagePix^2) > (lowThresh/100);
    tooHigh = (numHigh/imagePix^2) > (highThresh/100);
    
    
    
    
    if tooLow & tooHigh %reduceContrast
        
        if lastChangeCon == 1
            changeCon = changeCon/2
        end
        disp('dropContrast')
        newCon = newCon-changeCon;
        newBright = newBright + changeCon;
        lastChangeCon = -1;
        %lastChangeBright = 0;
    elseif tooLow
        if lastChangeBright == -1
            changeBright = changeBright;
        end
        disp('brighten')
        newBright = newBright + changeBright;
        lastChangeBright = 1;
        %lastChangeCon = 0;
    elseif tooHigh
        if lastChangeBright == 1
            changeBright = changeBright/2;
        end
        disp('darken')
        newBright = newBright - changeBright;
        lastChangeBright = -1;
        %lastChangeCon = 0;
    else
        if lastChangeCon == -1
            changeCon = changeCon/2;
        end
        passLow = (numGoodLow/imagePix^2) > (lowThresh/100)
        passHigh = (numGoodHigh/imagePix^2)> (highThresh/100)
        if passLow & passHigh
            'passed'
            break
        end
        
        disp('Increase Contrast')
        newCon = newCon+changeCon;
        newBright = newBright - changeCon/2;
        lastChangeCon = 1;
        %lastChangeBright = 0;
    end
    
    
    
    MyCZEMAPIClass.Set_PassedTypeSingle('AP_BRIGHTNESS',newBright);
    MyCZEMAPIClass.Set_PassedTypeSingle('AP_CONTRAST',newCon);
end %image again

toc