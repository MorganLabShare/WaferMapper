function varargout = SectionMaskGUI(varargin)
% SECTIONMASKGUI MATLAB code for SectionMaskGUI.fig
%      SECTIONMASKGUI, by itself, creates a new SECTIONMASKGUI or raises the existing
%      singleton*.
%
%      H = SECTIONMASKGUI returns the handle to a new SECTIONMASKGUI or the handle to
%      the existing singleton*.
%
%      SECTIONMASKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SECTIONMASKGUI.M with the given input arguments.
%
%      SECTIONMASKGUI('Property','Value',...) creates a new SECTIONMASKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SectionMaskGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SectionMaskGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SectionMaskGUI

% Last Modified by GUIDE v2.5 07-Jun-2017 16:06:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SectionMaskGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SectionMaskGUI_OutputFcn, ...
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


% --- Executes just before SectionMaskGUI is made visible.
function SectionMaskGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SectionMaskGUI (see VARARGIN)

% Choose default command line output for SectionMaskGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SectionMaskGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GuiGlobalsStruct invertThresh;
global SectionMaskGuiGlobals;


invertThresh = 0;
SectionMaskGuiGlobals.UpperThreshold = 125;
SectionMaskGuiGlobals.LowerThreshold = 50;
set(handles.editbox_UpperThreshold, 'String', num2str(SectionMaskGuiGlobals.UpperThreshold));
set(handles.slider_UpperThreshold, 'Value',SectionMaskGuiGlobals.UpperThreshold);
set(handles.editbox_LowerThreshold, 'String', num2str(SectionMaskGuiGlobals.LowerThreshold));
set(handles.slider_LowerThreshold, 'Value',SectionMaskGuiGlobals.LowerThreshold);

set(handles.slider_FullYDriftCompensation, 'Min', -1);
set(handles.slider_FullYDriftCompensation, 'Max', 1);
set(handles.slider_FullYDriftCompensation, 'Value', 0);
SectionMaskGuiGlobals.FullYDriftCompensation = get(handles.slider_FullYDriftCompensation,'Value');
set(handles.editbox_FullYDriftCompensation, 'String', num2str(SectionMaskGuiGlobals.FullYDriftCompensation));


set(handles.slider_Exponential, 'Min', .4);
set(handles.slider_Exponential, 'Max', 2);
set(handles.slider_Exponential, 'Value', 1);
SectionMaskGuiGlobals.Exponential = get(handles.slider_Exponential,'Value');
set(handles.editbox_Exponential, 'String', num2str(SectionMaskGuiGlobals.Exponential));


%load Full wafer map image and apply light filtering
FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Loading image file: %s',FullWaferImageFileNameStr);
FullMapImage = imread(FullWaferImageFileNameStr,'tif');
H_gaussian = fspecial('gaussian',[7 7],3); %fspecial('gaussian',[5 5],1.5);
FullMapImage = imfilter(FullMapImage,H_gaussian);
SectionMaskGuiGlobals.FullMapImage = FullMapImage;
%SectionMaskGuiGlobals.FullMapImage_Modified = [];

%HIGH PASS FILTER
% Image_fft = fft2(SectionMaskGuiGlobals.FullMapImage);
% [MaxR, MaxC] = size(Image_fft);
% CenterR = 1; %MaxR/2;
% CenterC = 1; %MaxC/2;
% Image_fft_CenterRemoved = Image_fft;
% for RIndex = 1:MaxR
%     for CIndex = 1:MaxC
%         DistToCenter = sqrt( (RIndex - CenterR)^2 + (CIndex - CenterC)^2);
%         if DistToCenter <= 10
%             Image_fft_CenterRemoved(RIndex, CIndex) = 0;
%         end
%     end
% end      
% SectionMaskGuiGlobals.FullMapImage = uint8(real(ifft2(Image_fft_CenterRemoved)));

axes(handles.axes_FullMapDisplay);
imshow(SectionMaskGuiGlobals.FullMapImage,[0,255]);

%load example section image and apply light filtering
SubImageForTemplateFileNameStr = sprintf('%s\\ExampleSectionImageCropped.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
SubImageForTemplate = imread(SubImageForTemplateFileNameStr,'tif');
SubImageForTemplate = imfilter(SubImageForTemplate,H_gaussian);
SectionMaskGuiGlobals.SubImageForTemplate = SubImageForTemplate;
axes(handles.axes_ExampleImageDisplay);
imshow(SectionMaskGuiGlobals.SubImageForTemplate,[0,255]);

[MaxR, MaxC] = size(SectionMaskGuiGlobals.SubImageForTemplate);
SectionMaskGuiGlobals.UpLeftCorner_R = 10;
SectionMaskGuiGlobals.UpLeftCorner_C = 10;
SectionMaskGuiGlobals.LowerRightCorner_R = MaxR - 10;
SectionMaskGuiGlobals.LowerRightCorner_C = MaxC - 10;

[MaxR, MaxC] = size(SectionMaskGuiGlobals.FullMapImage)
SectionMaskGuiGlobals.FullMapImage_Modified = zeros(MaxR, MaxC);

UpdateMaskImages(handles);

% --- Outputs from this function are returned to the command line.
function varargout = SectionMaskGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


















function editbox_UpperThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_UpperThreshold as text
%        str2double(get(hObject,'String')) returns contents of editbox_UpperThreshold as a double


% --- Executes during object creation, after setting all properties.
function editbox_UpperThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editbox_LowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_LowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_LowerThreshold as text
%        str2double(get(hObject,'String')) returns contents of editbox_LowerThreshold as a double


% --- Executes during object creation, after setting all properties.
function editbox_LowerThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_LowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function UpdateMaskImages(handles)

global SectionMaskGuiGlobals invertThresh;


%do full y contrast compensation 
%SectionMaskGuiGlobals.FullMapImage_Modified = [];
[MaxR, MaxC] = size(SectionMaskGuiGlobals.FullMapImage)

for RIndex = 1:MaxR
    t = (RIndex-1)/(MaxR-1);  %goes from 0 to 1
    te = ((t)^SectionMaskGuiGlobals.Exponential); %goes from 0 to 1
    Multiplier = 1+te*SectionMaskGuiGlobals.FullYDriftCompensation;
    SectionMaskGuiGlobals.FullMapImage_Modified(RIndex, :) = Multiplier *...
        SectionMaskGuiGlobals.FullMapImage(RIndex, :);
end

axes(handles.axes_FullMapDisplay);
imshow(SectionMaskGuiGlobals.FullMapImage_Modified,[0,255]);


%Threshold FullMapImage 
if invertThresh
GreaterThanLowerArray = SectionMaskGuiGlobals.FullMapImage_Modified<SectionMaskGuiGlobals.LowerThreshold;
LessThanUpperArray = SectionMaskGuiGlobals.FullMapImage_Modified>SectionMaskGuiGlobals.UpperThreshold;
else
GreaterThanLowerArray = SectionMaskGuiGlobals.FullMapImage_Modified>SectionMaskGuiGlobals.LowerThreshold;
LessThanUpperArray = SectionMaskGuiGlobals.FullMapImage_Modified<SectionMaskGuiGlobals.UpperThreshold;
    
end
InBoundsArray = double(GreaterThanLowerArray) .* double(LessThanUpperArray);
SectionMaskGuiGlobals.FullMapThresholded = 255*uint8(InBoundsArray);

axes(handles.axes_FullMapThresholdedDisplay);
imshow(SectionMaskGuiGlobals.FullMapThresholded,[0,255]);

%Threshold SectionMaskGuiGlobals.SubImageForTemplate
if invertThresh
GreaterThanLowerArray = SectionMaskGuiGlobals.SubImageForTemplate<SectionMaskGuiGlobals.LowerThreshold;
LessThanUpperArray = SectionMaskGuiGlobals.SubImageForTemplate>SectionMaskGuiGlobals.UpperThreshold;
else
 GreaterThanLowerArray = SectionMaskGuiGlobals.SubImageForTemplate>SectionMaskGuiGlobals.LowerThreshold;
LessThanUpperArray = SectionMaskGuiGlobals.SubImageForTemplate<SectionMaskGuiGlobals.UpperThreshold;
   
end

InBoundsArray = double(GreaterThanLowerArray) .* double(LessThanUpperArray);
SectionMaskGuiGlobals.SubImageForTemplateThresholded = 255*uint8(InBoundsArray);

%Now zero out everytthing outside of "keep box" bounds
[MaxR, MaxC] = size(SectionMaskGuiGlobals.SubImageForTemplateThresholded);
for r = 1:MaxR
    for c = 1:MaxC
        if (r<SectionMaskGuiGlobals.UpLeftCorner_R) || (r>SectionMaskGuiGlobals.LowerRightCorner_R) ||...
                (c<SectionMaskGuiGlobals.UpLeftCorner_C) || (c>SectionMaskGuiGlobals.LowerRightCorner_C)
            SectionMaskGuiGlobals.SubImageForTemplateThresholded(r,c) = 0;
        end
        
    end
end


%display ExampleImageMask
axes(handles.axes_ExampleImageMaskDisplay);
imshow(SectionMaskGuiGlobals.SubImageForTemplateThresholded,[0,255]);
%draw keep box bounds
h1 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.UpLeftCorner_R]);
h2 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.LowerRightCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
h3 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.UpLeftCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
h4 = line([SectionMaskGuiGlobals.LowerRightCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
set(h1,'Color',[1 1 0]);
set(h2,'Color',[1 1 0]);
set(h3,'Color',[1 1 0]);
set(h4,'Color',[1 1 0]);

%display ExampleImage
axes(handles.axes_ExampleImageDisplay);  
imshow(SectionMaskGuiGlobals.SubImageForTemplate,[0,255]);
h1 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.UpLeftCorner_R]);
h2 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.LowerRightCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
h3 = line([SectionMaskGuiGlobals.UpLeftCorner_C, SectionMaskGuiGlobals.UpLeftCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
h4 = line([SectionMaskGuiGlobals.LowerRightCorner_C, SectionMaskGuiGlobals.LowerRightCorner_C],...
    [SectionMaskGuiGlobals.UpLeftCorner_R, SectionMaskGuiGlobals.LowerRightCorner_R]);
set(h1,'Color',[1 1 0]);
set(h2,'Color',[1 1 0]);
set(h3,'Color',[1 1 0]);
set(h4,'Color',[1 1 0]);

% --- Executes on slider movement.
function slider_UpperThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SectionMaskGuiGlobals invertThresh;

SectionMaskGuiGlobals.UpperThreshold = get(hObject,'Value');
set(handles.editbox_UpperThreshold, 'String', num2str(SectionMaskGuiGlobals.UpperThreshold));

if SectionMaskGuiGlobals.LowerThreshold > SectionMaskGuiGlobals.UpperThreshold
%     SectionMaskGuiGlobals.LowerThreshold = SectionMaskGuiGlobals.UpperThreshold;
%     set(handles.editbox_LowerThreshold, 'String', num2str(SectionMaskGuiGlobals.LowerThreshold));
%     set(handles.slider_LowerThreshold, 'Value',SectionMaskGuiGlobals.LowerThreshold);
%     
    invertThresh = 1
else
    invertThresh = 0;
end
UpdateMaskImages(handles);


% --- Executes during object creation, after setting all properties.
function slider_UpperThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_UpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_LowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_LowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SectionMaskGuiGlobals invertThresh;

SectionMaskGuiGlobals.LowerThreshold = get(hObject,'Value');
set(handles.editbox_LowerThreshold, 'String', num2str(SectionMaskGuiGlobals.LowerThreshold));

if SectionMaskGuiGlobals.LowerThreshold > SectionMaskGuiGlobals.UpperThreshold
%     SectionMaskGuiGlobals.UpperThreshold = SectionMaskGuiGlobals.LowerThreshold;
%     set(handles.editbox_UpperThreshold, 'String', num2str(SectionMaskGuiGlobals.UpperThreshold));
%     set(handles.slider_UpperThreshold, 'Value',SectionMaskGuiGlobals.UpperThreshold);
    invertThresh = 1
else
    invertThresh = 0;
end
UpdateMaskImages(handles);


% --- Executes during object creation, after setting all properties.
function slider_LowerThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_LowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in button_SaveThresholdedImages.
function button_SaveThresholdedImages_Callback(hObject, eventdata, handles)
% hObject    handle to button_SaveThresholdedImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global SectionMaskGuiGlobals;

FullMapImage_Thresholded_FileNameStr = sprintf('%s\\FullMapImage_Thresholded.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Saving file: %s',FullMapImage_Thresholded_FileNameStr);
disp(MyStr);
imwrite(SectionMaskGuiGlobals.FullMapThresholded,FullMapImage_Thresholded_FileNameStr,'tif'); 


ExampleSectionImage_Thresholded_FileNameStr = sprintf('%s\\ExampleSectionImage_Thresholded.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
MyStr = sprintf('Saving file: %s',ExampleSectionImage_Thresholded_FileNameStr);
disp(MyStr);
imwrite(SectionMaskGuiGlobals.SubImageForTemplateThresholded,ExampleSectionImage_Thresholded_FileNameStr,'tif'); 

%Close this GUI
close(handles.output);

% --- Executes on button press in Button_DrawKeepBox.
function Button_DrawKeepBox_Callback(hObject, eventdata, handles)
% hObject    handle to Button_DrawKeepBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global SectionMaskGuiGlobals;

axes(handles.axes_ExampleImageDisplay);

MyStr = sprintf('Use mouse to drag box to be around only section. All outside box will turn black.');
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
    
    SectionMaskGuiGlobals.UpLeftCorner_R = UpLeftCorner_R;
    SectionMaskGuiGlobals.UpLeftCorner_C = UpLeftCorner_C;
    SectionMaskGuiGlobals.LowerRightCorner_R = LowerRightCorner_R;
    SectionMaskGuiGlobals.LowerRightCorner_C = LowerRightCorner_C;
    UpdateMaskImages(handles);
end


% --- Executes on slider movement.
function slider_FullYDriftCompensation_Callback(hObject, eventdata, handles)
% hObject    handle to slider_FullYDriftCompensation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SectionMaskGuiGlobals;

SectionMaskGuiGlobals.FullYDriftCompensation = get(hObject,'Value');
set(handles.editbox_FullYDriftCompensation, 'String', num2str(SectionMaskGuiGlobals.FullYDriftCompensation));
UpdateMaskImages(handles);



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


% --- Executes on slider movement.
function slider_Exponential_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Exponential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SectionMaskGuiGlobals;

SectionMaskGuiGlobals.Exponential = get(hObject,'Value');
set(handles.editbox_Exponential, 'String', num2str(SectionMaskGuiGlobals.Exponential));
UpdateMaskImages(handles);

% --- Executes during object creation, after setting all properties.
function slider_Exponential_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Exponential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_Exponential_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_Exponential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_Exponential as text
%        str2double(get(hObject,'String')) returns contents of editbox_Exponential as a double


% --- Executes during object creation, after setting all properties.
function editbox_Exponential_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_Exponential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in unthreshold_pushbutton.
function unthreshold_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to unthreshold_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GuiGlobalsStruct;
global SectionMaskGuiGlobals;

FullMapImage_Thresholded_FileNameStr = sprintf('%s\\FullMapImage_Thresholded.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Saving file: %s',FullMapImage_Thresholded_FileNameStr);
disp(MyStr);
imwrite(uint8(SectionMaskGuiGlobals.FullMapImage_Modified),FullMapImage_Thresholded_FileNameStr,'tif'); 


ExampleSectionImage_Thresholded_FileNameStr = sprintf('%s\\ExampleSectionImage_Thresholded.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
MyStr = sprintf('Saving file: %s',ExampleSectionImage_Thresholded_FileNameStr);
disp(MyStr);
imwrite(uint8(SectionMaskGuiGlobals.SubImageForTemplate),ExampleSectionImage_Thresholded_FileNameStr,'tif'); 

%Close this GUI
close(handles.output);


