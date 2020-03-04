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

% Last Modified by GUIDE v2.5 19-Dec-2017 18:49:41

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

try
    UpdateAllFields(handles);
catch 
   'Montage parameters appear incompatable with parameter gui version' 
   FixMontageParametersDefaults 
   UpdateAllFields(handles);
end


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
if ~isfield(GuiGlobalsStruct.MontageParameters,'IsTargetFocus')
    GuiGlobalsStruct.MontageParameters.IsTargetFocus = true;
end
set(handles.IsTargetFocus_checkbox,'Value', GuiGlobalsStruct.MontageParameters.IsTargetFocus);

set(handles.IsSingle_AF_ForWholeMontage_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage);
set(handles.IsSingle_AFASAF_ForWholeMontage_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage);
set(handles.IsAFOnEveryTile_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsAFOnEveryTile);
set(handles.IsAFASAFOnEveryTile_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsAFASAFOnEveryTile);
set(handles.IsPlaneFit_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsPlaneFit);
set(handles.IsXFit_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.IsXFit);
set(handles.noFocus_radiobutton, 'Value', GuiGlobalsStruct.MontageParameters.noFocus);


set(handles.RowDistBetweenAFPointsMicrons_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons));
set(handles.ColDistBetweenAFPointsMicrons_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons));
set(handles.AutofunctionScanrate_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AutofunctionScanrate));
set(handles.AutoFunctionImageStore_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore));
set(handles.IBSCContrast_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.IBSCContrast));
set(handles.IBSCBrightness_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.IBSCBrightness));
set(handles.ImageContrast_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ImageContrast));

set(handles.ImageBrightness_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.ImageBrightness));
set(handles.AFStartingWD_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFStartingWD*1000)); % Need to convert back to mm
set(handles.WDResetThreshold_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.WDResetThreshold*1000)); % Need to convert back to mm
set(handles.StartingStigX_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.StartingStigX));
set(handles.StartingStigY_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.StartingStigY));
set(handles.StigResetThreshold_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.StigResetThreshold));
set(handles.AFTestImageFOV_microns_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns));
set(handles.AFTestImageWidth_pixels_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels));
set(handles.AFTestImageDwellTime_microseconds_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds));
set(handles.SameAsTileParameters_checkbox, 'Value', GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters);


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


% --- Executes during object creation, after setting all properties.
function AutofocusMethod_uipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutofocusMethod_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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

Value = get(handles.noFocus_radiobutton, 'Value');
GuiGlobalsStruct.MontageParameters.noFocus = Value;

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
focOptions = [];
AFImageParams.FOV_microns = GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns;
AFImageParams.ImageWidthInPixels = GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels;
AFImageParams.ImageHeightInPixels = GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels;
AFImageParams.DwellTimeInMicroseconds = GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds;
[q] = takeFocusImage(focOptions,AFImageParams);

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
    if Value >= 0 || Value <= 15
        GuiGlobalsStruct.MontageParameters.AutofunctionScanrate = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

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
    if Value >= 0 || Value <= 3
        GuiGlobalsStruct.MontageParameters.AutoFunctionImageStore = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


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
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.IBSCBrightness = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


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
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.IBSCContrast = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

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
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.ImageContrast = Value;
    else
        
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

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
    if Value >= 0 || Value <= 100
        GuiGlobalsStruct.MontageParameters.ImageBrightness = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

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
    if Value >= 1 || Value <= 100
        GuiGlobalsStruct.MontageParameters.retakeFocusType = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


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


% --- Executes during object deletion, before destroying properties.
function AutofocusMethod_uipanel_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to AutofocusMethod_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Is4square_radiobutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Is4square_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in IsTargetFocus_checkbox.
function IsTargetFocus_checkbox_Callback(hObject, eventdata, handles)

global GuiGlobalsStruct
Value = get(handles.IsTargetFocus_checkbox,'Value');
GuiGlobalsStruct.MontageParameters.IsTargetFocus = Value;


% hObject    handle to IsTargetFocus_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IsTargetFocus_checkbox


% --- Executes during object creation, after setting all properties.
function IsTargetFocus_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IsTargetFocus_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in autoBC_checkbox.
function autoBC_checkbox_Callback(hObject, eventdata, handles)
global GuiGlobalsStruct
GuiGlobalsStruct.MontageParameters.IsAutoBrightnessContrast = get(hObject,'Value')
% hObject    handle to autoBC_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoBC_checkbox


% --- Executes on button press in autoBC_pushbutton.
function autoBC_pushbutton_Callback(hObject, eventdata, handles)

autoBC_ParametersGUI
% hObject    handle to autoBC_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function AFStartingWD_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AFStartingWD_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AFStartingWD_edit as text
%        str2double(get(hObject,'String')) returns contents of AFStartingWD_edit as a double

global GuiGlobalsStruct;

ValueString = get(handles.AFStartingWD_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % This is a WD in mm, so it must be between 0 and 10.0 to be valid.
    % (Other variables in this GUI are only constrained to be real numbers)
    if Value >= 0 && Value <= 10000
        % Change to meters and save
        GuiGlobalsStruct.MontageParameters.AFStartingWD = Value*0.001;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AFStartingWD_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AFStartingWD_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WDResetThreshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to WDResetThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WDResetThreshold_edit as text
%        str2double(get(hObject,'String')) returns contents of WDResetThreshold_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.WDResetThreshold_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % This is a WD in mm, so it must be between 0 and 10.0 to be valid.
    % (Other variables in this GUI are only constrained to be real numbers)
    if Value >= 0 && Value <= 100000
        % Change to meters and save
        GuiGlobalsStruct.MontageParameters.WDResetThreshold = Value*0.001;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function WDResetThreshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WDResetThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StartingStigX_edit_Callback(hObject, eventdata, handles)
% hObject    handle to StartingStigX_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartingStigX_edit as text
%        str2double(get(hObject,'String')) returns contents of StartingStigX_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.StartingStigX_edit,'String');
% ValueString = get(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_X'),'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % This is a percentage, so it must be between 0 and 100.0 to be valid.
    % (Other variables in this GUI are only constrained to be real numbers)
    if Value >= -100 && Value <= 100.0
        % Keep in percentage form
        GuiGlobalsStruct.MontageParameters.StartingStigX = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);



% --- Executes during object creation, after setting all properties.
function StartingStigX_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartingStigX_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StartingStigY_edit_Callback(hObject, eventdata, handles)
% hObject    handle to StartingStigY_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartingStigY_edit as text
%        str2double(get(hObject,'String')) returns contents of StartingStigY_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.StartingStigY_edit,'String');
% ValueString = get(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_Y'),'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % This is a percentage, so it must be between 0 and 100.0 to be valid.
    % (Other variables in this GUI are only constrained to be real numbers)
    if Value >= -100 && Value <= 100.0
        % Keep in percentage form
        GuiGlobalsStruct.MontageParameters.StartingStigY = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function StartingStigY_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartingStigY_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StigResetThreshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to StigResetThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StigResetThreshold_edit as text
%        str2double(get(hObject,'String')) returns contents of StigResetThreshold_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.StigResetThreshold_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % This is a percentage, so it must be between 0 and 100.0 to be valid.
    % (Other variables in this GUI are only constrained to be real numbers)
    if Value >= 0 && Value <= 100.0
        % Keep in percentage form
        GuiGlobalsStruct.MontageParameters.StigResetThreshold = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function StigResetThreshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StigResetThreshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AFTestImageFOV_microns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AFTestImageFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AFTestImageFOV_microns_edit as text
%        str2double(get(hObject,'String')) returns contents of AFTestImageFOV_microns_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AFTestImageFOV_microns_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) 
    % Any positive, real number works here
    if Value >= 0
        GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns = Value;
    else
        uiwait(msgbox('Illegal value. Not updating.'));
    end
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

if GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters ==1
    GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
     set(handles.AFTestImageFOV_microns_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function AFTestImageFOV_microns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AFTestImageFOV_microns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AFTestImageWidth_pixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AFTestImageWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AFTestImageWidth_pixels_edit as text
%        str2double(get(hObject,'String')) returns contents of AFTestImageWidth_pixels_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AFTestImageWidth_pixels_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1000) && (Value <= 32768)
    GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

if GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters ==1
    GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels;
    set(handles.AFTestImageWidth_pixels_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels));
end

UpdateAllFields(handles);



% --- Executes during object creation, after setting all properties.
function AFTestImageWidth_pixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AFTestImageWidth_pixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AFTestImageDwellTime_microseconds_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AFTestImageDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AFTestImageDwellTime_microseconds_edit as text
%        str2double(get(hObject,'String')) returns contents of AFTestImageDwellTime_microseconds_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AFTestImageDwellTime_microseconds_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= .01) && (Value <= 10)
    GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

if GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters ==1
    GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds;
    set(handles.AFTestImageDwellTime_microseconds_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds));
end

UpdateAllFields(handles);


% --- Executes during object creation, after setting all properties.
function AFTestImageDwellTime_microseconds_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AFTestImageDwellTime_microseconds_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SameAsTileParameters_checkbox.
function SameAsTileParameters_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SameAsTileParameters_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SameAsTileParameters_checkbox

global GuiGlobalsStruct
Value = get(handles.SameAsTileParameters_checkbox,'Value');
GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters = Value;
% If this box is checked, reset all of the values to the tile parameter
% values and refresh the window
if GuiGlobalsStruct.MontageParameters.IsAFTestSameAsTileParameters==1
    GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns = GuiGlobalsStruct.MontageParameters.TileFOV_microns;
    GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels = GuiGlobalsStruct.MontageParameters.TileWidth_pixels;
    GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds = GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds;
% %     set(handles.AFTestImageFOV_microns_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageFOV_microns));
% %     set(handles.AFTestImageWidth_pixels_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageWidth_pixels));
% %     set(handles.AFTestImageDwellTime_microseconds_edit, 'String', num2str(GuiGlobalsStruct.MontageParameters.AFTestImageDwellTime_microseconds));
end

UpdateAllFields(handles);


% --- Executes on button press in pushbutton_getCurrentValues.
function pushbutton_getCurrentValues_Callback(hObject, eventdata, handles)

global GuiGlobalsStruct

set(handles.ImageContrast_edit, 'String', GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_CONTRAST')); %chch
set(handles.ImageBrightness_edit, 'String', GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_BRIGHTNESS')); %chch
set(handles.StartingStigX_edit, 'String', GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_X'));
set(handles.StartingStigY_edit, 'String', GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_Y')); %chch
set(handles.AFStartingWD_edit, 'String', str2num(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_WD'))*1000); % converted back to mm?? %chch

GuiGlobalsStruct.MontageParameters.ImageBrightness = str2num(get(handles.ImageBrightness_edit,'String'));
GuiGlobalsStruct.MontageParameters.ImageContrast = str2num(get(handles.ImageContrast_edit,'String'));
GuiGlobalsStruct.MontageParameters.AFStartingWD = str2num(get(handles.AFStartingWD_edit ,'String'))* 0.001;
GuiGlobalsStruct.MontageParameters.StartingStigX = str2num(get(handles.StartingStigX_edit,'String'));
GuiGlobalsStruct.MontageParameters.StartingStigY = str2num(get(handles.StartingStigY_edit,'String'));

% ValueString = get(handles.ImageBrightness_edit,'String');
% Value = str2num(ValueString);
% 
% if ~isempty(Value) 
%     if Value >= 0 || Value <= 100
%         GuiGlobalsStruct.MontageParameters.ImageBrightness = Value;
%     else
%         uiwait(msgbox('Illegal value. Not updating.'));
%     end
% else
%     uiwait(msgbox('Illegal value. Not updating.'));
% end
% 
% 
% ValueString = get(handles.ImageContrast_edit,'String');
% Value = str2num(ValueString);
% 
% if ~isempty(Value) 
%     if Value >= 0 || Value <= 100
%         GuiGlobalsStruct.MontageParameters.ImageContrast = Value;
%     else
%         
%         uiwait(msgbox('Illegal value. Not updating.'));
%     end
% else
%     uiwait(msgbox('Illegal value. Not updating.'));
% end
% 
% 
% 
% ValueString = get(handles.AFStartingWD_edit,'String');
% Value = str2num(ValueString);
% 
% if ~isempty(Value) 
%     % This is a WD in mm, so it must be between 0 and 10.0 to be valid.
%     % (Other variables in this GUI are only constrained to be real numbers)
%     if Value >= 0 && Value <= 10000
%         % Change to meters and save
%         GuiGlobalsStruct.MontageParameters.AFStartingWD = Value*0.001;
%     else
%         uiwait(msgbox('Illegal value. Not updating.'));
%     end
% else
%     uiwait(msgbox('Illegal value. Not updating.'));
% end
% 
% 
% ValueString = get(handles.StartingStigX_edit,'String');
% % ValueString = get(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_X'),'String');
% Value = str2num(ValueString);
% 
% if ~isempty(Value) 
%     % This is a percentage, so it must be between 0 and 100.0 to be valid.
%     % (Other variables in this GUI are only constrained to be real numbers)
%     if Value >= -100 && Value <= 100.0
%         % Keep in percentage form
%         GuiGlobalsStruct.MontageParameters.StartingStigX = Value;
%     else
%         uiwait(msgbox('Illegal value. Not updating.'));
%     end
% else
%     uiwait(msgbox('Illegal value. Not updating.'));
% 
% end
% 
% 
% 
% ValueString = get(handles.StartingStigY_edit,'String');
% % ValueString = get(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('AP_STIG_Y'),'String');
% Value = str2num(ValueString);
% 
% if ~isempty(Value) 
%     % This is a percentage, so it must be between 0 and 100.0 to be valid.
%     % (Other variables in this GUI are only constrained to be real numbers)
%     if Value >= -100 && Value <= 100.0
%         % Keep in percentage form
%         GuiGlobalsStruct.MontageParameters.StartingStigY = Value;
%     else
%         uiwait(msgbox('Illegal value. Not updating.'));
%     end
% else
%     uiwait(msgbox('Illegal value. Not updating.'));
% end



UpdateAllFields(handles);




% hObject    handle to pushbutton_getCurrentValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in noFocus_radiobutton.
function noFocus_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to noFocus_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noFocus_radiobutton


% --- Executes on button press in pushbutton_selectTiles.
function pushbutton_selectTiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectTiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectTilesGUI
