function varargout = LogFileDisplayer(varargin)
% LOGFILEDISPLAYER M-file for LogFileDisplayer.fig
%      LOGFILEDISPLAYER, by itself, creates a new LOGFILEDISPLAYER or raises the existing
%      singleton*.
%
%      H = LOGFILEDISPLAYER returns the handle to a new LOGFILEDISPLAYER or the handle to
%      the existing singleton*.
%
%      LOGFILEDISPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOGFILEDISPLAYER.M with the given input arguments.
%
%      LOGFILEDISPLAYER('Property','Value',...) creates a new LOGFILEDISPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LogFileDisplayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LogFileDisplayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LogFileDisplayer

% Last Modified by GUIDE v2.5 02-Mar-2012 16:54:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LogFileDisplayer_OpeningFcn, ...
                   'gui_OutputFcn',  @LogFileDisplayer_OutputFcn, ...
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


% --- Executes just before LogFileDisplayer is made visible.
function LogFileDisplayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LogFileDisplayer (see VARARGIN)

% Choose default command line output for LogFileDisplayer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LogFileDisplayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LogFileDisplayer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function MainDisplay_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainDisplay_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in RefreshOnce_Button.
function RefreshOnce_Button_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshOnce_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
