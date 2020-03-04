function MyKeyPressFcn(h_obj,evt)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
global GuiGlobalsStruct;



if isfield(GuiGlobalsStruct, 'TimeOfLastUpdate')
    if etime(GuiGlobalsStruct.TimeOfLastUpdate, clock) > 0.1
        
        
        disp(evt.Key);
        
        MyKey = evt.Key
        
        if strcmp(evt.Key,'rightarrow')
            GuiGlobalsStruct.SectionIndex = GuiGlobalsStruct.SectionIndex + 1;
        end
        
        if strcmp(evt.Key,'leftarrow')
            GuiGlobalsStruct.SectionIndex = GuiGlobalsStruct.SectionIndex - 1;
        end
        
        
        
        imshow(GuiGlobalsStruct.ArrayOfImages(GuiGlobalsStruct.SectionIndex).Image, [0,255]);
        disp(sprintf('GuiGlobalsStruct.SectionIndex = %d',GuiGlobalsStruct.SectionIndex));
        drawnow;
    end
end

GuiGlobalsStruct.TimeOfLastUpdate = clock;
end

