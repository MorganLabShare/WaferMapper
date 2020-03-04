function LoadOpticalWaferImage(handles)

global GuiGlobalsStruct;

if ~exist(GuiGlobalsStruct.OpticalWaferImageDirectory)
    mkdir(GuiGlobalsStruct.OpticalWaferImageDirectory)
end

%[FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE)
[FileName, PathName, FilterIndex] = uigetfile('*.tif','Choose the optical image of the wafer')
 
FileNameStr = sprintf('%s%s',PathName, FileName);

MyImage = imread(FileNameStr,'tif');
MyImage = mean(double(MyImage),3);
MyImage = MyImage-min(MyImage(:));
MyImage = MyImage * 255/max(MyImage(:));
MyImage = uint8(MyImage);

h_MyFigure = figure();
imshow(MyImage);
[MaxY, MaxX] = size(MyImage);

uiwait(msgbox('Drive microscope to a fiducial then click that fiducial location in the image'));

NumOfOpticalFiducial = 1;
while(1)
    IsAbortMove = false;
    
    %disp('ginput response;');
    [x_mouse, y_mouse, button] = ginput(1);
    if (x_mouse < 0) || (x_mouse > MaxX) || (y_mouse < 0) || (y_mouse > MaxY) 
        disp('HERE 1');
        break; %break out of pick loop if user picks outside of axes bounds
    end
    if button == 27 %'Esc'
        disp('HERE 2');
        break; %break out of pick loop if user presses esc
    end
    
    if (button == 1) %left mouse click means move, right means zoom in to 3x3 before move
        Info.r_InOpticalImage = y_mouse;
        Info.c_InOpticalImage = x_mouse;
        Info.stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
        Info.stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
        DataFileName = sprintf('%s\\OpticalToSEMFiducial_%d.mat',GuiGlobalsStruct.OpticalWaferImageDirectory, NumOfOpticalFiducial);
        
        MyStr = sprintf('Optical (r,c) = (%d,%d)\n SEM (x,y) = (%d,%d)\n Save this OpticalToSEMFiducial?',...
            Info.r_InOpticalImage, Info.c_InOpticalImage, Info.stage_x, Info.stage_y);
        AnswerName = questdlg(MyStr, ...
            'Question', ...
            'Yes', 'No', 'Yes');
        
        if strcmp(AnswerName, 'Yes')
            save(DataFileName,'Info');
            NumOfOpticalFiducial = NumOfOpticalFiducial + 1;
        else
            
        end
        
    end
end


NewFileNameStr = sprintf('%s\\FullWaferOpticalImage.tif',GuiGlobalsStruct.OpticalWaferImageDirectory)
imwrite(MyImage, NewFileNameStr, 'tif');


if ishandle(h_MyFigure)
    close(h_MyFigure);
end





