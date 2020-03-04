function varargout = QuickCheck(varargin)
% QUICKCHECK MATLAB code for QuickCheck.fig
%      QUICKCHECK, by itself, creates a new QUICKCHECK or raises the existing
%      singleton*.
%
%      H = QUICKCHECK returns the handle to a new QUICKCHECK or the handle to
%      the existing singleton*.
%
%      QUICKCHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUICKCHECK.M with the given input arguments.
%
%      QUICKCHECK('Property','Value',...) creates a new QUICKCHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QuickCheck_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QuickCheck_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QuickCheck

% Last Modified by GUIDE v2.5 21-Jun-2011 22:07:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QuickCheck_OpeningFcn, ...
                   'gui_OutputFcn',  @QuickCheck_OutputFcn, ...
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


% --- Executes just before QuickCheck is made visible.
function QuickCheck_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QuickCheck (see VARARGIN)

% Choose default command line output for QuickCheck
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes QuickCheck wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global QuickCheckGlobals;

QuickCheckGlobals.SectionNum = 1;

% --- Outputs from this function are returned to the command line.
function varargout = QuickCheck_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Next_button.
function Next_button_Callback(hObject, eventdata, handles)
% hObject    handle to Next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function SectionNum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionNum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionNum_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionNum_edit as a double


% --- Executes during object creation, after setting all properties.
function SectionNum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionNum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Prev_button.
function Prev_button_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
