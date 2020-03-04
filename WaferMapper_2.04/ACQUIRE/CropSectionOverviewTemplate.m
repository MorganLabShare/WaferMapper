%CropSectionOverviewTemplate
SectionOverviewTemplateFileNameStr = sprintf('%s\\SectionOverviewTemplate.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
MyStr = sprintf('Loading image file: %s',SectionOverviewTemplateFileNameStr);
disp(MyStr);
SectionOverviewTemplate = imread(SectionOverviewTemplateFileNameStr,'tif');
h_fig = figure();
imshow(SectionOverviewTemplate,[0,255]);


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
    
    UpLeftCorner_C = floor(p1(1));
    UpLeftCorner_R = floor(p1(2));
    LowerRightCorner_C = floor(p1(1)+offset(1));
    LowerRightCorner_R = floor(p1(2)+offset(2));
    
    MyStr = sprintf('UL_R = %d, UL_C = %d,    LR_R = %d, LR_C = %d',UpLeftCorner_R,UpLeftCorner_C,LowerRightCorner_R,LowerRightCorner_C);
    disp(MyStr);
    
    %SubImage = SectionOverviewTemplate(UpLeftCorner_R:LowerRightCorner_R, UpLeftCorner_C:LowerRightCorner_C);

    %imshow(SubImage,[0,255]);

end

Avg1 = mean(SectionOverviewTemplate(UpLeftCorner_R:LowerRightCorner_R,UpLeftCorner_C)); %top line
Avg2 = mean(SectionOverviewTemplate(UpLeftCorner_R:LowerRightCorner_R,LowerRightCorner_C)); %bottom line
Avg3 = mean(SectionOverviewTemplate(UpLeftCorner_R,UpLeftCorner_C:LowerRightCorner_C)); %left line
Avg4 = mean(SectionOverviewTemplate(LowerRightCorner_R,UpLeftCorner_C:LowerRightCorner_C)); %right line
AverageOfPeriphery = mean([Avg1,Avg2,Avg3,Avg4]);

SectionOverviewTemplate(:,1:UpLeftCorner_C) = AverageOfPeriphery; %fill top
SectionOverviewTemplate(:,LowerRightCorner_C:end) = AverageOfPeriphery; %fill bottom
SectionOverviewTemplate(1:UpLeftCorner_R,:) = AverageOfPeriphery; %fill left
SectionOverviewTemplate(LowerRightCorner_R:end,:) = AverageOfPeriphery; %fill right

h_fig2 = figure();
imshow(SectionOverviewTemplate,[0,255]);

ImageFileNameStr = sprintf('%s\\SectionOverviewTemplateCroppedFilledPeriphery.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
MyStr = sprintf('About to write file: %s',ImageFileNameStr);
ButtonName = questdlg(MyStr,'title','OK','Cancel','OK');
if strcmp(ButtonName,'OK')
    imwrite(SectionOverviewTemplate,ImageFileNameStr,'tif');
end

if ishandle(h_fig)
    close(h_fig);
end

if ishandle(h_fig2)
    close(h_fig2);
end

if ishandle(GuiGlobalsStruct.HandleToWaferMapperFigure)
    figure(GuiGlobalsStruct.HandleToWaferMapperFigure);
end