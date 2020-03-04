function varargout = MontageParametersGUI(varargin)
% MONTAGEPARAMETERSGUI MATLAB code for MontageParametersGUI.fig
%      MONTAGEPARAMETERSGUI, by itself, creates a new MONTAGEPARAMETERSGUI or raises the existing
%      singleton*.
%
%      H = MONTAGEPARAMETERSGUI returns the handle to a new MONTAGEPARAMETERSGUI or the handle to
%      the existing singleton*.
%
%      MONTAGEPARAMETERSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MONTAGEPARAMETERSGUI.M with the given input arguments.
%
%      MONTAGEPARAMETERSGUI('Property','Value',...) creates a new MONTAGEPARAMETERSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MontageParametersGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MontageParametersGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MontageParametersGUI

% Last Modified by GUIDE v2.5 25-Feb-2013 09:44:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MontageParametersGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MontageParametersGUI_OutputFcn, ...
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



% --- Executes just before MontageParametersGUI is made visible.
function MontageParametersGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MontageParametersGUI (see VARARGIN)

% Choose default command line output for MontageParametersGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MontageParametersGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global HandleToThisFigure;
HandleToThisFigure = hObject;

UpdateAllFields(handles);


function UpdateAllFields(handles)
global GuiGlobalsStruct;
% global HandleToThisFigure;

set(handles.TileFOV_microns_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.TileFOV_microns));
set(handles.TileWidth_pixels_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.TileWidth_pixels));
set(handles.PixelSize_edit, 'String', num2str(1000*(GuiGlobalsStruct.MontageParameters.TileFOV_microns/GuiGlobalsStruct.MontageParameters.TileWidth_pixels)));
set(handles.TileDwellTime_microseconds_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds));

set(handles.MontageNorthAngle_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.MontageNorthAngle));
set(handles.NumberOfTileRows_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.NumberOfTileRows));
set(handles.NumberOfTileCols_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.NumberOfTileCols));
set(handles.PercentTileOverlap_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.PercentTileOverlap));
set(handles.XOffsetFromAlignTargetMicrons_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.XOffsetFromAlignTargetMicrons));
set(handles.YOffsetFromAlignTargetMicrons_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.YOffsetFromAlignTargetMicrons));

set(handles.AF_X_Offset_Microns_edit, 'String',num2str(GuiGlobalsStruct.MontageParameters.AF_X_Offset_Microns));
set(handles.AF_Y_Offset_Microns_edit, 'String',num2str(GuiGlobalsStruct.MontageParameters.AF_Y_Offset_Microns));

set(handles.AutofocusStartMag_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AutoFocusStartMag));
set(handles.IsPerformQualityCheckOnEveryAF_checkbox, 'Value', GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF);
set(handles.AFQualityThreshold_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFQualityThreshold));
set(handles.IsPerformQualCheckAfterEachImage_checkbox,'Value', GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage);
set(handles.ImageQualityThreshold_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ImageQualityThreshold));

set(handles.IsSingle_AF_ForWholeMontage_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage);
set(handles.IsSingle_AFASAF_ForWholeMontage_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage);
set(handles.IsAFOnEveryTile_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsAFOnEveryTile);
set(handles.IsAFASAFOnEveryTile_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsAFASAFOnEveryTile);
set(handles.IsPlaneFit_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsPlaneFit);

if ~isfield(GuiGlobalsStruct.MontageParameters,'IsXFit')
    GuiGlobalsStruct.MontageParameters.IsXFit = 0;
end
if ~isfield(GuiGlobalsStruct.MontageParameters,'Is4square')
    GuiGlobalsStruct.MontageParameters.Is4square = 0;
end
set(handles.IsXFit_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsXFit);
set(handles.Is4square_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.Is4square);






set(handles.RowDistBetweenAFPointsMicrons_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons));
set(handles.ColDistBetweenAFPointsMicrons_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons));
set(handles.AutofunctionScanrate_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AutofunctionScanrate));
set(handles.AutoFunctionImageStore_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore));
set(handles.IBSCContrast_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.IBSCContrast));
set(handles.IBSCBrightness_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.IBSCBrightness));
set(handles.ImageContrast_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ImageContrast));
set(handles.ImageBrightness_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ImageBrightness));




set(handles.IsAcquireOverviewImage_checkbox, 'Value', GuiGlobalsStruct.MontageParameters.IsAcquireOverviewImage);
set(handles.MontageOverviewImageFOV_microns_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.MontageOverviewImageFOV_microns));
set(handles.MontageOverviewImageWidth_pixels_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.MontageOverviewImageWidth_pixels));
set(handles.MontageOverviewImageHeight_pixels_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.MontageOverviewImageHeight_pixels));
set(handles.MontageOverviewImageDwellTime_microseconds_edit,'String',num2str(GuiGlobalsStruct.MontageParameters.MontageOverviewImageDwellTime_microseconds));

%cludge 
GuiGlobalsStruct.MontageTarget.MontageNorthAngle = GuiGlobalsStruct.MontageParameters.MontageNorthAngle;
GuiGlobalsStruct.MontageTarget.NumberOfTileRows = GuiGlobalsStruct.MontageParameters.NumberOfTileRows;
GuiGlobalsStruct.MontageTarget.NumberOfTileCols = GuiGlobalsStruct.MontageParameters.NumberOfTileCols;
GuiGlobalsStruct.MontageTarget.PercentTileOverlap = GuiGlobalsStruct.MontageParameters.PercentTileOverlap;
GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
GuiGlobalsStruct.MontageTarget.XOffsetFromAlignTargetMicrons = GuiGlobalsStruct.MontageParameters.XOffsetFromAlignTargetMicrons;
GuiGlobalsStruct.MontageTarget.YOffsetFromAlignTargetMicrons = GuiGlobalsStruct.MontageParameters.YOffsetFromAlignTargetMicrons;
GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns = GuiGlobalsStruct.MontageParameters.AF_X_Offset_Microns;
GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns = GuiGlobalsStruct.MontageParameters.AF_Y_Offset_Microns;


% UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
% 
% figure(HandleToThisFigure); %bring back to front

% --- Outputs from this function are returned to the command line.
function varargout = MontageParametersGUI_OutputFcn(hObject, eventdata, handles) 
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

if ~isempty(Value) %% && (Value >= 1) && (Value <= 8000)
    GuiGlobalsStruct.MontageParameters.TileFOV_microns = Value;
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

if ~isempty(Value) && (Value >= 1000) && (Value <= 32768)
    GuiGlobalsStruct.MontageParameters.TileWidth_pixels = Value;
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

if ~isempty(Value) && (Value >= .01) && (Value <= 10)
    GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds = Value;
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

function NumberOfTileRows_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfTileRows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfTileRows_edit as text
%        str2double(get(hObject,'String')) returns contents of NumberOfTileRows_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.NumberOfTileRows_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 100)
    GuiGlobalsStruct.MontageParameters.NumberOfTileRows = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function NumberOfTileRows_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfTileRows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberOfTileCols_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfTileCols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfTileCols_edit as text
%        str2double(get(hObject,'String')) returns contents of NumberOfTileCols_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.NumberOfTileCols_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 100)
    GuiGlobalsStruct.MontageParameters.NumberOfTileCols = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function NumberOfTileCols_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfTileCols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PercentTileOverlap_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PercentTileOverlap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PercentTileOverlap_edit as text
%        str2double(get(hObject,'String')) returns contents of PercentTileOverlap_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.PercentTileOverlap_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0) && (Value <= 100)
    GuiGlobalsStruct.MontageParameters.PercentTileOverlap = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function PercentTileOverlap_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PercentTileOverlap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function MontageOverviewImageFOV_microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MontageOverviewImageFOV_microns_edit as text
%        str2double(get(hObject,'String')) returns contents of MontageOverviewImageFOV_microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.MontageOverviewImageFOV_microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 10) && (Value <= 4096)
    GuiGlobalsStruct.MontageParameters.MontageOverviewImageFOV_microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function MontageOverviewImageFOV_microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MontageOverviewImageWidth_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MontageOverviewImageWidth_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of MontageOverviewImageWidth_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.MontageOverviewImageWidth_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 16384)
    GuiGlobalsStruct.MontageParameters.MontageOverviewImageWidth_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function MontageOverviewImageWidth_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MontageOverviewImageHeight_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageHeight_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MontageOverviewImageHeight_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of MontageOverviewImageHeight_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.MontageOverviewImageHeight_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 16384)
    GuiGlobalsStruct.MontageParameters.MontageOverviewImageHeight_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function MontageOverviewImageHeight_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageHeight_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MontageOverviewImageDwellTime_microseconds_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MontageOverviewImageDwellTime_microseconds_edit as text
%        str2double(get(hObject,'String')) returns contents of MontageOverviewImageDwellTime_microseconds_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.MontageOverviewImageDwellTime_microseconds_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= .01) && (Value <= 10)
    GuiGlobalsStruct.MontageParameters.MontageOverviewImageDwellTime_microseconds = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function MontageOverviewImageDwellTime_microseconds_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MontageOverviewImageDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function MontageNorthAngle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MontageNorthAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MontageNorthAngle_edit as text
%        str2double(get(hObject,'String')) returns contents of MontageNorthAngle_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.MontageNorthAngle_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= -360) && (Value <= 360)
    if Value < 0
        GuiGlobalsStruct.MontageParameters.MontageNorthAngle = 360+Value;
    else
        GuiGlobalsStruct.MontageParameters.MontageNorthAngle = Value;
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function MontageNorthAngle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MontageNorthAngle_edit (see GCBO)
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
SetMontageParametersDefaults();
UpdateAllFields(handles);


% --- Executes on button press in Close_button.
function Close_button_Callback(hObject, eventdata, handles)
% hObject    handle to Close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Close this GUI
close(handles.output);


% --- Executes on button press in IsAcquireOverviewImage_checkbox.
function IsAcquireOverviewImage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IsAcquireOverviewImage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IsAcquireOverviewImage_checkbox
global GuiGlobalsStruct;

Value = get(handles.IsAcquireOverviewImage_checkbox,'Value');

GuiGlobalsStruct.MontageParameters.IsAcquireOverviewImage = Value;

UpdateAllFields(handles);



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RowDistBetweenAFPointsMicrons_edit_Callback(hObject, eventdata, handles)
% hObject    handle to RowDistBetweenAFPointsMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RowDistBetweenAFPointsMicrons_edit as text
%        str2double(get(hObject,'String')) returns contents of RowDistBetweenAFPointsMicrons_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.RowDistBetweenAFPointsMicrons_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0) 
    GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function RowDistBetweenAFPointsMicrons_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RowDistBetweenAFPointsMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ColDistBetweenAFPointsMicrons_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ColDistBetweenAFPointsMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ColDistBetweenAFPointsMicrons_edit as text
%        str2double(get(hObject,'String')) returns contents of ColDistBetweenAFPointsMicrons_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.ColDistBetweenAFPointsMicrons_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0) 
    GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function ColDistBetweenAFPointsMicrons_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColDistBetweenAFPointsMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UpdateDisplay_pushbutton.
function UpdateDisplay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateDisplay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global HandleToThisFigure;

UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);

figure(HandleToThisFigure); %bring back to front



function PixelSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PixelSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelSize_edit as text
%        str2double(get(hObject,'String')) returns contents of PixelSize_edit as a double


% --- Executes during object creation, after setting all properties.
function PixelSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XOffsetFromAlignTargetMicrons_edit_Callback(hObject, eventdata, handles)
% hObject    handle to XOffsetFromAlignTargetMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XOffsetFromAlignTargetMicrons_edit as text
%        str2double(get(hObject,'String')) returns contents of XOffsetFromAlignTargetMicrons_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.XOffsetFromAlignTargetMicrons_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.XOffsetFromAlignTargetMicrons = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);



% --- Executes during object creation, after setting all properties.
function XOffsetFromAlignTargetMicrons_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XOffsetFromAlignTargetMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YOffsetFromAlignTargetMicrons_edit_Callback(hObject, eventdata, handles)
% hObject    handle to YOffsetFromAlignTargetMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YOffsetFromAlignTargetMicrons_edit as text
%        str2double(get(hObject,'String')) returns contents of YOffsetFromAlignTargetMicrons_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.YOffsetFromAlignTargetMicrons_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.YOffsetFromAlignTargetMicrons = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function YOffsetFromAlignTargetMicrons_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YOffsetFromAlignTargetMicrons_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AF_X_Offset_Microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AF_X_Offset_Microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AF_X_Offset_Microns_edit as text
%        str2double(get(hObject,'String')) returns contents of AF_X_Offset_Microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AF_X_Offset_Microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.AF_X_Offset_Microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AF_X_Offset_Microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AF_X_Offset_Microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AF_Y_Offset_Microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AF_Y_Offset_Microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AF_Y_Offset_Microns_edit as text
%        str2double(get(hObject,'String')) returns contents of AF_Y_Offset_Microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AF_Y_Offset_Microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.AF_Y_Offset_Microns = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AF_Y_Offset_Microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AF_Y_Offset_Microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in AutofocusMethod_uipanel.
function AutofocusMethod_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in AutofocusMethod_uipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%set(handles.IsSingle_AF_ForWholeMontage_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage);
Value = get(handles.IsSingle_AF_ForWholeMontage_radiobutton,'Value');
GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage = Value;

Value = get(handles.IsSingle_AFASAF_ForWholeMontage_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage = Value;

Value = get(handles.IsAFOnEveryTile_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.IsAFOnEveryTile = Value;

Value = get(handles.IsAFASAFOnEveryTile_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.IsAFASAFOnEveryTile = Value;

Value = get(handles.IsPlaneFit_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.IsPlaneFit = Value;


Value = get(handles.IsXFit_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.IsXFit = Value;

Value = get(handles.Is4square_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.Is4square = Value

UpdateAllFields(handles);

function AutofocusStartMag_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutofocusStartMag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutofocusStartMag_edit as text
%        str2double(get(hObject,'String')) returns contents of AutofocusStartMag_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutofocusStartMag_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 100) 
    GuiGlobalsStruct.MontageParameters.AutoFocusStartMag = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AutofocusStartMag_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutofocusStartMag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function QualityThreshold_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to QualityThreshold_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QualityThreshold_EditBox as text
%        str2double(get(hObject,'String')) returns contents of QualityThreshold_EditBox as a double


% --- Executes during object creation, after setting all properties.
function QualityThreshold_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualityThreshold_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IsPerformQualityCheckOnEveryAF_checkbox.
function IsPerformQualityCheckOnEveryAF_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IsPerformQualityCheckOnEveryAF_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IsPerformQualityCheckOnEveryAF_checkbox
global GuiGlobalsStruct;

Value = get(handles.IsPerformQualityCheckOnEveryAF_checkbox,'Value');

GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF = Value;

UpdateAllFields(handles);


function AFQualityThreshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AFQualityThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AFQualityThreshold_edit as text
%        str2double(get(hObject,'String')) returns contents of AFQualityThreshold_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AFQualityThreshold_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.AFQualityThreshold = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AFQualityThreshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AFQualityThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IsPerformQualCheckAfterEachImage_checkbox.
function IsPerformQualCheckAfterEachImage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IsPerformQualCheckAfterEachImage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IsPerformQualCheckAfterEachImage_checkbox
global GuiGlobalsStruct;

Value = get(handles.IsPerformQualCheckAfterEachImage_checkbox,'Value');

GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage = Value;

UpdateAllFields(handles);



function ImageQualityThreshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ImageQualityThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageQualityThreshold_edit as text
%        str2double(get(hObject,'String')) returns contents of ImageQualityThreshold_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.ImageQualityThreshold_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    GuiGlobalsStruct.MontageParameters.ImageQualityThreshold = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

% --- Executes during object creation, after setting all properties.
function ImageQualityThreshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageQualityThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TakeTestTile_button.
function TakeTestTile_button_Callback(hObject, eventdata, handles)
% hObject    handle to TakeTestTile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

h_fig = showinfowindow('Taking Test Tile Image... please wait','Message')
set(handles.TestTileQualResult_edit,'String','');

%this takes a test image with the current tile parameters
focOptions = [];
ImageParams.FOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
ImageParams.ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels;
ImageParams.ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels;
ImageParams.DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds;
[q] = takeFocusImage(focOptions, ImageParams);


set(handles.TestTileQualResult_edit,'String',num2str(q.quality, 3));

if ishandle(h_fig)
    close(h_fig);
end


% --- Executes on button press in TakeTestAFImage_button.
function TakeTestAFImage_button_Callback(hObject, eventdata, handles)
% hObject    handle to TakeTestAFImage_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

h_fig = showinfowindow('Taking Test AF Image... please wait','Message')
set(handles.TestAFImageQualResult_edit,'String','');

%this takes a test image with the current tile parameters
[q] = takeFocusImage();

set(handles.TestAFImageQualResult_edit,'String',num2str(q.quality, 3));

if ishandle(h_fig)
    close(h_fig);
end

function TestTileQualResult_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TestTileQualResult_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestTileQualResult_edit as text
%        str2double(get(hObject,'String')) returns contents of TestTileQualResult_edit as a double


% --- Executes during object creation, after setting all properties.
function TestTileQualResult_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestTileQualResult_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TestAFImageQualResult_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TestAFImageQualResult_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestAFImageQualResult_edit as text
%        str2double(get(hObject,'String')) returns contents of TestAFImageQualResult_edit as a double


% --- Executes during object creation, after setting all properties.
function TestAFImageQualResult_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestAFImageQualResult_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Is4square_radiobutton.
function Is4square_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Is4square_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Is4square_radiobutton


function AutofunctionScanrate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutofunctionScanrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutofunctionScanrate_edit as text
%        str2double(get(hObject,'String')) returns contents of AutofunctionScanrate_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutofunctionScanrate_edit,'String');
Value = str2num(ValueString)

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 15
        GuiGlobalsStruct.MontageParameters.AutofunctionScanrate = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

% --- Executes during object creation, after setting all properties.
function AutofunctionScanrate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutofunctionScanrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function AutofocusMethod_uipanel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AutofocusMethod_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






%



function AutoFunctionImageStore_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AutoFunctionImageStore_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AutoFunctionImageStore_edit as text
%        str2double(get(hObject,'String')) returns contents of AutoFunctionImageStore_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AutoFunctionImageStore_edit,'String');
Value = str2num(ValueString)

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 3
        GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end



% --- Executes during object creation, after setting all properties.
function AutoFunctionImageStore_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoFunctionImageStore_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IBSCBrightness_edit_Callback(hObject, eventdata, handles)
% hObject    handle to IBSCBrightness_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IBSCBrightness_edit as text
%        str2double(get(hObject,'String')) returns contents of IBSCBrightness_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.IBSCBrightness_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.IBSCBrightness = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end



% --- Executes during object creation, after setting all properties.
function IBSCBrightness_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IBSCBrightness_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IBSCContrast_edit_Callback(hObject, eventdata, handles)
% hObject    handle to IBSCContrast_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IBSCContrast_edit as text
%        str2double(get(hObject,'String')) returns contents of IBSCContrast_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.IBSCContrast_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.IBSCContrast = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

% --- Executes during object creation, after setting all properties.
function IBSCContrast_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IBSCContrast_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageContrast_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ImageContrast_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageContrast_edit as text
%        str2double(get(hObject,'String')) returns contents of ImageContrast_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.ImageContrast_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.ImageContrast = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

% --- Executes during object creation, after setting all properties.
function ImageContrast_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageContrast_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageBrightness_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ImageBrightness_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageBrightness_edit as text
%        str2double(get(hObject,'String')) returns contents of ImageBrightness_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.ImageBrightness_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.ImageBrightness = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

% --- Executes during object creation, after setting all properties.
function ImageBrightness_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageBrightness_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function retakeFocusType_edit_Callback(hObject, eventdata, handles)
% hObject    handle to retakeFocusType_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of retakeFocusType_edit as text
%        str2double(get(hObject,'String')) returns contents of retakeFocusType_edit as a double

global GuiGlobalsStruct;

ValueString = get(handles.ImageBrightness_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    Value = round(Value);
    if Value >= 1 || Value <= 10
        GuiGlobalsStruct.MontageParameters.retakeFocusType = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end


% --- Executes during object creation, after setting all properties.
function retakeFocusType_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to retakeFocusType_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
