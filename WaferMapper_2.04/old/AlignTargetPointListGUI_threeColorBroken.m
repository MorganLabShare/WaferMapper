function varargout = AlignTargetPointListGUI(varargin)
% ALIGNTARGETPOINTLISTGUI MATLAB code for AlignTargetPointListGUI.fig
%      ALIGNTARGETPOINTLISTGUI, by itself, creates a new ALIGNTARGETPOINTLISTGUI or raises the existing
%      singleton*.
%
%      H = ALIGNTARGETPOINTLISTGUI returns the handle to a new ALIGNTARGETPOINTLISTGUI or the handle to
%      the existing singleton*.
%
%      ALIGNTARGETPOINTLISTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNTARGETPOINTLISTGUI.M with the given input arguments.
%
%      ALIGNTARGETPOINTLISTGUI('Property','Value',...) creates a new ALIGNTARGETPOINTLISTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlignTargetPointListGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlignTargetPointListGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlignTargetPointListGUI

% Last Modified by GUIDE v2.5 17-May-2011 19:28:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlignTargetPointListGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AlignTargetPointListGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AlignTargetPointListGUI is made visible.
function AlignTargetPointListGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AlignTargetPointListGUI (see VARARGIN)

% Choose default command line output for AlignTargetPointListGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AlignTargetPointListGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

AlignTargetPointListGuiGlobalStruct.IsShowOnlyCurrentImage = false;
set(handles.ShowOnlyCurrentImage_checkbox,'Value',AlignTargetPointListGuiGlobalStruct.IsShowOnlyCurrentImage);

%Popup dialog box to ask for AlignedTargetList to work on
if ~exist(GuiGlobalsStruct.AlignedTargetListsDirectory, 'dir')
    MyStr = sprintf('Could not find directory: %s.',GuiGlobalsStruct.AlignedTargetListsDirectory);
    uiwait(msgbox(MyStr));
    return;
else
    DirListArray = dir(GuiGlobalsStruct.AlignedTargetListsDirectory);
    n = 1;
    ListOfDirNames = [];
    for i=1:length(DirListArray)
        if (DirListArray(i).isdir == 1) && (DirListArray(i).name(1) ~= '.')
            ListOfDirNames{n} = DirListArray(i).name;
            n = n + 1;
        end
    end
    
    if length(ListOfDirNames) > 0
        [SelectionNumber,isok] = listdlg('PromptString','Select a dir:',...
            'SelectionMode','single',...
            'ListString',ListOfDirNames);
        
        if isok == 1
            AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir = sprintf('%s\\%s',...
                GuiGlobalsStruct.AlignedTargetListsDirectory,ListOfDirNames{SelectionNumber});
            %load AlignedTargetList.mat
            AlignTargetPointListGuiGlobalStruct.DataFileNameStr = sprintf('%s\\AlignedTargetList.mat',AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir);
            load(AlignTargetPointListGuiGlobalStruct.DataFileNameStr, 'AlignedTargetList');
   
        end
    else
        uiwait(msgbox('No AlignedTargetLists found.'));
        return;
    end
end

AlignTargetPointListGuiGlobalStruct.AlignedTargetList = AlignedTargetList;
%%Confused by this:
% AlignedTargetList = AlignTargetPointListGuiGlobalStruct.AlignedTargetList;

%%REPLACE WITH TEMPLATE SECTION SELECTOR
WaferNameIndex = 25;
SectionIndex = 8;

%name of SectionOverviewsAlignedWithTemplate
ImageFileNameStr = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).ImageFileNameStr;
r = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).r;
c = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).c;
half_w = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_w;
half_h = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_h;

r_offset = str2num(get(handles.R_OFFSET_edit,'String'));
c_offset = str2num(get(handles.C_OFFSET_edit,'String'));

New_r = r - r_offset;
New_c = c - c_offset;
%now use these to grab a new image from the aligned overview
AlignTargetPointListGuiGlobalStruct.TemplateImage_shifted = imread(ImageFileNameStr, 'PixelRegion',...
    {[New_r-half_h New_r+half_h], [New_c-half_w New_c+half_w]});

%Also grab a 3x larger image centered at same region
AlignTargetPointListGuiGlobalStruct.TemplateImage_x3LargerROI_shifted = imread(ImageFileNameStr, 'PixelRegion',...
           {[New_r-(half_h*3+1) New_r+(half_h*3+1)], [New_c-(half_w*3+1) New_c+(half_w*3+1)]});



% %save in global
% AlignTargetPointListGuiGlobalStruct.AlignedTargetList = AlignedTargetList;

%Populate the WaferName_PopupMenu
set(handles.WaferName_PopupMenu, 'String', AlignTargetPointListGuiGlobalStruct.AlignedTargetList.ListOfWaferNames);

%Choose the first wafer and the first section
set(handles.WaferName_PopupMenu, 'Value', 1); 
set(handles.SectionNumber_EditBox, 'String', '1');

UpdateDisplay(handles);



function UpdateDisplay(handles)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value')
WaferNameList = get(handles.WaferName_PopupMenu, 'String');
WaferName = WaferNameList{WaferNameIndex};
SectionNumStr = get(handles.SectionNumber_EditBox, 'String');
SectionNum = str2num(SectionNumStr);

%Load in current image
ImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
    AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir, WaferName, SectionNumStr);
%disp(sprintf('ImageFileNameStr = %s',ImageFileNameStr));
if exist(ImageFileNameStr, 'file')
    AlignTargetPointListGuiGlobalStruct.CurrentImage = imread(ImageFileNameStr, 'tif');
else
    AlignTargetPointListGuiGlobalStruct.CurrentImage = [];
end

%Load in previous image
if (SectionNum-1) >= 1
    SectionNum = SectionNum - 1;
elseif (WaferNameIndex-1) >= 1
    WaferNameIndex = WaferNameIndex-1;
    WaferName = WaferNameList{WaferNameIndex};
    MaxSectionNumInThisWafer = ...
        length(AlignTargetPointListGuiGlobalStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray);
    SectionNum = MaxSectionNumInThisWafer;
else
    %Already on first section of first wafer.
    % Just keep same image as 'previous'
end

PreviousImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
            AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir, WaferName, num2str(SectionNum));
%disp(sprintf('PreviousImageFileNameStr = %s',PreviousImageFileNameStr));
if exist(PreviousImageFileNameStr, 'file')
    AlignTargetPointListGuiGlobalStruct.PreviousImage = imread(PreviousImageFileNameStr, 'tif');     
else
    AlignTargetPointListGuiGlobalStruct.PreviousImage = [];
end


axes(handles.axes1); %display for OverviewImageAlignedDS

if AlignTargetPointListGuiGlobalStruct.IsShowOnlyCurrentImage
    if ~isempty(AlignTargetPointListGuiGlobalStruct.CurrentImage)
        ColorCombinedImage(:,:,1) = double(AlignTargetPointListGuiGlobalStruct.CurrentImage)/255;
        ColorCombinedImage(:,:,2) = ColorCombinedImage(:,:,1);
        ColorCombinedImage(:,:,3) = double(AlignTargetPointListGuiGlobalStruct.TemplateImage)/255;
    else
        ColorCombinedImage = [];
    end
else
    if (~isempty(AlignTargetPointListGuiGlobalStruct.CurrentImage)) && (~isempty(AlignTargetPointListGuiGlobalStruct.PreviousImage))
        ColorCombinedImage(:,:,1) = double(AlignTargetPointListGuiGlobalStruct.CurrentImage)/255;
        ColorCombinedImage(:,:,2) = double(AlignTargetPointListGuiGlobalStruct.PreviousImage)/255;%NOTE template will 'look' red because section is darker than background
        ColorCombinedImage(:,:,3) = double(AlignTargetPointListGuiGlobalStruct.TemplateImage)/255;
    elseif ~isempty(AlignTargetPointListGuiGlobalStruct.CurrentImage)
        ColorCombinedImage(:,:,1) = double(AlignTargetPointListGuiGlobalStruct.CurrentImage)/255;
        ColorCombinedImage(:,:,2) = ColorCombinedImage(:,:,1);
        ColorCombinedImage(:,:,3) = double(AlignTargetPointListGuiGlobalStruct.TemplateImage)/255;
    else
        ColorCombinedImage = [];
    end
end

imshow(1-ColorCombinedImage);
% [r_max, c_max] = size(ColorCombinedImage(:,:,1));
% h1 = line([1, c_max],[r_max/2, r_max/2]); 
% set(h1,'Color',[1 0 0]);
% h2 = line([c_max/2, c_max/2],[1, r_max]); 
% set(h2,'Color',[1 0 0]);

axes(handles.axes2);
cla;


% --- Outputs from this function are returned to the command line.
function varargout = AlignTargetPointListGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Next_pushbutton.
function Next_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Next_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsAtEnd = IncrementSectionNumber(handles);
if IsAtEnd
    uiwait(msgbox('Already on last section of last wafer.'));
end
UpdateDisplay(handles);

function IsAtEnd = IncrementSectionNumber(handles)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

IsAtEnd = false;

WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');

MaxSectionNumInThisWafer = ...
    length(AlignTargetPointListGuiGlobalStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray);
MaxWaferIndex = length(get(handles.WaferName_PopupMenu, 'String'));

SectionNum = str2num(get(handles.SectionNumber_EditBox, 'String'));

if (SectionNum+1) <= MaxSectionNumInThisWafer
    SectionNum = 1+ SectionNum;
    set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
elseif (WaferNameIndex+1) <= MaxWaferIndex
    WaferNameIndex = 1 + WaferNameIndex;
    set(handles.WaferName_PopupMenu,'Value',WaferNameIndex);
    SectionNum = 1;
    set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
else
    IsAtEnd = true;
end

% --- Executes on button press in Prev_pushbutton.
function Prev_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsAtBeginning = DecrementSectionNumber(handles);
if IsAtBeginning
 uiwait(msgbox('Already on first section of first wafer.'));
end
UpdateDisplay(handles);

function IsAtBeginning = DecrementSectionNumber(handles)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

IsAtBeginning = false;
WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');


SectionNum = str2num(get(handles.SectionNumber_EditBox, 'String'));

if (SectionNum-1) >= 1
    SectionNum = SectionNum - 1;
    set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
elseif (WaferNameIndex-1) >= 1
    WaferNameIndex = WaferNameIndex-1;
    set(handles.WaferName_PopupMenu,'Value',WaferNameIndex);
    MaxSectionNumInThisWafer = ...
        length(AlignTargetPointListGuiGlobalStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray);
    SectionNum = MaxSectionNumInThisWafer;
    set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
else
    IsAtBeginning = true;
end


function SectionNumber_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to SectionNumber_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionNumber_EditBox as text
%        str2double(get(hObject,'String')) returns contents of SectionNumber_EditBox as a double
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');
MaxSectionNumInThisWafer = ...
    length(AlignTargetPointListGuiGlobalStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray);

%check if legal section number
SectionNumStr = get(handles.SectionNumber_EditBox, 'String');

if isempty(str2num(SectionNumStr))
    uiwait(msgbox('Not a valid number. Setting to 1.'));
    SectionNum = 1;
    set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
else
    SectionNum = round(str2num(SectionNumStr)); %make sure integer
    if (SectionNum >=1) && (SectionNum <= MaxSectionNumInThisWafer)
        set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
    else
        SectionNum = 1;
        set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));
    end
end

UpdateDisplay(handles);




% --- Executes during object creation, after setting all properties.
function SectionNumber_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionNumber_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WaferName_PopupMenu.
function WaferName_PopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to WaferName_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WaferName_PopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WaferName_PopupMenu
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

%For new wafer set section number to 1
SectionNum = 1;
set(handles.SectionNumber_EditBox, 'String',num2str(SectionNum));

UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function WaferName_PopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaferName_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Play_pushbutton.
function Play_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

AlignTargetPointListGuiGlobalStruct.IsStopPlay = false;
IsAtEnd = false;

while ~IsAtEnd && ~AlignTargetPointListGuiGlobalStruct.IsStopPlay
    IsAtEnd = IncrementSectionNumber(handles);
    UpdateDisplay(handles);
end

% if strcmp('Play>>',get(handles.Play_pushbutton,'String'))
%     disp('strcmp true'); 
%     set(handles.Play_pushbutton,'String','STOP');
%     IsAtEnd = false;
% else
%     set(handles.Play_pushbutton,'String','Play>>');
%     IsAtEnd = true;
% end
% 
% while ~IsAtEnd 
%     IsAtEnd = IncrementSectionNumber(handles);
%     UpdateDisplay(handles);
% end





% --- Executes on button press in Stop_pushbutton.
function Stop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

AlignTargetPointListGuiGlobalStruct.IsStopPlay = true;


% --- Executes on button press in LoadToModify_pushbutton.
function LoadToModify_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadToModify_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');
WaferNameList = get(handles.WaferName_PopupMenu, 'String');
WaferName = WaferNameList{WaferNameIndex};
SectionNumStr = get(handles.SectionNumber_EditBox, 'String');
SectionIndex = str2num(SectionNumStr);

AlignedTargetList = AlignTargetPointListGuiGlobalStruct.AlignedTargetList;

%*** create a new aligned image 'NewImage_shifted' *********************************
XOffsetOfNewInPixels = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).XOffsetOfNewInPixels;
YOffsetOfNewInPixels = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).YOffsetOfNewInPixels;
r_offset = YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
c_offset = - XOffsetOfNewInPixels;
set(handles.R_OFFSET_edit,'String',num2str(r_offset));
set(handles.C_OFFSET_edit,'String',num2str(c_offset));

UpdateNewImageDisplay(handles)


function UpdateNewImageDisplay(handles)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');
WaferNameList = get(handles.WaferName_PopupMenu, 'String');
WaferName = WaferNameList{WaferNameIndex};
SectionNumStr = get(handles.SectionNumber_EditBox, 'String');
SectionIndex = str2num(SectionNumStr);

AlignedTargetList = AlignTargetPointListGuiGlobalStruct.AlignedTargetList;

%name of SectionOverviewsAlignedWithTemplate
ImageFileNameStr = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).ImageFileNameStr;
r = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).r;
c = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).c;
half_w = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_w;
half_h = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_h;

r_offset = str2num(get(handles.R_OFFSET_edit,'String'));
c_offset = str2num(get(handles.C_OFFSET_edit,'String'));

New_r = r - r_offset;
New_c = c - c_offset;
%now use these to grab a new image from the aligned overview
AlignTargetPointListGuiGlobalStruct.NewImage_shifted = imread(ImageFileNameStr, 'PixelRegion',...
    {[New_r-half_h New_r+half_h], [New_c-half_w New_c+half_w]});

%Also grab a 3x larger image centered at same region
AlignTargetPointListGuiGlobalStruct.NewImage_x3LargerROI_shifted = imread(ImageFileNameStr, 'PixelRegion',...
           {[New_r-(half_h*3+1) New_r+(half_h*3+1)], [New_c-(half_w*3+1) New_c+(half_w*3+1)]});

axes(handles.axes2);

if AlignTargetPointListGuiGlobalStruct.IsShowOnlyCurrentImage
    ColorCombinedImage(:,:,1) = double(AlignTargetPointListGuiGlobalStruct.NewImage_shifted)/255;
    ColorCombinedImage(:,:,2) = ColorCombinedImage(:,:,1);
    ColorCombinedImage(:,:,3) = double(AlignTargetPointListGuiGlobalStruct.TemplateImage)/255;
else
    ColorCombinedImage(:,:,1) = double(AlignTargetPointListGuiGlobalStruct.NewImage_shifted)/255 ;
    ColorCombinedImage(:,:,2) = double(AlignTargetPointListGuiGlobalStruct.PreviousImage)/255;%NOTE template will 'look' red because section is darker than background
    ColorCombinedImage(:,:,3) = double(AlignTargetPointListGuiGlobalStruct.TemplateImage)/255 ;
end

imshow(1-ColorCombinedImage);

% [r_max, c_max] = size(ColorCombinedImage(:,:,1));
% h1 = line([1, c_max],[r_max/2, r_max/2]); 
% set(h1,'Color',[1 0 0]);
% h2 = line([c_max/2, c_max/2],[1, r_max]); 
% set(h2,'Color',[1 0 0]);

function R_OFFSET_edit_Callback(hObject, eventdata, handles)
% hObject    handle to R_OFFSET_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R_OFFSET_edit as text
%        str2double(get(hObject,'String')) returns contents of R_OFFSET_edit as a double


% --- Executes during object creation, after setting all properties.
function R_OFFSET_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R_OFFSET_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C_OFFSET_edit_Callback(hObject, eventdata, handles)
% hObject    handle to C_OFFSET_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C_OFFSET_edit as text
%        str2double(get(hObject,'String')) returns contents of C_OFFSET_edit as a double


% --- Executes during object creation, after setting all properties.
function C_OFFSET_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_OFFSET_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RightShift_pushbutton.
function RightShift_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RightShift_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShiftPixels = str2num(get(handles.ShiftPixels_edit,'String'));

c_offset = str2num(get(handles.C_OFFSET_edit,'String'));
c_offset = c_offset + ShiftPixels;
set(handles.C_OFFSET_edit,'String',num2str(c_offset));
UpdateNewImageDisplay(handles);

% --- Executes on button press in LeftShift_pushbutton.
function LeftShift_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LeftShift_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShiftPixels = str2num(get(handles.ShiftPixels_edit,'String'));

c_offset = str2num(get(handles.C_OFFSET_edit,'String'));
c_offset = c_offset - ShiftPixels;
set(handles.C_OFFSET_edit,'String',num2str(c_offset));
UpdateNewImageDisplay(handles);

% --- Executes on button press in UpShift_pushbutton.
function UpShift_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpShift_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShiftPixels = str2num(get(handles.ShiftPixels_edit,'String'));

r_offset = str2num(get(handles.R_OFFSET_edit,'String'));
r_offset = r_offset - ShiftPixels;
set(handles.R_OFFSET_edit,'String',num2str(r_offset));
UpdateNewImageDisplay(handles);

% --- Executes on button press in DownShift_pushbutton.
function DownShift_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DownShift_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ShiftPixels = str2num(get(handles.ShiftPixels_edit,'String'));

r_offset = str2num(get(handles.R_OFFSET_edit,'String'));
r_offset = r_offset + ShiftPixels;
set(handles.R_OFFSET_edit,'String',num2str(r_offset));
UpdateNewImageDisplay(handles);

% --- Executes on button press in ToggleShiftSpeed_pushbutton.
function ToggleShiftSpeed_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleShiftSpeed_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ShiftPixels = str2num(get(handles.ShiftPixels_edit,'String'));
if ShiftPixels == 1
    ShiftPixels = 5;
elseif ShiftPixels == 5
    ShiftPixels = 50;
else
    ShiftPixels =1;
end
set(handles.ShiftPixels_edit,'String',num2str(ShiftPixels));

function ShiftPixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ShiftPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ShiftPixels_edit as text
%        str2double(get(hObject,'String')) returns contents of ShiftPixels_edit as a double


% --- Executes during object creation, after setting all properties.
function ShiftPixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShiftPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveAndUpdateMatFile_pushbutton.
function SaveAndUpdateMatFile_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAndUpdateMatFile_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignTargetPointListGuiGlobalStruct;

%get info
WaferNameIndex = get(handles.WaferName_PopupMenu, 'Value');
WaferNameList = get(handles.WaferName_PopupMenu, 'String');
WaferName = WaferNameList{WaferNameIndex};
SectionNumStr = get(handles.SectionNumber_EditBox, 'String');
SectionIndex = str2num(SectionNumStr);

%Save updated image 
ImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
    AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir, WaferName, SectionNumStr);
%disp(sprintf('ImageFileNameStr = %s',ImageFileNameStr));
imwrite(AlignTargetPointListGuiGlobalStruct.NewImage_shifted, ImageFileNameStr, 'tif');

%KH added to deal with 3x larger ROI images
ImageFile_x3LargerROI_NameStr = sprintf('%s\\LowResAligned_x3LargerROI_%s_Section_%s.tif',...
    AlignTargetPointListGuiGlobalStruct.AlignedTargetListDir, WaferName, SectionNumStr);
imwrite(AlignTargetPointListGuiGlobalStruct.NewImage_x3LargerROI_shifted, ImageFile_x3LargerROI_NameStr, 'tif');
%

%Save updated *.mat file
AlignedTargetList = AlignTargetPointListGuiGlobalStruct.AlignedTargetList;
r_offset = str2num(get(handles.R_OFFSET_edit,'String'));
c_offset = str2num(get(handles.C_OFFSET_edit,'String'));
YOffsetOfNewInPixels = r_offset; %Note: Here is where the reversed Y-Axis sign change is fixed
XOffsetOfNewInPixels = -c_offset;

AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).XOffsetOfNewInPixels = XOffsetOfNewInPixels;
AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).YOffsetOfNewInPixels = YOffsetOfNewInPixels;

AlignTargetPointListGuiGlobalStruct.AlignedTargetList = AlignedTargetList; %Save internal to this program
save(AlignTargetPointListGuiGlobalStruct.DataFileNameStr, 'AlignedTargetList'); %Save the updated *.mat file

UpdateDisplay(handles);
UpdateNewImageDisplay(handles);



% --- Executes on button press in ShowOnlyCurrentImage_checkbox.
function ShowOnlyCurrentImage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowOnlyCurrentImage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowOnlyCurrentImage_checkbox
global AlignTargetPointListGuiGlobalStruct;
AlignTargetPointListGuiGlobalStruct.IsShowOnlyCurrentImage = get(handles.ShowOnlyCurrentImage_checkbox,'Value');

UpdateDisplay(handles);
UpdateNewImageDisplay(handles);
