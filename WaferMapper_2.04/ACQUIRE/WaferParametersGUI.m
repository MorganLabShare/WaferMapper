function varargout = WaferParametersGUI(varargin)
% WAFERPARAMETERSGUI MATLAB code for WaferParametersGUI.fig
%      WAFERPARAMETERSGUI, by itself, creates a new WAFERPARAMETERSGUI or raises the existing
%      singleton*.
%
%      H = WAFERPARAMETERSGUI returns the handle to a new WAFERPARAMETERSGUI or the handle to
%      the existing singleton*.
%
%      WAFERPARAMETERSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAFERPARAMETERSGUI.M with the given input arguments.
%
%      WAFERPARAMETERSGUI('Property','Value',...) creates a new WAFERPARAMETERSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WaferParametersGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WaferParametersGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WaferParametersGUI

% Last Modified by GUIDE v2.5 06-Mar-2012 15:26:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WaferParametersGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @WaferParametersGUI_OutputFcn, ...
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


% --- Executes just before WaferParametersGUI is made visible.
function WaferParametersGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WaferParametersGUI (see VARARGIN)

% Choose default command line output for WaferParametersGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WaferParametersGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
UpdateAllFields(handles);


function UpdateAllFields(handles)
global GuiGlobalsStruct;

set(handles.TileFOV_microns_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.TileFOV_microns));
set(handles.TileWidth_pixels_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.TileWidth_pixels));
set(handles.TileDwellTime_microseconds_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.TileDwellTime_microseconds));
set(handles.DownSampleFactorForFullWaferOverviewImage_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.DownSampleFactorForFullWaferOverviewImage));
set(handles.PerformBacklashDuringFullWaferMontage_checkbox,'Value',GuiGlobalsStruct.WaferParameters.PerformBacklashDuringFullWaferMontage);

set(handles.LowResFiducialFOV_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.LowResFiducialFOV_microns));
set(handles.HighResFiducialFOV_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.HighResFiducialFOV_microns));
set(handles.FiducialWidth_pixels_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels));
set(handles.FiducialDwellTime_microseconds_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.FiducialDwellTime_microseconds));
set(handles.AutoMapAnglesToTryMinAngle_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMinAngle));
set(handles.AutoMapAnglesToTryMaxAngle_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMaxAngle));
set(handles.AutoMapAnglesToTryNumberOfAngles_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryNumberOfAngles));
set(handles.AutoMapFurtherDownsampleFactor_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.AutoMapFurtherDownsampleFactor));
set(handles.SectionOverviewFOV_microns_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns));
set(handles.SectionOverviewWidth_pixels_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels));
set(handles.SectionOverviewDwellTime_microseconds_edit,'String',num2str(GuiGlobalsStruct.WaferParameters.SectionOverviewDwellTime_microseconds));
%set(handles.AutoFunctionImageStore_edit, 'String', num2str(GuiGlobalsStruct.WaferParameters.AutoFunctionImageStore));
set(handles.PerformAutofocus_checkbox,'Value',GuiGlobalsStruct.WaferParameters.PerformAutofocus);

% --- Outputs from this function are returned to the command line.
function varargout = WaferParametersGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function TileFOV_microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TileFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TileFOV_microns_edit as text
%        str2double(get(hObject,'String')) returns contents of TileFOV_microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.TileFOV_microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 20000)
    GuiGlobalsStruct.WaferParameters.TileFOV_microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

    



% --- Executes during object creation, after setting all properties.
function TileFOV_microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TileFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TileWidth_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TileWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TileWidth_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of TileWidth_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.TileWidth_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 100) && (Value <= 16384)
    GuiGlobalsStruct.WaferParameters.TileWidth_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function TileWidth_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TileWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TileDwellTime_microseconds_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TileDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TileDwellTime_microseconds_edit as text
%        str2double(get(hObject,'String')) returns contents of TileDwellTime_microseconds_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.TileDwellTime_microseconds_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0.01) && (Value <= 10)
    GuiGlobalsStruct.WaferParameters.TileDwellTime_microseconds = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function TileDwellTime_microseconds_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TileDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DownSampleFactorForFullWaferOverviewImage_edit_Callback(hObject, eventdata, handles)
% hObject    handle to DownSampleFactorForFullWaferOverviewImage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DownSampleFactorForFullWaferOverviewImage_edit as text
%        str2double(get(hObject,'String')) returns contents of DownSampleFactorForFullWaferOverviewImage_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.DownSampleFactorForFullWaferOverviewImage_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 64)
    GuiGlobalsStruct.WaferParameters.DownSampleFactorForFullWaferOverviewImage = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function DownSampleFactorForFullWaferOverviewImage_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DownSampleFactorForFullWaferOverviewImage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LowResFiducialFOV_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LowResFiducialFOV_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LowResFiducialFOV_edit as text
%        str2double(get(hObject,'String')) returns contents of LowResFiducialFOV_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.LowResFiducialFOV_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 4096)
    GuiGlobalsStruct.WaferParameters.LowResFiducialFOV_microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);



% --- Executes during object creation, after setting all properties.
function LowResFiducialFOV_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LowResFiducialFOV_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HighResFiducialFOV_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HighResFiducialFOV_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighResFiducialFOV_edit as text
%        str2double(get(hObject,'String')) returns contents of HighResFiducialFOV_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.HighResFiducialFOV_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 100) && (Value <= 4096)
    GuiGlobalsStruct.WaferParameters.HighResFiducialFOV_microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function HighResFiducialFOV_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighResFiducialFOV_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FiducialWidth_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FiducialWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FiducialWidth_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of FiducialWidth_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.FiducialWidth_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 16384)
    GuiGlobalsStruct.WaferParameters.FiducialWidth_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function FiducialWidth_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FiducialWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FiducialDwellTime_microseconds_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FiducialDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FiducialDwellTime_microseconds_edit as text
%        str2double(get(hObject,'String')) returns contents of FiducialDwellTime_microseconds_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.FiducialDwellTime_microseconds_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= .01) && (Value <= 10)
    GuiGlobalsStruct.WaferParameters.FiducialDwellTime_microseconds = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function FiducialDwellTime_microseconds_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FiducialDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AutoMapAnglesToTryMinAngle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryMinAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutoMapAnglesToTryMinAngle_edit as text
%        str2double(get(hObject,'String')) returns contents of AutoMapAnglesToTryMinAngle_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutoMapAnglesToTryMinAngle_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= -180) && (Value <= 0)
    GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMinAngle = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AutoMapAnglesToTryMinAngle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryMinAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AutoMapAnglesToTryMaxAngle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryMaxAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutoMapAnglesToTryMaxAngle_edit as text
%        str2double(get(hObject,'String')) returns contents of AutoMapAnglesToTryMaxAngle_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutoMapAnglesToTryMaxAngle_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0) && (Value <= 180)
    GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMaxAngle = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function AutoMapAnglesToTryMaxAngle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryMaxAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AutoMapAnglesToTryNumberOfAngles_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryNumberOfAngles_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutoMapAnglesToTryNumberOfAngles_edit as text
%        str2double(get(hObject,'String')) returns contents of AutoMapAnglesToTryNumberOfAngles_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutoMapAnglesToTryNumberOfAngles_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 100)
    GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryNumberOfAngles = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function AutoMapAnglesToTryNumberOfAngles_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoMapAnglesToTryNumberOfAngles_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AutoMapFurtherDownsampleFactor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutoMapFurtherDownsampleFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutoMapFurtherDownsampleFactor_edit as text
%        str2double(get(hObject,'String')) returns contents of AutoMapFurtherDownsampleFactor_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutoMapFurtherDownsampleFactor_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 16)
    GuiGlobalsStruct.WaferParameters.AutoMapFurtherDownsampleFactor = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);



% --- Executes during object creation, after setting all properties.
function AutoMapFurtherDownsampleFactor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoMapFurtherDownsampleFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function SectionOverviewFOV_microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionOverviewFOV_microns_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionOverviewFOV_microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.SectionOverviewFOV_microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 100) && (Value <= 5000)
    GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function SectionOverviewFOV_microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionOverviewFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SectionOverviewWidth_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionOverviewWidth_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionOverviewWidth_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.SectionOverviewWidth_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 16384)
    GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function SectionOverviewWidth_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionOverviewWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SectionOverviewDwellTime_microseconds_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionOverviewDwellTime_microseconds_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionOvervieAFwellTime_microseconds_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.SectionOverviewDwellTime_microseconds_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= .01) && (Value <= 10)
    GuiGlobalsStruct.WaferParameters.SectionOverviewDwellTime_microseconds = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function SectionOverviewDwellTime_microseconds_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionOverviewDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ResetToDefault_button.
function ResetToDefault_button_Callback(hObject, eventdata, handles)
% hObject    handle to ResetToDefault_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetWaferParametersDefaults();
UpdateAllFields(handles);


% --- Executes on button press in PerformBacklashDuringFullWaferMontage_checkbox.
function PerformBacklashDuringFullWaferMontage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to PerformBacklashDuringFullWaferMontage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PerformBacklashDuringFullWaferMontage_checkbox
global GuiGlobalsStruct;

Value = get(handles.PerformBacklashDuringFullWaferMontage_checkbox,'Value');


GuiGlobalsStruct.WaferParameters.PerformBacklashDuringFullWaferMontage = Value;

UpdateAllFields(handles);


% --- Executes on button press in PerformAutofocus_checkbox.
function PerformAutofocus_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to PerformAutofocus_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PerformAutofocus_checkbox
global GuiGlobalsStruct;

Value = get(handles.PerformAutofocus_checkbox,'Value');


GuiGlobalsStruct.WaferParameters.PerformAutofocus = Value;

UpdateAllFields(handles);


% --- Executes on button press in Close_pushbutton.
function Close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Close this GUI
close(handles.output);
