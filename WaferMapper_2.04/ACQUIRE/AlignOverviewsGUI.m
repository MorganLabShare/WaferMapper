function varargout = AlignOverviewsGUI(varargin)
% ALIGNOVERVIEWSGUI MATLAB code for AlignOverviewsGUI.fig
%      ALIGNOVERVIEWSGUI, by itself, creates a new ALIGNOVERVIEWSGUI or raises the existing
%      singleton*.
%
%      H = ALIGNOVERVIEWSGUI returns the handle to a new ALIGNOVERVIEWSGUI or the handle to
%      the existing singleton*.
%
%      ALIGNOVERVIEWSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNOVERVIEWSGUI.M with the given input arguments.
%
%      ALIGNOVERVIEWSGUI('Property','Value',...) creates a new ALIGNOVERVIEWSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlignOverviewsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlignOverviewsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlignOverviewsGUI

% Last Modified by GUIDE v2.5 22-Feb-2011 03:33:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlignOverviewsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AlignOverviewsGUI_OutputFcn, ...
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


% --- Executes just before AlignOverviewsGUI is made visible.
function AlignOverviewsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AlignOverviewsGUI (see VARARGIN)

% Choose default command line output for AlignOverviewsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AlignOverviewsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

AlignOverviewsGuiGlobalStruct.ColorCombinedImage = [];

%load SectionOverviewTemplateCroppedFilledPeriphery.tif image, then apply light filtering
FileNameStr = sprintf('%s\\SectionOverviewTemplateCroppedFilledPeriphery.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
AlignOverviewsGuiGlobalStruct.SectionOverviewTemplateCroppedFilled = imread(FileNameStr,'tif');
AlignOverviewsGuiGlobalStruct.H_gaussian = fspecial('gaussian',[5 5],1.5);
AlignOverviewsGuiGlobalStruct.CenteredTemplateImage = ...
    imfilter(AlignOverviewsGuiGlobalStruct.SectionOverviewTemplateCroppedFilled,AlignOverviewsGuiGlobalStruct.H_gaussian);
%downsample
AlignOverviewsGuiGlobalStruct.DSFactor = 8; 
AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS = ...
    imresize(AlignOverviewsGuiGlobalStruct.CenteredTemplateImage,1/AlignOverviewsGuiGlobalStruct.DSFactor,'bilinear');


%determine max label in the SectionOverviewsDirectory
AlignOverviewsGuiGlobalStruct.MaxLabelNum = -1;
DirList = dir(GuiGlobalsStruct.SectionOverviewsDirectory);
for i = 1:length(DirList)
    if length(DirList(i).name) > 5
        if strcmp(DirList(i).name(((end-length('.tif'))+1:end)), '.tif')
            %Extract Label
            Label = DirList(i).name(length('SectionOverview_')+1:end-4);
            LableNum = str2num(Label);
            if LableNum > AlignOverviewsGuiGlobalStruct.MaxLabelNum
                AlignOverviewsGuiGlobalStruct.MaxLabelNum = LableNum;
            end
        end
    end
end

AlignOverviewsGuiGlobalStruct.SectionNum = 1;
LoadOverviewFromFile(handles, AlignOverviewsGuiGlobalStruct.SectionNum );
DisplayColorCombinedImage(handles);


function LoadOverviewFromFile(handles, SectionNum)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

Label = num2str(SectionNum);
set(handles.SectionNumber_EditBox,'String', Label);
AlignOverviewsGuiGlobalStruct.SectionNum = SectionNum;

%Load these THREE files:
TimeBeforeLoad = tic;
OverviewImageFileNameStr = sprintf('%s\\SectionOverview_%s.tif',GuiGlobalsStruct.SectionOverviewsDirectory,Label);
OverviewImageAlignedFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.tif',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);

%AlignmentParameters Data file
load(OverviewAlignedDataFileNameStr, 'AlignmentParameters');  
AlignOverviewsGuiGlobalStruct.r_offset = AlignmentParameters.r_offset;
AlignOverviewsGuiGlobalStruct.c_offset = AlignmentParameters.c_offset;
AlignOverviewsGuiGlobalStruct.AngleOffsetInDegrees = AlignmentParameters.AngleOffsetInDegrees;
set(handles.r_offset_EditBox,'String',num2str(AlignOverviewsGuiGlobalStruct.r_offset));
set(handles.c_offset_EditBox,'String',num2str(AlignOverviewsGuiGlobalStruct.c_offset));
set(handles.AngleOffset_EditBox,'String',num2str(AlignOverviewsGuiGlobalStruct.AngleOffsetInDegrees));
set(handles.r_offset_Slider, 'Value', -AlignOverviewsGuiGlobalStruct.r_offset); 
set(handles.c_offset_Slider, 'Value', AlignOverviewsGuiGlobalStruct.c_offset); 
set(handles.AngleOffset_Slider, 'Value', AlignOverviewsGuiGlobalStruct.AngleOffsetInDegrees); 

%load OverviewImage and apply light filtering
disp(sprintf('Loading image file: %s',OverviewImageFileNameStr));
AlignOverviewsGuiGlobalStruct.OverviewImage = imread(OverviewImageFileNameStr,'tif');
AlignOverviewsGuiGlobalStruct.OverviewImage = imfilter(AlignOverviewsGuiGlobalStruct.OverviewImage,AlignOverviewsGuiGlobalStruct.H_gaussian);

%load OverviewImageAligned image and apply light filtering
disp(sprintf('Loading image file: %s',OverviewImageAlignedFileNameStr));
AlignOverviewsGuiGlobalStruct.OverviewImageAligned = imread(OverviewImageAlignedFileNameStr,'tif');
AlignOverviewsGuiGlobalStruct.OverviewImageAligned = imfilter(AlignOverviewsGuiGlobalStruct.OverviewImageAligned,AlignOverviewsGuiGlobalStruct.H_gaussian);

TimeForLoad = toc(TimeBeforeLoad);
disp(sprintf('Time to load images: %0.5g seconds', TimeForLoad));

%downsample
AlignOverviewsGuiGlobalStruct.OverviewImageDS = ...
    imresize(AlignOverviewsGuiGlobalStruct.OverviewImage,1/AlignOverviewsGuiGlobalStruct.DSFactor,'bilinear');
AlignOverviewsGuiGlobalStruct.OverviewImageAlignedDS = ...
    imresize(AlignOverviewsGuiGlobalStruct.OverviewImageAligned,1/AlignOverviewsGuiGlobalStruct.DSFactor,'bilinear');

AlignOverviewsGuiGlobalStruct.OverviewImageTransformedDS = AlignOverviewsGuiGlobalStruct.OverviewImageDS;

ApplyTransform(handles);


function DisplayColorCombinedImage(handles)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

if 1 %color
axes(handles.axes1); %display for OverviewImageAlignedDS
ColorCombinedImage(:,:,1) = double(AlignOverviewsGuiGlobalStruct.OverviewImageAlignedDS)/255; 
ColorCombinedImage(:,:,2) = double(AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS)/255;%NOTE template will 'look' red because section is darker than background
ColorCombinedImage(:,:,3) = double(AlignOverviewsGuiGlobalStruct.OverviewImageAlignedDS)/255; 
%ColorCombinedImage = ColorCombinedImage - mode(ColorCombinedImage);
%ColorCombinedImage = ColorCombinedImage * 1.5/(max(ColorCombinedImage(:)));

imshow(ColorCombinedImage, 'InitialMagnification', 'fit');

axes(handles.axes2); %display for OverviewImageDS
ColorCombinedImage(:,:,1) = double(AlignOverviewsGuiGlobalStruct.OverviewImageTransformedDS)/255;
ColorCombinedImage(:,:,2) = double(AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS)/255;%NOTE template will 'look' red because section is darker than background
ColorCombinedImage(:,:,3) = double(AlignOverviewsGuiGlobalStruct.OverviewImageTransformedDS)/255;
%ColorCombinedImage = ColorCombinedImage - mode(ColorCombinedImage);

%ColorCombinedImage = ColorCombinedImage * 1.5/(max(ColorCombinedImage(:)));

imshow(ColorCombinedImage, 'InitialMagnification', 'fit');

else
    
    axes(handles.axes1); %display for OverviewImageAlignedDS
ColorCombinedImage = double(AlignOverviewsGuiGlobalStruct.OverviewImageAlignedDS)/255 - double(AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS)/255;%NOTE template will 'look' red because section is darker than background
ColorCombinedImage = repmat(ColorCombinedImage, [1 1 3]);
ColorCombinedImage = ColorCombinedImage * 2/(max(ColorCombinedImage(:)));
imshow(ColorCombinedImage, 'InitialMagnification', 'fit');

axes(handles.axes2); %display for OverviewImageDS
ColorCombinedImage = double(AlignOverviewsGuiGlobalStruct.OverviewImageTransformedDS)/255 - double(AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS)/255;%NOTE template will 'look' red because section is darker than background
ColorCombinedImage = repmat(ColorCombinedImage, [1 1 3])
ColorCombinedImage = ColorCombinedImage * 2/(max(ColorCombinedImage(:)));

imshow(ColorCombinedImage, 'InitialMagnification', 'fit');
    
    
end

% --- Outputs from this function are returned to the command line.
function varargout = AlignOverviewsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function OverviewFileName_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to OverviewFileName_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OverviewFileName_EditBox as text
%        str2double(get(hObject,'String')) returns contents of OverviewFileName_EditBox as a double


% --- Executes during object creation, after setting all properties.
function OverviewFileName_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverviewFileName_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Next_Button.
function Next_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Next_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

AlignOverviewsGuiGlobalStruct.SectionNum = 1 + AlignOverviewsGuiGlobalStruct.SectionNum;

if AlignOverviewsGuiGlobalStruct.SectionNum > AlignOverviewsGuiGlobalStruct.MaxLabelNum
    AlignOverviewsGuiGlobalStruct.SectionNum = AlignOverviewsGuiGlobalStruct.SectionNum - 1;
    uiwait(msgbox('Already on last section'));
    return;
end

LoadOverviewFromFile(handles, AlignOverviewsGuiGlobalStruct.SectionNum );
DisplayColorCombinedImage(handles);

% --- Executes on button press in Next_Button.
function Back_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Back_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

AlignOverviewsGuiGlobalStruct.SectionNum =  AlignOverviewsGuiGlobalStruct.SectionNum -1;

if AlignOverviewsGuiGlobalStruct.SectionNum < 1 
    AlignOverviewsGuiGlobalStruct.SectionNum = 1;
    uiwait(msgbox('Already on first section'));
    return;
end

LoadOverviewFromFile(handles, AlignOverviewsGuiGlobalStruct.SectionNum );
DisplayColorCombinedImage(handles);

function SectionNumber_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to SectionNumber_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionNumber_EditBox as text
%        str2double(get(hObject,'String')) returns contents of SectionNumber_EditBox as a double
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

MySectionNumberStr = get(handles.SectionNumber_EditBox,'String');

%[X,OK]=STR2NUM(S)
[SectionNum, IsOK] = str2num(MySectionNumberStr)
if ~IsOK
    LoadOverviewFromFile(handles, 1); %just reload first section and return
    DisplayColorCombinedImage(handles);
    return;
end
if SectionNum<1 || SectionNum>AlignOverviewsGuiGlobalStruct.MaxLabelNum
    LoadOverviewFromFile(handles, 1);%just reload first section and return
    DisplayColorCombinedImage(handles);
    return;
end

LoadOverviewFromFile(handles, SectionNum);
DisplayColorCombinedImage(handles);


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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;
OriginalImage = AlignOverviewsGuiGlobalStruct.OverviewImageDS;
NewImage = AlignOverviewsGuiGlobalStruct.CenteredTemplateImageDS;
AnglesInDegreesToTryArray = linspace(-6,6,5); %-6    -3     0     3     6
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] = ...
    CalcPixelOffsetAndAngleBetweenTwoImages_CenterRestricted(OriginalImage, NewImage, AnglesInDegreesToTryArray)






function r_offset_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to r_offset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_offset_EditBox as text
%        str2double(get(hObject,'String')) returns contents of r_offset_EditBox as a double
r_offset = str2num(get(handles.r_offset_EditBox,'String'));
set(handles.r_offset_Slider, 'Value',-r_offset); %note minus sign
ApplyTransform(handles);



% --- Executes during object creation, after setting all properties.
function r_offset_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_offset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c_offset_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to c_offset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_offset_EditBox as text
%        str2double(get(hObject,'String')) returns contents of c_offset_EditBox as a double
c_offset = str2num(get(handles.c_offset_EditBox,'String'));
set(handles.c_offset_Slider, 'Value',c_offset); %note minus sign
ApplyTransform(handles);

% --- Executes during object creation, after setting all properties.
function c_offset_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_offset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AngleOffset_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to AngleOffset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AngleOffset_EditBox as text
%        str2double(get(hObject,'String')) returns contents of AngleOffset_EditBox as a double
AngleOffset = str2num(get(handles.AngleOffset_EditBox,'String'));
set(handles.AngleOffset_Slider, 'Value',AngleOffset); %note minus sign
ApplyTransform(handles);

% --- Executes during object creation, after setting all properties.
function AngleOffset_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleOffset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ApplyTransform(handles)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;

% AlignOverviewsGuiGlobalStruct.r_offset = AlignmentParameters.r_offset;
% AlignOverviewsGuiGlobalStruct.c_offset = AlignmentParameters.c_offset;
% AlignOverviewsGuiGlobalStruct.AngleOffsetInDegrees = AlignmentParameters.AngleOffsetInDegrees;


r_offset = str2num(get(handles.r_offset_EditBox,'String'));
c_offset = str2num(get(handles.c_offset_EditBox,'String'));
AngleOffsetInDegrees = str2num(get(handles.AngleOffset_EditBox,'String'));

OverviewImage_rotated = imrotate(AlignOverviewsGuiGlobalStruct.OverviewImageDS,AngleOffsetInDegrees,'crop'); %note negative on angle
OverviewImage_rotated_shifted = 0*OverviewImage_rotated;
[MaxR, MaxC] = size(OverviewImage_rotated)
for r = 1:MaxR
    for c = 1:MaxC
        New_r = r + floor(r_offset/AlignOverviewsGuiGlobalStruct.DSFactor);
        New_c = c + floor(c_offset/AlignOverviewsGuiGlobalStruct.DSFactor);
        if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
            OverviewImage_rotated_shifted(New_r, New_c) = OverviewImage_rotated(r,c);
        end
    end
end

AlignOverviewsGuiGlobalStruct.OverviewImageTransformedDS = OverviewImage_rotated_shifted;

DisplayColorCombinedImage(handles);


% --- Executes on button press in OverwritePrevious_Button.
function OverwritePrevious_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OverwritePrevious_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AlignOverviewsGuiGlobalStruct;


h_fig = msgbox('Please wait...');

r_offset = floor(str2num(get(handles.r_offset_EditBox,'String')));
c_offset = floor(str2num(get(handles.c_offset_EditBox,'String')));
AngleOffsetInDegrees = str2num(get(handles.AngleOffset_EditBox,'String'));


%Apply to non-downsampled image
%START: KH Make background average value code 9_17_2011
[MaxR, MaxC] = size(AlignOverviewsGuiGlobalStruct.OverviewImage);
Temp1 = mean(AlignOverviewsGuiGlobalStruct.OverviewImage(5:MaxR-5, 5));
Temp2 = mean(AlignOverviewsGuiGlobalStruct.OverviewImage(5:MaxR-5, MaxC-5));
Temp3 = mean(AlignOverviewsGuiGlobalStruct.OverviewImage(5, 5:MaxC-5));
Temp4 = mean(AlignOverviewsGuiGlobalStruct.OverviewImage(MaxR-5, 5:MaxC-5));
AverageBorderGrayScale = uint8((Temp1 + Temp2 + Temp3 + Temp4)/4);
for r = 1:MaxR
  for c = 1:MaxC
    if AlignOverviewsGuiGlobalStruct.OverviewImage(r,c) == 0;
      AlignOverviewsGuiGlobalStruct.OverviewImage(r,c) = 1; %Bump all original black pixels up to a 1 value
    end
  end
end
%END: KH Make background average value code 9_17_2011
OverviewImage_rotated = imrotate(AlignOverviewsGuiGlobalStruct.OverviewImage,AngleOffsetInDegrees,'crop'); %note negative on angle
OverviewImage_rotated_shifted = 0*OverviewImage_rotated;
[MaxR, MaxC] = size(OverviewImage_rotated);
for r = 1:MaxR
    for c = 1:MaxC
        New_r = r + r_offset; %*AlignOverviewsGuiGlobalStruct.DSFactor;
        New_c = c + c_offset; %*AlignOverviewsGuiGlobalStruct.DSFactor;
        if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
            OverviewImage_rotated_shifted(New_r, New_c) = OverviewImage_rotated(r,c);
        end
    end
end

%START: KH Make background average value code 9_17_2011
[MaxR, MaxC] = size(OverviewImage_rotated_shifted)
for r = 1:MaxR
  for c = 1:MaxC
    if OverviewImage_rotated_shifted(r,c) == 0;
      OverviewImage_rotated_shifted(r,c) = AverageBorderGrayScale; %fill in all transform produced border pixels with original background average
    end
  end
end
%END: KH Make background average value code 9_17_2011


Label = get(handles.SectionNumber_EditBox,'String');
OverviewImageAlignedFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.tif',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);

imwrite(OverviewImage_rotated_shifted,OverviewImageAlignedFileNameStr,'tif');
AlignmentParameters.r_offset = r_offset;
AlignmentParameters.c_offset = c_offset;
AlignmentParameters.AngleOffsetInDegrees = AngleOffsetInDegrees;
save(OverviewAlignedDataFileNameStr, 'AlignmentParameters');

%refresh with newly created files
LoadOverviewFromFile(handles, AlignOverviewsGuiGlobalStruct.SectionNum );
DisplayColorCombinedImage(handles);

if ishandle(h_fig)
   close(h_fig); 
end

MyStr = sprintf('Overwrote files: %s and %s', OverviewImageAlignedFileNameStr,  OverviewAlignedDataFileNameStr);
uiwait(msgbox(MyStr));

% --- Executes on slider movement.
function r_offset_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to r_offset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

r_offset = -get(handles.r_offset_Slider, 'Value'); %note minus sign
MyStr = sprintf('r_offset_Slider = %d', r_offset);
disp(MyStr);

set(handles.r_offset_EditBox,'String',num2str(r_offset));

ApplyTransform(handles);



% --- Executes during object creation, after setting all properties.
function r_offset_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_offset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function c_offset_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to c_offset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
c_offset = get(handles.c_offset_Slider, 'Value'); %note minus sign
MyStr = sprintf('c_offset_Slider = %d', c_offset);
disp(MyStr);

set(handles.c_offset_EditBox,'String',num2str(c_offset));

ApplyTransform(handles);

% --- Executes during object creation, after setting all properties.
function c_offset_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_offset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function AngleOffset_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to AngleOffset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
AngleOffset = get(handles.AngleOffset_Slider, 'Value'); %note minus sign
MyStr = sprintf('AngleOffset_Slider = %d', AngleOffset);
disp(MyStr);

set(handles.AngleOffset_EditBox,'String',num2str(AngleOffset));

ApplyTransform(handles);

% --- Executes during object creation, after setting all properties.
function AngleOffset_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleOffset_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
