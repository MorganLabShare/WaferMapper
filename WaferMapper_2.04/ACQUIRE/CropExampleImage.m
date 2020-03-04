%CropExampleImage
global GuiGlobalsStruct;

ExampleSectionImageFileNameStr = sprintf('%s\\ExampleSectionImage.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
MyStr = sprintf('Loading image file: %s',ExampleSectionImageFileNameStr);
disp(MyStr);
ExampleSectionImage = imread(ExampleSectionImageFileNameStr,'tif');
h_fig = figure();
imshow(ExampleSectionImage,[0,255]);


MyStr = sprintf('Use mouse to drag box to be around only one section. Should be a little larger than the section. Press any key to escape.');
uiwait(msgbox(MyStr,'modal'));

%put up rubber band box
k = waitforbuttonpress;
if k == 0 %was mouse press
    
    point1 = get(gca,'CurrentPoint')   % button down detected
    finalRect = rbbox;                   % return figure units
    point2 = get(gca,'CurrentPoint')    % button up detected
    point1 = point1(1,1:2);              % extract x and y
    point2 = point2(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    
    UpLeftCorner_C = p1(1);
    UpLeftCorner_R = p1(2);
    LowerRightCorner_C = p1(1)+offset(1);
    LowerRightCorner_R = p1(2)+offset(2);
    
    MyStr = sprintf('UL_R = %d, UL_C = %d,    LR_R = %d, LR_C = %d',UpLeftCorner_R,UpLeftCorner_C,LowerRightCorner_R,LowerRightCorner_C);
    disp(MyStr);
    
    SubImage = ExampleSectionImage(UpLeftCorner_R:LowerRightCorner_R, UpLeftCorner_C:LowerRightCorner_C);
    
    
    
    
    imshow(SubImage,[0,255]);
    
    
    ImageFileNameStr = sprintf('%s\\ExampleSectionImageCropped.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
    imwrite(SubImage,ImageFileNameStr,'tif');
    
    MyStr = sprintf('Saved file: %s \n Click OK to continue.',ImageFileNameStr);
    uiwait(msgbox(MyStr));
    
    
end

if ishandle(h_fig)
    close(h_fig);
end

%Make sure main window pops back up on top
figure(GuiGlobalsStruct.HandleToWaferMapperFigure);