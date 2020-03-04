function[] = autocorrFocus()

global GuiGlobalsStruct;

sm = GuiGlobalsStruct.MyCZEMAPIClass;


%% Set focus imaging conditions
ImageWidthInPixels = 1024;
ImageHeightInPixels = 1024;
DwellTimeInMicroseconds = 1; 
PixelSize = 4; % target pixel size in nanometers
FOV = ImageWidthInPixels * PixelSize/1000; % Field of view in micrometers
reps = 100; %max number of autofocus checks
focStep = 5/1000;


if exist(GuiGlobalsStruct.TempImagesDirectory,'dir')
    FileName = [GuiGlobalsStruct.TempImagesDirectory '\tempFoc.tif']
else
    FileName = 'C:\temp\temFoc.tif';
end

%% Get scope starting conditions
startingWD =sm.Get_ReturnTypeSingle('AP_WD')
startStigX =sm.Get_ReturnTypeSingle('AP_STIG_X');
startStigY =sm.Get_ReturnTypeSingle('AP_STIG_Y');
stage_x = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
stage_y = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');



%% Start autofocus

sm.Fibics_WriteFOV(FOV); % set autofocus field of view

NextWorkingDistance = CurrentWorkingDistance;
WD = CurrentWorkingDistance;
ck4 = [WD - focStep WD WD + focStep WD + focStep*2];
clear recQual recWD
for r = 1 : reps % repeat image, check, adjust
    
    disp(sprintf('%.4f',ck4))
    
    %% run four points
    trackQual = ck4 * 0;
    for c = 1:length(ck4)
        %% Set working distance
        sm.Set_PassedTypeSingle('AP_WD',ck4(c));
        takePic;
        I = imread(FileName);
        acQual = autocorrQual(Isource);
        Iqual = acQual.var; %% choose quality value
        trackQual(c) = Iqual;
        
    end
    
    recQual(r,:) = trackQual;
    recWD(r,:) = ck4;
    qualVar(r) = max(trackQual)-min(trackQual);
    [sortQual ord] = sort(trackQual,'descend');
    
    if (sortQual(1) == 4) | ( sortQual(2) == 4) %top end is best
        ck4 = [ck4(2:4) ck4(4) + focStep];
    elseif (sortQual(1) == 1) | ( sortQual(2) == 1) % bottom end is best
        ck4 = [ck4(1) - focStep ck4(1:3)];
    else
        focStep = focStep/2;
        ck4 = [chk4(2) ck4(2)+focStep ck4(3)-focStep ck4(3)];
    end
  
    if r>3
        if qualVar(end)< qualVar(end-1)
            'done'
            break
        end
    end
end


function takePic(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileName)

 sm.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileName);
    while(sm.Fibics_IsBusy)
        pause(.01); %1
    end
    
    %Wait for file to be written
    IsReadOK = false;
    while ~IsReadOK
        IsReadOK = true;
        try
            I = imread(FileName);
        catch MyException
            IsReadOK = false;
            pause(0.1);
        end
    end
end



