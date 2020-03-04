
%%This program tests stage reliablity by repeatedly moving the stage through a set of 
%%User defined target points and then taking both a high and low resolution image
%%To use the target points from a previous test, move the targetPoints.mat file from the old
%%directory to the new one.


clear all



%% set var
mag = 1000;
xStep = .1; % in milimeters
yStep = .07;
xNum = 3;
yNum = 3;
ImageWidthInPixels = 1024;%512;
ImageHeightInPixels = 768;%512; 
ImageStore = 0;
%DwellTimeInMicroseconds = 0.3;
ScanRate = 6;
DiagonalMove = 1;
extraPause = 0;
independentBacklash = 1;
BacklashState = 'Off';

%{
reps = 1;  %how many times should cycle be repeated
rLength = length(num2str(reps));
FOV_microns = 5120; %field of view in microns
FOV_micronsHigh = 51.2;


%}

sm = startSmartSem;

%% Test image


sm.Set_PassedTypeSingle('DP_SCANRATE',0);%ScanRate)
sm.Set_PassedTypeSingle('AP_MAG',mag);
sm.Set_PassedTypeSingle('DP_IMAGE_STORE',ImageStore) 
        pause(1)

gi = sm.Grab(0,0,ImageWidthInPixels,ImageHeightInPixels,0,'C:\test\test03.bmp')
        pause(1)



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

 New_StageX_Meters = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X')
        New_StageY_Meters = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y')
        
        startX = New_StageX_Meters-xNum*xStep/1000/2;
        startY = New_StageY_Meters-yNum*yStep/1000/2;

        c = 0;
        for x = 1:xNum;
            for y = 1:yNum;
                c = c+1;
                tpX(c) = startX+(xStep*x)/1000;
                tpY(c) = startY+(yStep*y)/1000;
                fileName{c} =  sprintf('%sx-%03.0f_y-%03.0f.tif',TPN,x,y);
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



    for i = 1:length(fileName)
        FileNameStr = sprintf('%sx-%03.0f_y-%03.0f.tif',TPN,x,y);%[TPN 'Rep' zeroBuf(r,rLength) '.tif' ];
        
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
        
        
        believe_x(i) = sm.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        believe_y(i) = sm.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        
        
        %sm.Fibics_WriteFOV(FOV_micronsHigh);
        %Wait for image to be acquired
        %sm.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileNameStrHigh);
        pause(.1)
        sm.Grab(0,0,ImageWidthInPixels,ImageHeightInPixels,0,fileName{i})
        readFail = 1;
        while readFail
            pause(.01)
            try
                readFail = 0;
                imread(fileName{i});
            catch
                readFail = 1;
            end
        end
        
       sm.Set_PassedTypeSingle('DP_FROZEN', 0);


    end % run all target points
    
    save([TPN 'stageTestWorkspace.mat'])


%% Stitch

colormap gray(256)

ImageWidthInPixels
ImageHeightInPixels
pixSize = sm.Get_ReturnTypeSingle('AP_PIXEL_SIZE');


bigWidth = ceil(ImageWidthInPixels +  xStep/(pixSize*1000) * xNum);
bigHeight = ceil(ImageHeightInPixels + yStep/(pixSize*1000) * yNum);
bigI = zeros(bigHeight,bigWidth,3,'double');

lowX = tpX(1);
lowY = tpY(1);
    pixSize = double(sm.Get_ReturnTypeSingle('AP_PIXEL_SIZE'));

for i = 1:length(fileName)
    
    I = imread(fileName{i});

    startIx = ceil((tpX(i)-lowX)/pixSize)+1;
    startIy = ceil((tpY(i)-lowY)/pixSize)+1;
    stopIx = startIx+ size(I,2)-1;
    stopIy = startIy + size(I,1)-1;
    
    if mod(i,2)
        chan = 1;
    else
        chan = 2;
    end
    bigI(fix(startIy) : fix(stopIy), fix(startIx):fix(stopIx),chan) = ...
        bigI(fix(startIy) : fix(stopIy), fix(startIx):fix(stopIx),chan) + (256 - double(I));
    image(bigI)
    pause(.1)
end

bigI8 = uint8(bigI * 300 / max(bigI(:)));
imshow(bigI8)
% setPixSize = 10 * 10^-6
% sm.Set_PassedTypeSingle('AP_PIXEL_SIZE',setPixSize);
% 
% AP_PIXEL_SIZE 



