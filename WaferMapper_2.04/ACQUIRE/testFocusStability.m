%% test Focus stabiltiy

global GuiGlobalsStruct
TPN = GetMyDir; %reset original WD

focFile = [TPN 'focData.mat'];

ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels; %4096;%16384;%4096; %1024
DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds; %.5;
FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns; %4nm pixel %GuiGlobalsStruct.MontageTarget.MontageWidthInMicrons; %40.96;
IsDoAutoRetakeIfNeeded = false;
IsMagOverride = false;
MagForOverride = -1;

startingWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
WaferNameStr = 0;
LabelStr = 0;

quality = [];
iNum = 0;
for r = 1:5  % repeat full cycle of focus stig focus image
    %% Focus
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',startingWD);
    pause(1);
    %PerformAutoFocus;
    StartingMagForAF = GuiGlobalsStruct.MontageParameters.AutoFocusStartMag;
    IsPerformAutoStig = false;
    StartingMagForAS = round(StartingMagForAF/2);
    smartTileFocus(StartingMagForAF, IsPerformAutoStig, StartingMagForAS);
    foc.rep(r).newWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
    foc.rep(r).newStigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
    foc.rep(r).newStigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
    foc.rep(r).focusFinishTime = datenum(clock);
    
    
    for pause5 = 1:2  %take two groups of three images with 10 min in between
    for i = 1:3  %take three images
        %% File name
        iNum = iNum + 1;
        ImageFileNameStr = [TPN sprintf('TestFocus%d',iNum)];
            
        foc.rep(r).pause5(pause5).i(i).imageStartTime = datenum(clock);
        Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
        FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr,1);
        pause(.01)
        
        %% Wait for Fibics to finish being busy
        while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)  %% record current
        pause(.1); %1
        end
        
        checkFile = ImageFileNameStr;
        [qual qualI] = checkFileQual(checkFile);
        
        foc.rep(r).pause5(pause5).i(i).quality = qual.quality;
        quality = cat(1,quality,qual.quality);
        foc.quality = quality;
        %% record results
        
        safesave('focFile','foc');
        
        plot(quality),pause(.1)
    end
        
        if pause5 == 1
            pause(600)
        end
    end % repeat after ten min
    
end % repeat full cycle
        
        
