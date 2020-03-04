function PopulateWaferNamePopupMenu(handles)
%Populate the popup menu for wafers in the section overview display
WaferDirListArray = dir(GuiGlobalsStruct.UTSLDirectory);

n = 1;
ListOfWaferNames = [];
for i=1:length(WaferDirListArray)
    if (WaferDirListArray(i).isdir == 1) && (WaferDirListArray(i).name(1) ~= '.')
        if ~strcmp(WaferDirListArray(i).name, 'AlignedTargetListsDirectory') %this is only dir that is not a wafer
            ListOfWaferNames{n} = WaferDirListArray(i).name;
            n = n + 1;
        end
    end
end
GuiGlobalsStruct.ListOfWaferNames = ListOfWaferNames;
set(handles.WaferForSectionOverviewDisplay_PopupMenu,'String', GuiGlobalsStruct.ListOfWaferNames);