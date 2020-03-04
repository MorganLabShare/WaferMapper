global GuiGlobalsStruct;

h_fig = figure(555);

%set(h_fig,'KeyPressFcn',@(h_obj,evt) disp(evt.Key));
set(h_fig,'KeyPressFcn',@MyKeyPressFcn);

GuiGlobalsStruct.SectionIndex = 1;
GuiGlobalsStruct.SectionFig = h_fig;


% pause(1);
% for i = 1:length(GuiGlobalsStruct.ArrayOfImages)
%     imshow(GuiGlobalsStruct.ArrayOfImages(i).Image, [0,255]);
%     disp(sprintf('i = %d',i));
%     drawnow;
% end


