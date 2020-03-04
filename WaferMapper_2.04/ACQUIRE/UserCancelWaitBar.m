function [] = UserCancelWaitBar()
global GuiGlobalsStruct;

GuiGlobalsStruct.IsUserCancelWaitBar = true;
if ishandle(GuiGlobalsStruct.h_waitbar)
     delete(GuiGlobalsStruct.h_waitbar);
end

end

