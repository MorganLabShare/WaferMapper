function varargout = SectionOverviewProcessingParametersGUI(varargin)
% SECTIONOVERVIEWPROCESSINGPARAMETERSGUI MATLAB code for SectionOverviewProcessingParametersGUI.fig
%      SECTIONOVERVIEWPROCESSINGPARAMETERSGUI, by itself, creates a new SECTIONOVERVIEWPROCESSINGPARAMETERSGUI or raises the existing
%      singleton*.
%
%      H = SECTIONOVERVIEWPROCESSINGPARAMETERSGUI returns the handle to a new SECTIONOVERVIEWPROCESSINGPARAMETERSGUI or the handle to
%      the existing singleton*.
%
%      SECTIONOVERVIEWPROCESSINGPARAMETERSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SECTIONOVERVIEWPROCESSINGPARAMETERSGUI.M with the given input arguments.
%
%      SECTIONOVERVIEWPROCESSINGPARAMETERSGUI('Property','Value',...) creates a new SECTIONOVERVIEWPROCESSINGPARAMETERSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SectionOverviewProcessingParametersGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SectionOverviewProcessingParametersGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SectionOverviewProcessingParametersGUI

% Last Modified by GUIDE v2.5 21-Nov-2017 16:28:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SectionOverviewProcessingParametersGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SectionOverviewProcessingParametersGUI_OutputFcn, ...
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


% --- Executes just before SectionOverviewProcessingParametersGUI is made visible.
function SectionOverviewProcessingParametersGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SectionOverviewProcessingParametersGUI (see VARARGIN)

% Choose default command line output for SectionOverviewProcessingParametersGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SectionOverviewProcessingParametersGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
UpdateAllFields(handles);



function UpdateAllFields(handles)
global GuiGlobalsStruct;

set(handles.CenterAngle_edit,'String',num2str(GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle));
set(handles.AngleIncrement_edit,'String',num2str(GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement));
set(handles.NumMultiResSteps_edit,'String',num2str(GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps));

CenterAngle = GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle;
AngleIncrement = GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement;
NumMultiResSteps = GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps;
AnglesInDegreesToTryArray = [CenterAngle-2*AngleIncrement, CenterAngle-AngleIncrement,  CenterAngle,   CenterAngle+AngleIncrement ,   CenterAngle+2*AngleIncrement];


ScaleFactor = 1/(2^(NumMultiResSteps-1));
MyAccumString = '';
%Note: this mimics how the angles to try are computer in alignment function
for MultiResStepIndex = 1:NumMultiResSteps
    ScaleFactor = 1/(2^(NumMultiResSteps+-MultiResStepIndex));
    AnglesInDegreesToTryArray = [CenterAngle-2*AngleIncrement, CenterAngle-AngleIncrement,  CenterAngle,   CenterAngle+AngleIncrement ,   CenterAngle+2*AngleIncrement];
    
    MyAccumString = sprintf('%s\n%s',MyAccumString,...
        num2str(AnglesInDegreesToTryArray));
    
    %Prepare for next cycle centered on the found angle
    ScaleFactor = 2*ScaleFactor;
    AngleIncrement = AngleIncrement/2;
    CenterAngle = CenterAngle;
end

set(handles.StartingAnglesToTry_text,'String',MyAccumString);



if ~isfield(GuiGlobalsStruct.SectionOverviewProcessingParameters,'alignType')
    GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType = 'CCE';
end
setHand = sprintf('handles.%s',GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType);
set(handles.AglignType_uibuttongroup1,'selectedobject',eval(setHand))












% --- Outputs from this function are returned to the command line.
function varargout = SectionOverviewProcessingParametersGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function CenterAngle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CenterAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterAngle_edit as text
%        str2double(get(hObject,'String')) returns contents of CenterAngle_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.CenterAngle_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= -180) && (Value <= 180)
    GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function CenterAngle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterAngle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AngleIncrement_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AngleIncrement_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AngleIncrement_edit as text
%        str2double(get(hObject,'String')) returns contents of AngleIncrement_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.AngleIncrement_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 0) && (Value <= 90)
    GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function AngleIncrement_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleIncrement_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumMultiResSteps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumMultiResSteps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumMultiResSteps_edit as text
%        str2double(get(hObject,'String')) returns contents of NumMultiResSteps_edit as a double
global GuiGlobalsStruct;

ValueString = get(handles.NumMultiResSteps_edit,'String');
Value = str2num(ValueString);

if ~isempty(Value) && (Value >= 1) && (Value <= 7)
    GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps = Value;
else
    uiwait(msgbox('Illegal value. Not updating.'));
end

UpdateAllFields(handles);

% --- Executes during object creation, after setting all properties.
function NumMultiResSteps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumMultiResSteps_edit (see GCBO)
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
SetSectionOverviewProcessingParametersDefaults();
UpdateAllFields(handles);



function StartingAnglesToTry_edit_Callback(hObject, eventdata, handles)
% hObject    handle to StartingAnglesToTry_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartingAnglesToTry_edit as text
%        str2double(get(hObject,'String')) returns contents of StartingAnglesToTry_edit as a double


% --- Executes during object creation, after setting all properties.
function StartingAnglesToTry_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartingAnglesToTry_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SmallestAngleResolution_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SmallestAngleResolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmallestAngleResolution_edit as text
%        str2double(get(hObject,'String')) returns contents of SmallestAngleResolution_edit as a double


% --- Executes during object creation, after setting all properties.
function SmallestAngleResolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmallestAngleResolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function AglignType_uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AglignType_uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global GuiGlobalsStruct;





% --- Executes on button press in CC.
function CC_Callback(hObject, eventdata, handles)
global GuiGlobalsStruct;

% hObject    handle to CC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CC

GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType = 'CC';

% --- Executes on button press in CCE.
function CCE_Callback(hObject, eventdata, handles)
global GuiGlobalsStruct;

% hObject    handle to CCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CCE

GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType = 'CCE';

% --- Executes on button press in SURF.
function SURF_Callback(hObject, eventdata, handles)
global GuiGlobalsStruct;

% hObject    handle to SURF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SURF

GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType = 'SURF';


% --- Executes on button press in preProcessOverviews.
function preProcessOverviews_Callback(hObject, eventdata, handles)
% hObject    handle to preProcessOverviews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
preProcessOverviewsImages
