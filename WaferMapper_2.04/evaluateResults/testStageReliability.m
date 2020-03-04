
%%This program tests stage reliablity by repeatedly moving the stage through a set of 
%%User defined target points and then taking both a high and low resolution image
%%To use the target points from a previous test, move the targetPoints.mat file from the old
%%directory to the new one.


clear all
reps = 3000;  %how many times should cycle be repeated
rLength = length(num2str(reps));
FOV_microns = 5120; %field of view in microns
FOV_micronsHigh = 51.2;

BacklashState = 'Off';
ImageWidthInPixels = 512;
ImageHeightInPixels = 512;
DwellTimeInMicroseconds = 0.3;
DiagonalMove = 1;
extraPause = 0;
independentBacklash = 1;

sm = startFibics;

%% Get target directory
TPN = GetMyDir;

%% Turn on Backlash
disp('Turning stage backlash ON in X and Y');
sm.Set_PassedTypeString('DP_X_BACKLASH','+ -');
sm.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
sm.Set_PassedTypeString('DP_STAGE_BACKLASH', BacklashState);

%% Get stage starting information
disp('Getting stage position');
stage_x = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
stage_y = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
stage_z = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
stage_t = sm.Get_ReturnTypeSingle('AP_STAGE_AT_T');
stage_r = sm.Get_ReturnTypeSingle('AP_STAGE_AT_R');
stage_m = sm.Get_ReturnTypeSingle('AP_STAGE_AT_M');


%% get target points
clear tpX tpY
if exist([TPN 'targetPoints.mat'],'file')
    load([TPN 'targetPoints.mat'])
end

if exist('tpX','var')
    UsePrevious = questdlg('Use previous target points?', 'Question', 'Yes', 'No', 'Yes');
else
    UsePrevious = 'No'
end


if strcmp(UsePrevious, 'No')
    for i = 1:1000
        
        MyAnswer = questdlg('Move to target points with -ctrl tab', 'Question', 'Add Point', 'Finished', 'Add Point');
        if strcmp(MyAnswer, 'Finished')
            break;
        end
        
        New_StageX_Meters = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X')
        New_StageY_Meters = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y')
        
        tpX(i) = New_StageX_Meters;
        tpY(i) = New_StageY_Meters;
        
    end
end

%% calc distance traveled
prevX = tpX(end);
prevY = tpY(end);
for i = 1:length(tpX)
    distX(i) = abs(prevX-tpX(i));
    distY(i) = abs(prevY - tpY(i));
    prevX = tpX(i);
    prevY = tpY(i);
end
cycleDist = sum(sqrt(distX.^2+distY.^2));

tpLength = length(num2str(length(tpX)));
save([TPN 'targetPoints.mat'],'tpX', 'tpY','distX','distY')

%% start cycle
for i = 1:length(tpX)
    tpDir{i} = [TPN 'targetPoint' zeroBuf(i,tpLength)];
    if ~exist(tpDir{i},'dir')
        mkdir(tpDir{i})
    end
    tpDirHigh{i} = [TPN 'HighTargetPoint' zeroBuf(i,tpLength)];
    if ~exist(tpDirHigh{i},'dir')
        mkdir(tpDirHigh{i})
    end
end

if tpX(1) == 1019
    return
end

for r = 1:reps
    
    
    for i = 1:length(tpX)
        FileNameStr = [tpDir{i} '\Rep' zeroBuf(r,rLength) '.tif' ];
        FileNameStrHigh = [tpDirHigh{i} '\Rep' zeroBuf(r,rLength) '.tif' ];
        
        if DiagonalMove  %If move diagonal 
            sm.MoveStage(tpX(i),tpY(i),stage_z,stage_t,stage_r,stage_m);
            while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            pause(extraPause)
        else %else move x then y
            
            sm.Set_PassedTypeSingle('AP_STAGE_GOTO_X',tpX(i));
            while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
                        pause(extraPause)

            sm.Set_PassedTypeSingle('AP_STAGE_GOTO_Y',tpY(i));
            while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
                        pause(extraPause)

            
        end
        
        %% Do independent backlash
        if independentBacklash
            sm.Set_PassedTypeString('DP_STAGE_BACKLASH', 'On');

            sm.Execute('CMD_STAGE_BACKLASH')
            while(strcmp(sm.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            sm.Set_PassedTypeString('DP_STAGE_BACKLASH', 'Off');

        end
        
        
        believe_x(r,i) = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        believe_y(r,i) = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        
        
        sm.Fibics_WriteFOV(FOV_micronsHigh);
        %Wait for image to be acquired
        sm.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileNameStrHigh);
        while(sm.Fibics_IsBusy)
            pause(.02); %1
        end
        
        %Wait for file to be written
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                MyDownSampledImage = imread(FileNameStrHigh, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
            catch MyException
                IsReadOK = false;
                pause(0.2);
            end
        end
        
        
        
        
        
        
        
        sm.Fibics_WriteFOV(FOV_microns);
        %Wait for image to be acquired
        sm.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileNameStr);
        while(sm.Fibics_IsBusy)
            pause(.02); %1
        end
        
        %Wait for file to be written
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                MyDownSampledImage = imread(FileNameStr, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
            catch MyException
                IsReadOK = false;
                pause(0.2);
            end
        end
        
        
        
        sm.Set_PassedTypeSingle('DP_EXT_SCAN_CONTROL',0);
        
    end % run all target points
    
    save([TPN 'stageTestWorkspace.mat'])
end %repeat cycle












