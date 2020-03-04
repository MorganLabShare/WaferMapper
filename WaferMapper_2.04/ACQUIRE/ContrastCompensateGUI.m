function varargout = ContrastCompensateGUI(varargin)
% CONTRASTCOMPENSATEGUI MATLAB code for ContrastCompensateGUI.fig
%      CONTRASTCOMPENSATEGUI, by itself, creates a new CONTRASTCOMPENSATEGUI or raises the existing
%      singleton*.
%
%      H = CONTRASTCOMPENSATEGUI returns the handle to a new CONTRASTCOMPENSATEGUI or the handle to
%      the existing singleton*.
%
%      CONTRASTCOMPENSATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTRASTCOMPENSATEGUI.M with the given input arguments.
%
%      CONTRASTCOMPENSATEGUI('Property','Value',...) creates a new CONTRASTCOMPENSATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ContrastCompensateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ContrastCompensateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ContrastCompensateGUI

% Last Modified by GUIDE v2.5 03-Jul-2011 16:40:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ContrastCompensateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ContrastCompensateGUI_OutputFcn, ...
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


% --- Executes just before ContrastCompensateGUI is made visible.
function ContrastCompensateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ContrastCompensateGUI (see VARARGIN)

% Choose default command line output for ContrastCompensateGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ContrastCompensateGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GuiGlobalsStruct;
global ContrastCompensationGUIGlobals;

FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Loading image file: %s',FullWaferImageFileNameStr);
disp(MyStr);
FullMapImage = imread(FullWaferImageFileNameStr,'tif');
ContrastCompensationGUIGlobals.FullMapImage = double(FullMapImage)/255;
ContrastCompensationGUIGlobals.FullMapImage_Modified = 0*ContrastCompensationGUIGlobals.FullMapImage;

axes(handles.axes1);
imshow(ContrastCompensationGUIGlobals.FullMapImage,[0,1]);
axes(handles.axes2);
imshow(ContrastCompensationGUIGlobals.FullMapImage_Modified,[0,1]);

ExampleSectionImageFileNameStr = sprintf('%s\\ExampleSectionImage.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
MyStr = sprintf('Loading image file: %s',ExampleSectionImageFileNameStr);
disp(MyStr);
ExampleSectionImage = imread(ExampleSectionImageFileNameStr,'tif');
ContrastCompensationGUIGlobals.ExampleSectionImage = double(ExampleSectionImage)/255;
ExamSectionImagSize=size(ContrastCompensationGUIGlobals.ExampleSectionImage)
ContrastCompensationGUIGlobals.ExampleSectionImage_Modified = 0*ContrastCompensationGUIGlobals.ExampleSectionImage;

axes(handles.axes3);
imshow(ContrastCompensationGUIGlobals.ExampleSectionImage,[0,1]);
axes(handles.axes4);
imshow(ContrastCompensationGUIGlobals.ExampleSectionImage_Modified,[0,1]);

set(handles.slider_ContrastCompensationAtEdge, 'Min', .4);
set(handles.slider_ContrastCompensationAtEdge, 'Max', 2.0);
set(handles.slider_ContrastCompensationAtEdge, 'Value', 1);
ContrastCompensationGUIGlobals.ContrastCompensationAtEdge = get(handles.slider_ContrastCompensationAtEdge,'Value');
set(handles.editbox_ContrastCompensationAtEdge, 'String', num2str(ContrastCompensationGUIGlobals.ContrastCompensationAtEdge));

set(handles.slider_ExponentOnDist, 'Min', .5);
set(handles.slider_ExponentOnDist, 'Max', 3);
set(handles.slider_ExponentOnDist, 'Value', 1);
ContrastCompensationGUIGlobals.ExponentOnDist = get(handles.slider_ExponentOnDist,'Value');
set(handles.editbox_ExponentOnDist, 'String', num2str(ContrastCompensationGUIGlobals.ExponentOnDist));

set(handles.slider_OffsetX, 'Min', -1);
set(handles.slider_OffsetX, 'Max', 1);
set(handles.slider_OffsetX, 'Value', 0);
ContrastCompensationGUIGlobals.OffsetX = get(handles.slider_OffsetX,'Value');
set(handles.editbox_OffsetX, 'String', num2str(ContrastCompensationGUIGlobals.OffsetX));

set(handles.slider_OffsetY, 'Min', -1);
set(handles.slider_OffsetY, 'Max', 1);
set(handles.slider_OffsetY, 'Value', 0);
ContrastCompensationGUIGlobals.OffsetY = get(handles.slider_OffsetY,'Value');
set(handles.editbox_OffsetY, 'String', num2str(ContrastCompensationGUIGlobals.OffsetY));

set(handles.slider_FullYDriftCompensation, 'Min', -1);
set(handles.slider_FullYDriftCompensation, 'Max', 1);
set(handles.slider_FullYDriftCompensation, 'Value', 0);
ContrastCompensationGUIGlobals.FullYDriftCompensation = get(handles.slider_FullYDriftCompensation,'Value');
set(handles.editbox_FullYDriftCompensation, 'String', num2str(ContrastCompensationGUIGlobals.FullYDriftCompensation));

KHAdjustContrast(handles);

% --- Outputs from this function are returned to the command line.
function varargout = ContrastCompensateGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_ContrastCompensationAtEdge_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ContrastCompensationAtEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ContrastCompensationGUIGlobals;
ContrastCompensationGUIGlobals.ContrastCompensationAtEdge = get(hObject,'Value');
set(handles.editbox_ContrastCompensationAtEdge, 'String', num2str(ContrastCompensationGUIGlobals.ContrastCompensationAtEdge));
KHAdjustContrast(handles);

% --- Executes during object creation, after setting all properties.
function slider_ContrastCompensationAtEdge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ContrastCompensationAtEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_ContrastCompensationAtEdge_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_ContrastCompensationAtEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_ContrastCompensationAtEdge as text
%        str2double(get(hObject,'String')) returns contents of editbox_ContrastCompensationAtEdge as a double


% --- Executes during object creation, after setting all properties.
function editbox_ContrastCompensationAtEdge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_ContrastCompensationAtEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_ExponentOnDist_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ExponentOnDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ContrastCompensationGUIGlobals;
ContrastCompensationGUIGlobals.ExponentOnDist = get(hObject,'Value');
set(handles.editbox_ExponentOnDist, 'String', num2str(ContrastCompensationGUIGlobals.ExponentOnDist));
KHAdjustContrast(handles);

% --- Executes during object creation, after setting all properties.
function slider_ExponentOnDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ExponentOnDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_ExponentOnDist_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_ExponentOnDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_ExponentOnDist as text
%        str2double(get(hObject,'String')) returns contents of editbox_ExponentOnDist as a double


% --- Executes during object creation, after setting all properties.
function editbox_ExponentOnDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_ExponentOnDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function KHAdjustContrast(handles)
global ContrastCompensationGUIGlobals;
global GuiGlobalsStruct;

NumTileColumns = GuiGlobalsStruct.FullMapData.NumTileColumns;
NumTileRows = GuiGlobalsStruct.FullMapData.NumTileRows;

DownsampleFactor = GuiGlobalsStruct.FullMapData.DownsampleFactor;
DownsampledTileWidthInPixels = GuiGlobalsStruct.FullMapData.ImageWidthInPixels/DownsampleFactor
DownsampledTileHeightInPixels = GuiGlobalsStruct.FullMapData.ImageHeightInPixels/DownsampleFactor

%Create contrast compensation array
ContrastCompensationArray = double(ones(DownsampledTileWidthInPixels,DownsampledTileHeightInPixels));

CompensationValueAtCenter = 1;
CompensationValueAtEdge = ContrastCompensationGUIGlobals.ContrastCompensationAtEdge;
ExponentOnDist = ContrastCompensationGUIGlobals.ExponentOnDist;
OffsetX = ContrastCompensationGUIGlobals.OffsetX;
OffsetY = ContrastCompensationGUIGlobals.OffsetY;
for RIndex = 1:DownsampledTileWidthInPixels
    for CIndex = 1:DownsampledTileHeightInPixels
        NormalizedDistFromCenter = sqrt(((RIndex - OffsetY*DownsampledTileHeightInPixels/4) - DownsampledTileHeightInPixels/2)^2 +...
            ((CIndex - OffsetX*DownsampledTileWidthInPixels/4) - DownsampledTileWidthInPixels/2)^2)/(DownsampledTileWidthInPixels/2);
        NormalizedDistFromTopRightCorner = sqrt(((RIndex - OffsetY*DownsampledTileHeightInPixels/4) - 0)^2 +...
            ((CIndex - OffsetX*DownsampledTileWidthInPixels/4) - DownsampledTileWidthInPixels)^2)/(DownsampledTileWidthInPixels/2);
        if get(handles.CompensationForSE2Imaging_checkbox,'Value') == 1
            ContrastCompensationArray(RIndex,CIndex) = (CompensationValueAtEdge-CompensationValueAtCenter)*NormalizedDistFromTopRightCorner^ExponentOnDist + CompensationValueAtCenter;
        else
            ContrastCompensationArray(RIndex,CIndex) = (CompensationValueAtEdge-CompensationValueAtCenter)*NormalizedDistFromCenter^ExponentOnDist + CompensationValueAtCenter;
        end
    end
end

for RowIndex=1:NumTileRows

    for ColumnIndex=1:NumTileColumns
        
        ContrastCompensationGUIGlobals.FullMapImage_Modified(((RowIndex-1)*DownsampledTileHeightInPixels+1):(RowIndex*DownsampledTileHeightInPixels),...
            ((ColumnIndex-1)*DownsampledTileWidthInPixels+1):(ColumnIndex*DownsampledTileWidthInPixels))...
            = ContrastCompensationArray.*ContrastCompensationGUIGlobals.FullMapImage(((RowIndex-1)*DownsampledTileHeightInPixels+1):(RowIndex*DownsampledTileHeightInPixels),...
            ((ColumnIndex-1)*DownsampledTileWidthInPixels+1):(ColumnIndex*DownsampledTileWidthInPixels));
        
    end
end

%do full y contrast compensation
[MaxR, MaxC] = size(ContrastCompensationGUIGlobals.FullMapImage_Modified);
for RIndex = 1:MaxR
    a = ContrastCompensationGUIGlobals.FullYDriftCompensation;
    Multiplier = 1 + a*((RIndex - 1) - (MaxR/2))/MaxR;
    ContrastCompensationGUIGlobals.FullMapImage_Modified(RIndex, :) = Multiplier *...
        ContrastCompensationGUIGlobals.FullMapImage_Modified(RIndex, :);
end

axes(handles.axes2);
imshow(ContrastCompensationGUIGlobals.FullMapImage_Modified,[0,1]);

ContrastCompensationArray_ForNonDownSampledExampleImage = imresize(ContrastCompensationArray,GuiGlobalsStruct.FullMapData.DownsampleFactor,'bilinear');
NonDownSampExampleI = size(ContrastCompensationArray_ForNonDownSampledExampleImage)
ContrastCompensationGUIGlobals.ExampleSectionImage_Modified =...
            ContrastCompensationArray_ForNonDownSampledExampleImage.*ContrastCompensationGUIGlobals.ExampleSectionImage;

axes(handles.axes4);
imshow(ContrastCompensationGUIGlobals.ExampleSectionImage_Modified,[0,1]);

% --- Executes on slider movement.
function slider_OffsetX_Callback(hObject, eventdata, handles)
% hObject    handle to slider_OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ContrastCompensationGUIGlobals;
ContrastCompensationGUIGlobals.OffsetX = get(hObject,'Value');
set(handles.editbox_OffsetX, 'String', num2str(ContrastCompensationGUIGlobals.OffsetX));
KHAdjustContrast(handles);

% --- Executes during object creation, after setting all properties.
function slider_OffsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_OffsetX_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_OffsetX as text
%        str2double(get(hObject,'String')) returns contents of editbox_OffsetX as a double


% --- Executes during object creation, after setting all properties.
function editbox_OffsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_OffsetY_Callback(hObject, eventdata, handles)
% hObject    handle to slider_OffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ContrastCompensationGUIGlobals;
ContrastCompensationGUIGlobals.OffsetY = get(hObject,'Value');
set(handles.editbox_OffsetY, 'String', num2str(ContrastCompensationGUIGlobals.OffsetY));
KHAdjustContrast(handles);

% --- Executes during object creation, after setting all properties.
function slider_OffsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_OffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_OffsetY_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_OffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_OffsetY as text
%        str2double(get(hObject,'String')) returns contents of editbox_OffsetY as a double


% --- Executes during object creation, after setting all properties.
function editbox_OffsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_OffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_SaveModifiedImage.
function button_SaveModifiedImage_Callback(hObject, eventdata, handles)
% hObject    handle to button_SaveModifiedImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global ContrastCompensationGUIGlobals;

%Note: I never overwrite the FullMapImage_BeforeContrastCompensation.tif if
%it already exists
BackupOfOriginalFullWaferImageFileNameStr = sprintf('%s\\FullMapImage_BeforeContrastCompensation.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
if ~exist(BackupOfOriginalFullWaferImageFileNameStr,'file')
    MyStr = sprintf('Saving backup of original image file: %s',BackupOfOriginalFullWaferImageFileNameStr);
    disp(MyStr);
    imwrite(ContrastCompensationGUIGlobals.FullMapImage,BackupOfOriginalFullWaferImageFileNameStr,'tif'); %don't overwrite if this is second time
end

FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Overwriting original image file: %s',FullWaferImageFileNameStr);
disp(MyStr);
imwrite(ContrastCompensationGUIGlobals.FullMapImage_Modified,FullWaferImageFileNameStr,'tif');

BackupOfOriginalExampleSectionImageFileNameStr = sprintf('%s\\ExampleSectionImage_BeforeContrastCompensation.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
if ~exist(BackupOfOriginalExampleSectionImageFileNameStr,'file')
    MyStr = sprintf('Saving backup of original image file: %s',BackupOfOriginalExampleSectionImageFileNameStr);
    disp(MyStr);
    imwrite(ContrastCompensationGUIGlobals.ExampleSectionImage,BackupOfOriginalExampleSectionImageFileNameStr,'tif'); %don't overwrite if this is second time
end
ExampleSectionImageFileNameStr = sprintf('%s\\ExampleSectionImage.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
MyStr = sprintf('Overwriting original image file: %s',ExampleSectionImageFileNameStr);
disp(MyStr);
imwrite(ContrastCompensationGUIGlobals.ExampleSectionImage_Modified,ExampleSectionImageFileNameStr,'tif');

%Close this GUI
close(handles.output);


% --- Executes on slider movement.
function slider_FullYDriftCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to slider_FullYDriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ContrastCompensationGUIGlobals;
ContrastCompensationGUIGlobals.FullYDriftCompensation = get(hObject,'Value');
set(handles.editbox_FullYDriftCompensation, 'String', num2str(ContrastCompensationGUIGlobals.FullYDriftCompensation));
KHAdjustContrast(handles);

% --- Executes during object creation, after setting all properties.
function slider_FullYDriftCompensation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_FullYDriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_FullYDriftCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_FullYDriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_FullYDriftCompensation as text
%        str2double(get(hObject,'String')) returns contents of editbox_FullYDriftCompensation as a double


% --- Executes during object creation, after setting all properties.
function editbox_FullYDriftCompensation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_FullYDriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CompensationForSE2Imaging_checkbox.
function CompensationForSE2Imaging_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to CompensationForSE2Imaging_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CompensationForSE2Imaging_checkbox
KHAdjustContrast(handles);