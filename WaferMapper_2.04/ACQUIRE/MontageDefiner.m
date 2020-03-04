function varargout = MontageDefiner(varargin)
% MONTAGEDEFINER M-file for MontageDefiner.fig
%      MONTAGEDEFINER, by itself, creates a new MONTAGEDEFINER or raises the existing
%      singleton*.
%
%      H = MONTAGEDEFINER returns the handle to a new MONTAGEDEFINER or the handle to
%      the existing singleton*.
%
%      MONTAGEDEFINER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MONTAGEDEFINER.M with the given input arguments.
%
%      MONTAGEDEFINER('Property','Value',...) creates a new MONTAGEDEFINER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MontageDefiner_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MontageDefiner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MontageDefiner

% Last Modified by GUIDE v2.5 15-Feb-2011 17:02:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MontageDefiner_OpeningFcn, ...
                   'gui_OutputFcn',  @MontageDefiner_OutputFcn, ...
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


% --- Executes just before MontageDefiner is made visible.
function MontageDefiner_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MontageDefiner (see VARARGIN)

% Choose default command line output for MontageDefiner
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MontageDefiner wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global MontageDefinerGuiGlobalsStruct;

disp('CALLED FROM MontageDefiner_OpeningFcn()');


if isfield(MontageDefinerGuiGlobalsStruct,'MasterUTSLDirectory')
    TempCopyOfPreviouseMasterUTSLDirectoryName = MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory;
else
    TempCopyOfPreviouseMasterUTSLDirectoryName = 'C:\\MasterUTSLDirectory';
end

MontageDefinerGuiGlobalsStruct = []; %Note this wipes out all memory from previous session
MontageDefinerGuiGlobalsStruct.StartPath = TempCopyOfPreviouseMasterUTSLDirectoryName;

MontageDefinerGuiGlobalsStruct.HandleToMontageDefinerFigure = hObject

MyStr = sprintf('MontageDefiner - ');
set(MontageDefinerGuiGlobalsStruct.HandleToMontageDefinerFigure,'name',MyStr);

MontageDefinerGuiGlobalsStruct.IsLegalMasterUTSLDir = false;
set(handles.OpenUTSL_MenuItem,'Enable','off');

% --- Outputs from this function are returned to the command line.
function varargout = MontageDefiner_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to File_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMasterDirForUTSLs_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMasterDirForUTSLs_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global MontageDefinerGuiGlobalsStruct;

[dirname] = uigetdir(MontageDefinerGuiGlobalsStruct.StartPath, 'Pick the master directory where you keep UTSLs...');
if dirname == 0
    disp('User Cancled');
else
    %Make sure the following file 'UTSLDefaults.mat' exists in this
    %directory. This is mainly to prevent users from putting a wafer in a
    %non UTSL directory.
    UTSLDefaultsFileNameStr = sprintf('%s\\%s',dirname,'UTSLDefaults.mat');
    if exist(UTSLDefaultsFileNameStr,'file')
        %ok
    else
        MyStr = sprintf('Could not find: %s.',UTSLDefaultsFileNameStr);
        return;
    end

    MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory = dirname;
    MontageDefinerGuiGlobalsStruct.IsLegalMasterUTSLDir = true;
    MyStr = sprintf('MontageDefiner - %s', MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory);
    set(MontageDefinerGuiGlobalsStruct.HandleToMontageDefinerFigure,'name',MyStr);
    set(handles.OpenUTSL_MenuItem,'Enable','on');
    
    
end

% --------------------------------------------------------------------
function OpenUTSL_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenUTSL_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global MontageDefinerGuiGlobalsStruct;

if ~exist(MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory, 'dir')
    MyStr = sprintf('Could not find master directory: %s.',MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory);
    uiwait(msgbox(MyStr));
    return;
else
    DirListArray = dir(MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory);
    n = 1;
    ListOfDirNames = [];
    for i=1:length(DirListArray)
        if (DirListArray(i).isdir == 1) && (DirListArray(i).name(1) ~= '.')
            ListOfDirNames{n} = DirListArray(i).name;
            n = n + 1;
        end
    end
    
    
    if length(ListOfDirNames) > 0
        [SelectionNumber,isok] = listdlg('PromptString','Select a UTSL dir:',...
            'SelectionMode','single',...
            'ListString',ListOfDirNames);
        
        if isok == 1
            MontageDefinerGuiGlobalsStruct.UTSLDirectory = sprintf('%s\\%s',MontageDefinerGuiGlobalsStruct.MasterUTSLDirectory,ListOfDirNames{SelectionNumber});
            MyStr = sprintf('MontageDefiner - %s', MontageDefinerGuiGlobalsStruct.UTSLDirectory);
            set(MontageDefinerGuiGlobalsStruct.HandleToMontageDefinerFigure,'name',MyStr);

            %Enable menu items for next step
            set(handles.OpenUTSL_MenuItem,'Enable','on');
        end
    else
        uiwait(msgbox('No UTSLs found.'));
        return;
    end
    
end

%Now pupulate the WaferList_PopupMenu with all the wafers in this UTSL
%WaferList_PopupMenu

DirListArray = dir(MontageDefinerGuiGlobalsStruct.UTSLDirectory);

n = 1;
ListOfDirNames = [];
for i=1:length(DirListArray)
    if (DirListArray(i).isdir == 1) && (DirListArray(i).name(1) ~= '.')
        ListOfDirNames{n} = DirListArray(i).name;
        n = n + 1;
    end
end
MontageDefinerGuiGlobalsStruct.ListOfWaferNames = ListOfDirNames;


set(handles.WaferList_PopupMenu,'String', MontageDefinerGuiGlobalsStruct.ListOfWaferNames);

% --- Executes on selection change in WaferList_PopupMenu.
function WaferList_PopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to WaferList_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WaferList_PopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WaferList_PopupMenu


% --- Executes during object creation, after setting all properties.
function WaferList_PopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaferList_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
