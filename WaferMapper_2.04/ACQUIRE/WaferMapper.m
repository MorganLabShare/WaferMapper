function varargout = WaferMapper(varargin)
% WAFERMAPPER MATLAB code for WaferMapper.fig
%      WAFERMAPPER, by itself, creates a new WAFERMAPPER or raises the existing
%      singleton*.
%
%      H = WAFERMAPPER returns the handle to a new WAFERMAPPER or the handle to
%      the existing singleton*.
%
%      WAFERMAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAFERMAPPER.M with the given input arguments.
%
%      WAFERMAPPER('Property','Value',...) creates a new WAFERMAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WaferMapper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WaferMapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WaferMapper

% Last Modified by GUIDE v2.5 18-May-2017 16:17:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WaferMapper_OpeningFcn, ...
                   'gui_OutputFcn',  @WaferMapper_OutputFcn, ...
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


%% --- Executes just before WaferMapper is made visible.
function WaferMapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WaferMapper (see VARARGIN)

% Choose default command line output for WaferMapper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%START OF CUSTOM CODE
clear global; %This is to make sure that any previous runs are wiped out

global GuiGlobalsStruct; %This is the main global that keeps track of everything

currentDirectory = pwd;
subFuncDir = [currentDirectory '\SubFunctions\'];
addpath(genpath(subFuncDir));

%Make sure there is not another instance of WaferMapper running
MyHandleList = findobj('-regexp', 'name', 'WaferMapper - *')
if ~isempty(MyHandleList)
    figure(MyHandleList(1));
    uiwait(msgbox('WaferMapper already running. Close first.'));
    return;
end

MasterDisableAndUncheckGuiItems(handles);

%KH removed 7-12-2011 InitGUI(handles);

GuiGlobalsStruct.handles_FromWaferMapper = handles;

%NOTE: The following renaming with a ' - ' after the WaferMapper is to allow findobj
%above to recognize if it is looking at an already opened gui.
GuiGlobalsStruct.HandleToWaferMapperFigure = hObject;
MyStr = sprintf('WaferMapper - ');
set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);

%Frist thing is to ask user whether to do a Zeiss + Fibics initialization.
%If not then later functions will not work but may be useful to not init
%for debugging on a non SEM connected computer
GuiGlobalsStruct.IsZeissAPIInitialized = false;
GuiGlobalsStruct.IsFibicsAPIInitialized = false;
GuiGlobalsStruct.h_StatusBar_EditBox = handles.StatusBar_EditBox;

ButtonName = questdlg('About to init Zeiss and FIBICS APIs. Press cancel to skip.','title','OK','Cancel','OK');
if strcmp(ButtonName,'OK')
    
    h_msgbox = msgbox('Initializing Zeiss API Interface...','modal');
    
    IsOK = false;
    memory
    %% protect chunk of contiguous memory from actxserver
    mem = memory
    resMem = 1000000000;%mem.MaxPossibleArrayBytes* .55;
    spacer = zeros(round(resMem),1,'uint8');
    
    memory
    try
        
        MyCZEMAPIClass = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass');
        IsOK = true;
    catch MyException
        if ishandle(h_msgbox)
            close(h_msgbox);
        end
        uiwait(msgbox('Problem initializing Zeiss API. Some program functionality will be unavailable.'));
        set(handles.InitializeZeissSEMControl_MenuItem,'Checked','off');     
    end
    'actxserver'
    memory
    GuiGlobalsStruct.MyCZEMAPIClass = MyCZEMAPIClass;
    'MyCZ'
    memory
    
    if IsOK
        'IsOK'
        pause(15)
        memory
        MyReturnInt = MyCZEMAPIClass.InitialiseRemoting;
        'MyReturnInt'
        memory
        if (MyReturnInt == 0)
            MyMag = GuiGlobalsStruct.MyCZEMAPIClass.GetMag;
            'mymag'
            memory
            MyStr = sprintf('Zeiss API successfully initialized. GetMag() = %0.5g',MyMag);
            'mystr'
            memory
            StatusBarMessage(MyStr);
            
            GuiGlobalsStruct.IsZeissAPIInitialized = true;
            set(handles.InitializeZeissSEMControl_MenuItem,'Checked','on');
            if ishandle(h_msgbox)
               close(h_msgbox);
            end
            'status bar'
            memory
            %Make sure we have scan rotation = 0;
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);
        else
            if ishandle(h_msgbox)
                close(h_msgbox);
            end
            uiwait(msgbox('Problem initializing Zeiss API.'));
            StatusBarMessage('Problem initializing Zeiss API.');
            set(handles.InitializeZeissSEMControl_MenuItem,'Checked','off');
        end
    end
    
    
    
    if GuiGlobalsStruct.IsZeissAPIInitialized
        %uiwait(msgbox('About to initialize FIBICS API. MAKE SURE ATLAS SOFTWARE IS CLOSED. Press OK when ready...'));
        h_msgbox = msgbox('Programatically setting Zeiss SEM to 300x before init of FIBICS. This is necessary to maintain consistency of FOV calcs. between FIBICS sessions','modal');
        PreviousWD = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        PreviousMag =  GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MAG');
        StartWD = .009; %9mm
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',StartWD);
        pause(1);
        StartMag = 300; %25;
        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',StartMag);
        pause(1);
        if ishandle(h_msgbox)
            close(h_msgbox);
        end
        
        if GuiGlobalsStruct.MyCZEMAPIClass.GetMag() == StartMag
            GuiGlobalsStruct.MyCZEMAPIClass.Fibics_Initialise();
            
            for i=1:15
                MyStr = sprintf(' Fibics Initializing, pausing 15 seconds... %d', i);
                h_msgbox = msgbox(MyStr);
                pause(1);
                close(h_msgbox);
            end
            
            
            MyStr = sprintf('Fibics API successfully initialized.');
            StatusBarMessage(MyStr);
            GuiGlobalsStruct.IsFibicsAPIInitialized = true;
            set(handles.InitializeFibicsControl_MenuItem,'Checked','on');
            %bring the WaferMapper figure to the front again
            figure(GuiGlobalsStruct.HandleToWaferMapperFigure);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',PreviousWD);
            pause(1);
            GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',PreviousMag);
            pause(1);
        else
            uiwait(msgbox('Problem setting Zeiss SEM mag.'));
            GuiGlobalsStruct.IsFibicsAPIInitialized = false;
            set(handles.InitializeFibicsControl_MenuItem,'Checked','off');
            
        end
    end
        clear spacer %to recover reserved memory

end

StatusBarMessage('Completed opening.');
%NOTE: These are the fields in the global struct at the end of the opening
%function:
%
% %GuiGlobalsStruct = 
% 
%       handles_FromWaferMapper: [1x1 struct]
%     HandleToWaferMapperFigure: 173.0210
%         IsZeissAPIInitialized: 1
%        IsFibicsAPIInitialized: 1
%           h_StatusBar_EditBox: 191.0210
%                MyCZEMAPIClass: [1x1 COM.VBComObjectWrapperForZeissAPI_KHZeissSEMWrapperComClass]



function InitParameters(handles)
global GuiGlobalsStruct;

%Setup up default globals
GuiGlobalsStruct.IsDisplayCoarseSectionList = false;
GuiGlobalsStruct.CoarseSectionList = [];

SetWaferParametersDefaults();
SetSectionOverviewProcessingParametersDefaults();
SetMontageParametersDefaults();

GuiGlobalsStruct.backlashState = 'Off';
GuiGlobalsStruct.IsDisplayMontageTarget = false;
GuiGlobalsStruct.MontageTarget.r = 100;
GuiGlobalsStruct.MontageTarget.c = 100;
GuiGlobalsStruct.MontageTarget.MontageNorthAngle = 0; %degrees
GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons = 400;
GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons = 400;
GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons = 65.536;%40.96;
GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons = 65.536;%40.96;
GuiGlobalsStruct.MontageTarget.MicronsPerPixel = 0.01;
GuiGlobalsStruct.MontageTarget.NumberOfTileRows = 3;
GuiGlobalsStruct.MontageTarget.NumberOfTileCols = 3;
GuiGlobalsStruct.MontageTarget.PercentTileOverlap = 6;
GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns = 0;
GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns = 0;
GuiGlobalsStruct.MontageTarget.XOffsetFromAlignTargetMicrons = 0;
GuiGlobalsStruct.MontageTarget.YOffsetFromAlignTargetMicrons = 0;

GuiGlobalsStruct.IsUseStageCorrection = false;

GuiGlobalsStruct.IsDisplayCurrentStagePosition = true;

set(handles.SectionLabel_EditBox,'String','1');

MyStr = sprintf('Loaded Stage Transform: none');
set(handles.StageCorrectionStatus_EditBox, 'String', MyStr);






% --- Outputs from this function are returned to the command line.
function varargout = WaferMapper_OutputFcn(hObject, eventdata, handles) 
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
global GuiGlobalsStruct;

[dirname] = uigetdir('', 'Pick the master directory where you keep UTSLs...');
if dirname == 0
    disp('User Canceled');
    return;
else
    %%% START: Clear all variables except those that should have been filled before
    Temp_handles_FromWaferMapper = GuiGlobalsStruct.handles_FromWaferMapper;
    Temp_HandleToWaferMapperFigure = GuiGlobalsStruct.HandleToWaferMapperFigure;
    Temp_IsZeissAPIInitialized = GuiGlobalsStruct.IsZeissAPIInitialized;
    Temp_IsFibicsAPIInitialized = GuiGlobalsStruct.IsFibicsAPIInitialized;
    Temp_h_StatusBar_EditBox = GuiGlobalsStruct.h_StatusBar_EditBox;
    if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass') %This is to handle case if we are running without microscope
        Temp_MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
        IsField_MyCZEMAPIClass = true;
    else
        IsField_MyCZEMAPIClass = false;
    end
    clear global GuiGlobalsStruct;
    global GuiGlobalsStruct;
    GuiGlobalsStruct.handles_FromWaferMapper = Temp_handles_FromWaferMapper;
    GuiGlobalsStruct.HandleToWaferMapperFigure = Temp_HandleToWaferMapperFigure;
    GuiGlobalsStruct.IsZeissAPIInitialized = Temp_IsZeissAPIInitialized;
    GuiGlobalsStruct.IsFibicsAPIInitialized = Temp_IsFibicsAPIInitialized;
    GuiGlobalsStruct.h_StatusBar_EditBox = Temp_h_StatusBar_EditBox;
    if IsField_MyCZEMAPIClass %This is to handle case if we are running without microscope
        GuiGlobalsStruct.MyCZEMAPIClass = Temp_MyCZEMAPIClass;
    end
    %%% END: Clear all variables except those that should have been filled before
    
    
    %Make sure the following file 'UTSLDefaults.mat' exists in this
    %directory. This is mainly to prevent users from putting a wafer in a
    %non UTSL directory.
    UTSLDefaultsFileNameStr = sprintf('%s\\%s',dirname,'UTSLDefaults.mat');
    if exist(UTSLDefaultsFileNameStr,'file')
        %ok
    else
        MyStr = sprintf('Could not find: %s. If this is really a directory where you will be creating new UTSLs then press ''Create UTSLDefaults.mat'', else ''Cancel''.',UTSLDefaultsFileNameStr);
        AnswerStr = questdlg(MyStr,'Question', 'Create UTSLDefaults.mat', 'Cancel', 'Cancel');
        if strcmp(AnswerStr,'Cancel')
            return;
        else
            DummyVariable = 0;
            save(UTSLDefaultsFileNameStr, 'DummyVariable');
        end
    end
    
    %If we got here then we have a new or existing Master directory
    
    
    
    GuiGlobalsStruct.MasterUTSLDirectory = dirname;
    GuiGlobalsStruct.IsLegalMasterUTSLDir = true;
    MyStr = sprintf('WaferMapper - %s', GuiGlobalsStruct.MasterUTSLDirectory);
    set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);
    MasterDisableAndUncheckGuiItems(handles);
    set(handles.NewUTSL_MenuItem,'Enable','on');
    set(handles.OpenUTSL_MenuItem,'Enable','on');
    
    StatusBarMessage(MyStr);
    
    %NOTE: These are the fields in the global struct at the end of the function:
    % GuiGlobalsStruct =
    %
    %       handles_FromWaferMapper: [1x1 struct]
    %     HandleToWaferMapperFigure: 265.0266
    %         IsZeissAPIInitialized: 1
    %        IsFibicsAPIInitialized: 1
    %           h_StatusBar_EditBox: 283.0266
    %                MyCZEMAPIClass: [1x1 COM.VBComObjectWrapperForZeissAPI_KHZeissSEMWrapperComClass]
    %           MasterUTSLDirectory: 'Z:\Hayworth\MasterUTSLDirectory'
    %          IsLegalMasterUTSLDir: 1
    
end




function EditBox_DirectoryName_Callback(hObject, eventdata, handles)
% hObject    handle to EditBox_DirectoryName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditBox_DirectoryName as text
%        str2double(get(hObject,'String')) returns contents of EditBox_DirectoryName as a double


% --- Executes during object creation, after setting all properties.
function EditBox_DirectoryName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditBox_DirectoryName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --------------------------------------------------------------------
function NewUTSL_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NewUTSL_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

InputDlgAnswer = inputdlg('Enter name for new UTSL (will create subdirectory)');

if isempty(InputDlgAnswer)
    disp('User Canceled');
    return;
else
    %%% START: Clear all variables except those that should have been filled before
    Temp_handles_FromWaferMapper = GuiGlobalsStruct.handles_FromWaferMapper;
    Temp_HandleToWaferMapperFigure = GuiGlobalsStruct.HandleToWaferMapperFigure;
    Temp_IsZeissAPIInitialized = GuiGlobalsStruct.IsZeissAPIInitialized;
    Temp_IsFibicsAPIInitialized = GuiGlobalsStruct.IsFibicsAPIInitialized;
    Temp_h_StatusBar_EditBox = GuiGlobalsStruct.h_StatusBar_EditBox; 
    if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass') %This is to handle case if we are running without microscope
        Temp_MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
        IsField_MyCZEMAPIClass = true;
    else
        IsField_MyCZEMAPIClass = false;
    end
    Temp_MasterUTSLDirectory = GuiGlobalsStruct.MasterUTSLDirectory;
    Temp_IsLegalMasterUTSLDir = GuiGlobalsStruct.IsLegalMasterUTSLDir;
    clear global GuiGlobalsStruct;
    global GuiGlobalsStruct;
    GuiGlobalsStruct.handles_FromWaferMapper = Temp_handles_FromWaferMapper;
    GuiGlobalsStruct.HandleToWaferMapperFigure = Temp_HandleToWaferMapperFigure;
    GuiGlobalsStruct.IsZeissAPIInitialized = Temp_IsZeissAPIInitialized;
    GuiGlobalsStruct.IsFibicsAPIInitialized = Temp_IsFibicsAPIInitialized;
    GuiGlobalsStruct.h_StatusBar_EditBox = Temp_h_StatusBar_EditBox;
    if IsField_MyCZEMAPIClass %This is to handle case if we are running without microscope
        GuiGlobalsStruct.MyCZEMAPIClass = Temp_MyCZEMAPIClass;
    end
    GuiGlobalsStruct.MasterUTSLDirectory = Temp_MasterUTSLDirectory;
    GuiGlobalsStruct.IsLegalMasterUTSLDir = Temp_IsLegalMasterUTSLDir;
    %%% END: Clear all variables except those that should have been filled before
    GuiGlobalsStruct.ListOfWaferNames = [];
    
    NewNameStr = InputDlgAnswer{1};
    NewDirPath = sprintf('%s\\%s',GuiGlobalsStruct.MasterUTSLDirectory,NewNameStr);
    
    if ~exist(NewDirPath,'dir')
        [success,message,messageid] = mkdir(NewDirPath);
        if success == 1
            GuiGlobalsStruct.UTSLDirectory = NewDirPath;
            MyStr = sprintf('WaferMapper - %s', GuiGlobalsStruct.UTSLDirectory);
            set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);
            
            StatusBarMessage(MyStr);
            %Enable menu items for next step
            MasterDisableAndUncheckGuiItems(handles);
            set(handles.NewUTSL_MenuItem,'Enable','on');
            set(handles.OpenUTSL_MenuItem,'Enable','on');
            set(handles.NewWafer_MenuItem,'Enable','on');
            set(handles.OpenWafer_MenuItem,'Enable','on');
        else
            uiwait(msgbox(message));
            MasterDisableAndUncheckGuiItems(handles)
        end
        
    else
        MyStr = sprintf('Directory (%s) already exists. Use choose instead.',NewDirPath);
        uiwait(msgbox(MyStr));
        MasterDisableAndUncheckGuiItems(handles);
        return;
    end
    
    %NOTE: These are the fields in the global struct at the end of the function:
    %     GuiGlobalsStruct =
    %
    %       handles_FromWaferMapper: [1x1 struct]
    %     HandleToWaferMapperFigure: 265.0267
    %         IsZeissAPIInitialized: 1
    %        IsFibicsAPIInitialized: 1
    %           h_StatusBar_EditBox: 283.0267
    %                MyCZEMAPIClass: [1x1 COM.VBComObjectWrapperForZeissAPI_KHZeissSEMWrapperComClass]
    %           MasterUTSLDirectory: 'Z:\Hayworth\MasterUTSLDirectory'
    %          IsLegalMasterUTSLDir: 1
    %                 UTSLDirectory: 'Z:\Hayworth\MasterUTSLDirectory\TestUTSL_9283'
    
end


% --------------------------------------------------------------------
function OpenUTSL_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenUTSL_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%%% START: Clear all variables except those that should have been filled before
Temp_handles_FromWaferMapper = GuiGlobalsStruct.handles_FromWaferMapper;
Temp_HandleToWaferMapperFigure = GuiGlobalsStruct.HandleToWaferMapperFigure;
Temp_IsZeissAPIInitialized = GuiGlobalsStruct.IsZeissAPIInitialized;
Temp_IsFibicsAPIInitialized = GuiGlobalsStruct.IsFibicsAPIInitialized;
Temp_h_StatusBar_EditBox = GuiGlobalsStruct.h_StatusBar_EditBox;
if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass') %This is to handle case if we are running without microscope
    Temp_MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
    IsField_MyCZEMAPIClass = true;
else
    IsField_MyCZEMAPIClass = false;
end
Temp_MasterUTSLDirectory = GuiGlobalsStruct.MasterUTSLDirectory;
Temp_IsLegalMasterUTSLDir = GuiGlobalsStruct.IsLegalMasterUTSLDir;
clear global GuiGlobalsStruct;
global GuiGlobalsStruct;
GuiGlobalsStruct.handles_FromWaferMapper = Temp_handles_FromWaferMapper;
GuiGlobalsStruct.HandleToWaferMapperFigure = Temp_HandleToWaferMapperFigure;
GuiGlobalsStruct.IsZeissAPIInitialized = Temp_IsZeissAPIInitialized;
GuiGlobalsStruct.IsFibicsAPIInitialized = Temp_IsFibicsAPIInitialized;
GuiGlobalsStruct.h_StatusBar_EditBox = Temp_h_StatusBar_EditBox;
if IsField_MyCZEMAPIClass %This is to handle case if we are running without microscope
    GuiGlobalsStruct.MyCZEMAPIClass = Temp_MyCZEMAPIClass;
end
GuiGlobalsStruct.MasterUTSLDirectory = Temp_MasterUTSLDirectory;
GuiGlobalsStruct.IsLegalMasterUTSLDir = Temp_IsLegalMasterUTSLDir;
%%% END: Clear all variables except those that should have been filled before

%% Get list of wafer names
if ~exist(GuiGlobalsStruct.MasterUTSLDirectory, 'dir')
    MyStr = sprintf('Could not find master directory: %s.',GuiGlobalsStruct.MasterUTSLDirectory);
    uiwait(msgbox(MyStr));
    MasterDisableAndUncheckGuiItems(handles);
    return;
else
    DirListArray = dir(GuiGlobalsStruct.MasterUTSLDirectory);
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
            GuiGlobalsStruct.UTSLDirectory = sprintf('%s\\%s',GuiGlobalsStruct.MasterUTSLDirectory,ListOfDirNames{SelectionNumber});
            MyStr = sprintf('WaferMapper - %s', GuiGlobalsStruct.UTSLDirectory);
            set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);
            
            StatusBarMessage(MyStr);
            %Enable menu items for next step
            MasterDisableAndUncheckGuiItems(handles);
            set(handles.NewUTSL_MenuItem,'Enable','on');
            set(handles.OpenUTSL_MenuItem,'Enable','on');
            set(handles.NewWafer_MenuItem,'Enable','on');
            set(handles.OpenWafer_MenuItem,'Enable','on');
            
            %Populate the popup menu for wafers in the section overview display
            WaferDirListArray = dir(GuiGlobalsStruct.UTSLDirectory);
            WaferDirListArray = WaferDirListArray(3:end);
            
            
            ListOfWaferNames = [];
            for i=1:length(WaferDirListArray)
                if (WaferDirListArray(i).isdir == 1) 
                    nam = lower(WaferDirListArray(i).name);
                    if strcmp(nam(1),'w')
                        ListOfWaferNames{length(ListOfWaferNames)+1} = WaferDirListArray(i).name;
                    end
                end
            end
            GuiGlobalsStruct.ListOfWaferNames = ListOfWaferNames;
            set(handles.WaferForSectionOverviewDisplay_PopupMenu,'String', GuiGlobalsStruct.ListOfWaferNames);
            
        end
    else
        uiwait(msgbox('No UTSLs found.'));
        set(handles.NewUTSL_MenuItem,'Enable','off');
        set(handles.OpenUTSL_MenuItem,'Enable','off');
        set(handles.NewWafer_MenuItem,'Enable','off');
        set(handles.OpenWafer_MenuItem,'Enable','off');
        return;
    end
    
end






% --------------------------------------------------------------------
function OpenWafer_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenWafer_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;


%%% START: Clear all variables except those that should have been filled before
Temp_handles_FromWaferMapper = GuiGlobalsStruct.handles_FromWaferMapper;
Temp_HandleToWaferMapperFigure = GuiGlobalsStruct.HandleToWaferMapperFigure;
Temp_IsZeissAPIInitialized = GuiGlobalsStruct.IsZeissAPIInitialized;
Temp_IsFibicsAPIInitialized = GuiGlobalsStruct.IsFibicsAPIInitialized;
Temp_h_StatusBar_EditBox = GuiGlobalsStruct.h_StatusBar_EditBox;
if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass') %This is to handle case if we are running without microscope
    Temp_MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
    IsField_MyCZEMAPIClass = true;
else
    IsField_MyCZEMAPIClass = false;
end
Temp_MasterUTSLDirectory = GuiGlobalsStruct.MasterUTSLDirectory;
Temp_IsLegalMasterUTSLDir = GuiGlobalsStruct.IsLegalMasterUTSLDir;
Temp_UTSLDirectory = GuiGlobalsStruct.UTSLDirectory;
Temp_ListOfWaferNames = GuiGlobalsStruct.ListOfWaferNames;
clear global GuiGlobalsStruct;
global GuiGlobalsStruct;
GuiGlobalsStruct.handles_FromWaferMapper = Temp_handles_FromWaferMapper;
GuiGlobalsStruct.HandleToWaferMapperFigure = Temp_HandleToWaferMapperFigure;
GuiGlobalsStruct.IsZeissAPIInitialized = Temp_IsZeissAPIInitialized;
GuiGlobalsStruct.IsFibicsAPIInitialized = Temp_IsFibicsAPIInitialized;
GuiGlobalsStruct.h_StatusBar_EditBox = Temp_h_StatusBar_EditBox;
if IsField_MyCZEMAPIClass %This is to handle case if we are running without microscope
    GuiGlobalsStruct.MyCZEMAPIClass = Temp_MyCZEMAPIClass;
end
GuiGlobalsStruct.MasterUTSLDirectory = Temp_MasterUTSLDirectory;
GuiGlobalsStruct.IsLegalMasterUTSLDir = Temp_IsLegalMasterUTSLDir;
GuiGlobalsStruct.UTSLDirectory = Temp_UTSLDirectory;
GuiGlobalsStruct.ListOfWaferNames = Temp_ListOfWaferNames;
%%% END: Clear all variables except those that should have been filled before


MasterDisableAndUncheckGuiItems(handles);



if ~exist(GuiGlobalsStruct.UTSLDirectory, 'dir')
    MyStr = sprintf('Could not find UTSL directory: %s.',UGuiGlobalsStruct.UTSLDirectory);
    uiwait(msgbox(MyStr));
    set(handles.NewUTSL_MenuItem,'Enable','on');
    set(handles.OpenUTSL_MenuItem,'Enable','on');
    return;
else
    set(handles.NewUTSL_MenuItem,'Enable','on');
    set(handles.OpenUTSL_MenuItem,'Enable','on');
    set(handles.NewWafer_MenuItem,'Enable','on');
    set(handles.OpenWafer_MenuItem,'Enable','on');
    
    InitParameters(handles);

    ListOfDirNames =  GuiGlobalsStruct.ListOfWaferNames ;
    
    if length(ListOfDirNames) > 0
        [SelectionNumber,isok] = listdlg('PromptString','Select a wafer dir:',...
            'SelectionMode','single',...
            'ListString',ListOfDirNames);
        
        if isok == 1
            GuiGlobalsStruct.WaferDirectory = sprintf('%s\\%s',GuiGlobalsStruct.UTSLDirectory,ListOfDirNames{SelectionNumber});
            MyStr = sprintf('WaferMapper - %s', GuiGlobalsStruct.WaferDirectory);
            set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);
            StatusBarMessage(MyStr);
            %Enable menu items for next step
            set(handles.AcquireFullWaferMontage_MenuItem,'Enable','on');
            GuiGlobalsStruct.WaferName = ListOfDirNames{SelectionNumber};
            GuiGlobalsStruct.WaferNameIndex = find(strcmp(GuiGlobalsStruct.ListOfWaferNames,GuiGlobalsStruct.WaferName))
            %Set this to be the wafer in the aligned section overview
            %display
            WaferListCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
            for ii = 1:length(WaferListCellArray)
                if strcmp(ListOfDirNames{SelectionNumber}, WaferListCellArray{ii})
                   set(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value',ii); 
                end
            end
            
            
            
            
        else
            return;
        end
    else
        uiwait(msgbox('No Wafers found.'));
        return;
    end
    
    
    %Define the global variable names of all relevant directories at this
    %point (note some of these directories will be created when needed)
    
    %Directories completed after wafer is fully mapped:
    GuiGlobalsStruct.OpticalWaferImageDirectory = sprintf('%s\\OpticalWaferImageDirectory', GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.FullWaferTileImagesDirectory = sprintf('%s\\FullWaferTileImages', GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.LowResFiducialsDirectory = sprintf('%s\\LowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.HighResFiducialsDirectory = sprintf('%s\\HighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.ExampleSectionImageDirectory = sprintf('%s\\ExampleSectionImageDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.PixelToStageCalibrationDirectory = sprintf('%s\\PixelToStageCalibrationDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.SectionOverviewsDirectory = sprintf('%s\\SectionOverviewsDirectory',GuiGlobalsStruct.WaferDirectory);
    
    
    %Directories completed after (possibly offline) processing to align overview sections is compelted:
    GuiGlobalsStruct.SectionOverviewTemplateDirectory = sprintf('%s\\SectionOverviewTemplateDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory',GuiGlobalsStruct.WaferDirectory);
    
    %Directories completed during a wafer reload
    GuiGlobalsStruct.ReimageLowResFiducialsDirectory = sprintf('%s\\ReimageLowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.ReimageHighResFiducialsDirectory = sprintf('%s\\ReimageHighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory = sprintf('%s\\ReimageWithCorrectionLowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory = sprintf('%s\\ReimageWithCorrectionHighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    
    %Temp images directory
    GuiGlobalsStruct.TempImagesDirectory = sprintf('%s\\TempImagesDirectory',GuiGlobalsStruct.WaferDirectory);
    
    %AlignedTargetListsDirectory is specifically for keeping track of
    %multi-wafer alligned target points (same tissue position across
    %multiple sections and wafers)
    GuiGlobalsStruct.AlignedTargetListsDirectory = sprintf('%s\\AlignedTargetListsDirectory',GuiGlobalsStruct.UTSLDirectory);
    
    GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory = sprintf('%s\\ManuallyCorrectedStagePositionsDirectory',GuiGlobalsStruct.WaferDirectory);
    
    %Check this wafer directory to see how much processing has already
    %occured
    
    %*** I now go through each of the directories for the wafer mapping to
    %determine if each step of the wafer mapping has been completed) If it
    %has then I unlock the menu item for the next step
    
    %Check if 'Acquire Full Wafer Montage' step is done
    if exist(GuiGlobalsStruct.FullWaferTileImagesDirectory,'dir')
        FullMapDataFileNameStr = sprintf('%s\\FullMapData.mat',GuiGlobalsStruct.FullWaferTileImagesDirectory);
        if exist(FullMapDataFileNameStr,'file')
            set(handles.MapWaferOperations_MenuItem,'Enable','on');
            set(handles.AcquireFullWaferMontage_MenuItem,'Checked','on');
            set(handles.FreeView_MenuItem,'Enable','on');
            set(handles.AcquireLowResFiducials_MenuItem,'Enable','on'); %Next step
            
            disp(sprintf('Loading FullMapData.mat file: %s',FullMapDataFileNameStr));
            load(FullMapDataFileNameStr,'FullMapData');
            GuiGlobalsStruct.FullMapData = FullMapData;
            
            FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
            disp(sprintf('Loading image file: %s',FullWaferImageFileNameStr));
            GuiGlobalsStruct.FullWaferDownsampledDisplayImage = imread(FullWaferImageFileNameStr,'tif');
        else
            set(handles.AcquireFullWaferMontage_MenuItem,'Checked','off');
            GuiGlobalsStruct.FullMapData = [];
            GuiGlobalsStruct.FullWaferDownsampledDisplayImage = [];
        end
    else
        set(handles.AcquireFullWaferMontage_MenuItem,'Checked','off');
        GuiGlobalsStruct.FullMapData = [];
        GuiGlobalsStruct.FullWaferDownsampledDisplayImage = [];
    end
    
    %Check if 'Acquire Low Res. Fiducials' step is done
    if exist(GuiGlobalsStruct.LowResFiducialsDirectory,'dir')
        set(handles.AcquireLowResFiducials_MenuItem,'Checked','on');
        set(handles.AcquireHighResFiducials_MenuItem,'Enable','on');%Next step
    end
    
    %Check if 'Acquire High Res. Fiducials' step is done
    if exist(GuiGlobalsStruct.HighResFiducialsDirectory,'dir')
        set(handles.AcquireHighResFiducials_MenuItem,'Checked','on');
        set(handles.AcquireExampleSectionImage_MenuItem,'Enable','on');%Next step
        
        %Note: this is minimal info needed for reload
        set(handles.ReloadWaferOperations_MenuItem,'Enable','on');
        %The following are in the ReloadWaferOperations menu
        set(handles.DoAllStepsForStageCorrection_MenuItem,'Enable','on');
        set(handles.ReloadStageCorrection_MenuItem,'Enable','on');
        set(handles.FreeViewWithStageCorrection_MenuItem,'Enable','on');
    end
    
%     if exist(GuiGlobalsStruct.OpticalWaferImageDirectory)
%         set(handles.AutoMapAllSections_MenuItem,'Enable','on');%Next step
%     end
%     
    %Check if 'Acquire Example Section Image' step is done
    if exist(GuiGlobalsStruct.ExampleSectionImageDirectory,'dir')
        set(handles.AcquireExampleSectionImage_MenuItem,'Checked','on');
        set(handles.ContrastCompensate_MenuItem,'Enable','on');%Next step
    end
    
    %Check if 'Contrast Compensate' step is done
    if exist(GuiGlobalsStruct.FullWaferTileImagesDirectory,'dir')
        MyTempFileName = sprintf('%s\\FullMapImage_BeforeContrastCompensation.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
        if exist(MyTempFileName, 'file')
            set(handles.ContrastCompensate_MenuItem,'Checked','on');
            set(handles.CropExampleImage_MenuItem,'Enable','on');%Next step
        end
    end
    if exist(GuiGlobalsStruct.OpticalWaferImageDirectory)  %this step is skipped if optical so just check it off
        set(handles.ContrastCompensate_MenuItem,'Checked','on');
        set(handles.CropExampleImage_MenuItem,'Enable','on');%Next step
    end
    
    %Check if 'Crop Example Image' step is done
    if exist(GuiGlobalsStruct.ExampleSectionImageDirectory,'dir')
        MyTempFileName = sprintf('%s\\ExampleSectionImageCropped.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
        if exist(MyTempFileName, 'file')
            set(handles.CropExampleImage_MenuItem,'Checked','on');
            set(handles.ThresholdImages_MenuItem,'Enable','on');%Next step
        end
    end
    
    %Check if 'Threshold Images' step is done
    if exist(GuiGlobalsStruct.ExampleSectionImageDirectory,'dir')
        MyTempFileName = sprintf('%s\\ExampleSectionImage_Thresholded.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
        if exist(MyTempFileName, 'file')
            set(handles.ThresholdImages_MenuItem,'Checked','on');
            set(handles.AutoMapAllSections_MenuItem,'Enable','on');%Next step
        end
    end
    
    %Check if 'Auto Map All Sections' step is done
    if exist(GuiGlobalsStruct.FullWaferTileImagesDirectory,'dir')
        %Load Coarse Section list if it exists
        if exist(GuiGlobalsStruct.FullWaferTileImagesDirectory,'dir')
            CoarseSectionListFileNameStr = sprintf('%s\\CoarseSectionList.mat',GuiGlobalsStruct.FullWaferTileImagesDirectory);
            if exist(CoarseSectionListFileNameStr,'file')
                disp(sprintf('Loading CoarseSectionList.mat file: %s',CoarseSectionListFileNameStr));
                load(CoarseSectionListFileNameStr,'CoarseSectionList');
                
                %Copy this info into GuiGlobalsStruct
                GuiGlobalsStruct.CoarseSectionList = CoarseSectionList;
                set(handles.AutoMapAllSections_MenuItem,'Checked','on'); 
                set(handles.PerformPixelToStageCalibration_MenuItem,'Enable','on'); %Next step
                set(handles.DisplaySectionCrosshairs_ToolbarButton,'state','on'); %default to displaying the sections labels
                GuiGlobalsStruct.IsDisplayCoarseSectionList = true;
            else
                GuiGlobalsStruct.CoarseSectionList = [];
            end
        else
            GuiGlobalsStruct.CoarseSectionList = [];
        end
        
        UpdateFullWaferDisplay(handles);
    end
    
    %Check if 'Perform Pixel To Stage Calibration' step is done
    if exist(GuiGlobalsStruct.PixelToStageCalibrationDirectory,'dir')
        MyTempFileName = sprintf('%s\\CalibrationFile.mat',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
        if exist(MyTempFileName, 'file')
            CalibrationFileNameStr = sprintf('%s\\CalibrationFile.mat',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
            load(CalibrationFileNameStr, 'MicronsPerPixel_FromCalibration', 'MicronsPerPixel_FromFibicsReadFOV');
            GuiGlobalsStruct.MicronsPerPixel_FromCalibration_ForOverviewImages = MicronsPerPixel_FromCalibration;

            
            set(handles.PerformPixelToStageCalibration_MenuItem,'Checked','on');
            set(handles.AcquireSectionOverviewImages_MenuItem,'Enable','on');%Next step
        end
    else
        MyStr = sprintf('No Pixel To Stage Calibration file found. Continuing anyway...');
        uiwait(msgbox(MyStr));
        if isfield(GuiGlobalsStruct, 'MicronsPerPixel_FromCalibration_ForOverviewImages')
            rmfield(GuiGlobalsStruct, 'MicronsPerPixel_FromCalibration_ForOverviewImages')
        end
    end
    
    %Check if 'Acquire Section Overview Images' step is done
    if exist(GuiGlobalsStruct.SectionOverviewsDirectory,'dir')
        set(handles.AcquireSectionOverviewImages_MenuItem,'Checked','on');
        
        %Wafer mapping has been completed on this wafer.
        % The user can now legally go on to processing these images and/or
        %   reloading this wafer in teh SEM
        MyStr = sprintf('This wafer has been fully mapped! \n Unlocking the ''Processing'' and ''Reload Wafer Operations'' menu');
        uiwait(msgbox(MyStr,'modal'));

        set(handles.SectionOverviewProcessing_MenuItem,'Enable','on');
        set(handles.ChooseSectionTemplateImage_MenuItem,'Enable','on'); %next step
        set(handles.ChooseSectionTemplateImageSubsequentWafer_MenuItem,'Enable','on'); %next step
        set(handles.CropSectionTemplateImage_MenuItem,'Enable','off');
        set(handles.AlignSectionOverviews_MenuItem,'Enable','off');
        
        set(handles.ReloadWaferOperations_MenuItem,'Enable','on');
        %The following are in the ReloadWaferOperations menu
        set(handles.DoAllStepsForStageCorrection_MenuItem,'Enable','on');
        set(handles.ReloadStageCorrection_MenuItem,'Enable','on');
        set(handles.FreeViewWithStageCorrection_MenuItem,'Enable','on');
    end
    
    
    %*** Continue checking how much has been done on the processing side
    %Check if 'Choose Section Template Image' step is done
    if exist(GuiGlobalsStruct.SectionOverviewTemplateDirectory,'dir')
       SectionOverviewTemplateFileNameStr = sprintf('%s\\SectionOverviewTemplate.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
       if exist(SectionOverviewTemplateFileNameStr, 'file')
            set(handles.ChooseSectionTemplateImage_MenuItem,'Checked','on');
            set(handles.CropSectionTemplateImage_MenuItem,'Enable','on'); %next step
       end
    end
    
    %Check if 'Crop Section Template Image' step is done
    if exist(GuiGlobalsStruct.SectionOverviewTemplateDirectory,'dir')
        CroppedImageFileNameStr = sprintf('%s\\SectionOverviewTemplateCroppedFilledPeriphery.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
        if exist(CroppedImageFileNameStr, 'file')
            set(handles.CropSectionTemplateImage_MenuItem,'Checked','on');
            set(handles.AlignSectionOverviews_MenuItem,'Enable','on');%next step
        end
    end
    
    %Check if 'Align Section Overviews' step is done
    if exist(GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory, 'dir')
        set(handles.AlignSectionOverviews_MenuItem,'Checked','on');
    end
    
end

% --------------------------------------------------------------------
function NewWafer_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NewWafer_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;



InputDlgAnswer = inputdlg('Enter name for new Wafer (will create subdirectory)');
if isempty(InputDlgAnswer)
    disp('User Canceled');
    return;
else
    
    %%% START: Clear all variables except those that should have been filled before
    Temp_handles_FromWaferMapper = GuiGlobalsStruct.handles_FromWaferMapper;
    Temp_HandleToWaferMapperFigure = GuiGlobalsStruct.HandleToWaferMapperFigure;
    Temp_IsZeissAPIInitialized = GuiGlobalsStruct.IsZeissAPIInitialized;
    Temp_IsFibicsAPIInitialized = GuiGlobalsStruct.IsFibicsAPIInitialized;
    Temp_h_StatusBar_EditBox = GuiGlobalsStruct.h_StatusBar_EditBox;
    if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass') %This is to handle case if we are running without microscope
        Temp_MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;
        IsField_MyCZEMAPIClass = true;
    else
        IsField_MyCZEMAPIClass = false;
    end
    Temp_MasterUTSLDirectory = GuiGlobalsStruct.MasterUTSLDirectory;
    Temp_IsLegalMasterUTSLDir = GuiGlobalsStruct.IsLegalMasterUTSLDir;
    Temp_UTSLDirectory = GuiGlobalsStruct.UTSLDirectory;
    Temp_ListOfWaferNames = GuiGlobalsStruct.ListOfWaferNames;
    clear global GuiGlobalsStruct;
    global GuiGlobalsStruct;
    GuiGlobalsStruct.handles_FromWaferMapper = Temp_handles_FromWaferMapper;
    GuiGlobalsStruct.HandleToWaferMapperFigure = Temp_HandleToWaferMapperFigure;
    GuiGlobalsStruct.IsZeissAPIInitialized = Temp_IsZeissAPIInitialized;
    GuiGlobalsStruct.IsFibicsAPIInitialized = Temp_IsFibicsAPIInitialized;
    GuiGlobalsStruct.h_StatusBar_EditBox = Temp_h_StatusBar_EditBox;
    if IsField_MyCZEMAPIClass %This is to handle case if we are running without microscope
        GuiGlobalsStruct.MyCZEMAPIClass = Temp_MyCZEMAPIClass;
    end
    GuiGlobalsStruct.MasterUTSLDirectory = Temp_MasterUTSLDirectory;
    GuiGlobalsStruct.IsLegalMasterUTSLDir = Temp_IsLegalMasterUTSLDir;
    GuiGlobalsStruct.UTSLDirectory = Temp_UTSLDirectory;
    GuiGlobalsStruct.ListOfWaferNames = Temp_ListOfWaferNames;
    %%% END: Clear all variables except those that should have been filled before
    
    InitParameters(handles);
    
    NewNameStr = InputDlgAnswer{1};
    NewDirPath = sprintf('%s\\%s', GuiGlobalsStruct.UTSLDirectory, NewNameStr);
    
    if ~exist(NewDirPath,'dir')
        [success,message,messageid] = mkdir(NewDirPath);
        if success == 1
            MasterDisableAndUncheckGuiItems(handles);
            set(handles.NewUTSL_MenuItem,'Enable','on');
            set(handles.OpenUTSL_MenuItem,'Enable','on');
            set(handles.NewWafer_MenuItem,'Enable','on');
            set(handles.OpenWafer_MenuItem,'Enable','on');
            
            
            GuiGlobalsStruct.WaferDirectory = NewDirPath;
            MyStr = sprintf('WaferMapper - %s', GuiGlobalsStruct.WaferDirectory);
            set(GuiGlobalsStruct.HandleToWaferMapperFigure,'name',MyStr);
            StatusBarMessage(MyStr);
            
            %Enable button for next step
            set(handles.MapWaferOperations_MenuItem,'Enable','on');
            set(handles.AcquireFullWaferMontage_MenuItem,'Enable','on'); %Next step
        else
            msgbox(message);
        end
        
    else
        MyStr = sprintf('Directory (%s) already exists. Must manually delete to overwrite',NewDirPath);
        uiwait(msgbox(MyStr));
    end
    
    
    
end

% --------------------------------------------------------------------
function MapWaferOperations_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MapWaferOperations_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on mouse press over axes background.
function Axes_FullWaferDisplay_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Axes_FullWaferDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function AcquireFullWaferMontage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireFullWaferMontage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

start=tic;
%Make sure we have scan rotation = 0;
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

%create a subdirectory in this to hold image data
GuiGlobalsStruct.FullWaferTileImagesDirectory = sprintf('%s\\FullWaferTileImages', GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.FullWaferTileImagesDirectory, 'dir')
    MyStr = sprintf('%s already exists. If you are sure you want to acquire a new full wafer montage of this wafer then manually delete this or create a new wafer directory.',...
        GuiGlobalsStruct.FullWaferTileImagesDirectory);
    h = msgbox(MyStr,'modal');
    pause(3)
    close(h);
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.FullWaferTileImagesDirectory);

else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.FullWaferTileImagesDirectory);
end


GuiGlobalsStruct.ProgramState = 'Acquiring Full Wafer Montage';

AcquireFullWaferMontage;
toc(start)
set(handles.AcquireFullWaferMontage_MenuItem,'Checked','on');
set(handles.FreeView_MenuItem,'Enable','on');
set(handles.AcquireLowResFiducials_MenuItem,'Enable','on'); %Next step


% --------------------------------------------------------------------
function AcquireLowResFiducials_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireLowResFiducials_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

uiwait(msgbox('WARNING: YOU MUST CHECK TO SEE IF X<Y BACKLASH IS ON IN SmartSEM->Tools->User Preferences...->Stage->Backlash. Set X and Y to ''All Directions'''));

disp('Turning stage backlash ON in X and Y');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);

%Make directory for fiducial images and info
GuiGlobalsStruct.LowResFiducialsDirectory = sprintf('%s\\LowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.LowResFiducialsDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.LowResFiducialsDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.LowResFiducialsDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.LowResFiducialsDirectory);
end

GuiGlobalsStruct.ProgramState = 'Acquiring Low Resolution Fiducials';

%TO DO: POPUP DIRECTIONS FOR GRAB AND NAVIGATION
MyStr = sprintf('LEFT CLICK in full wafer display to move stage to that position. \nRIGHT CLICK to ZOOM. \nPress ''G'' Key to grab fiducial image at current position. \nPress ESC key to finish');
uiwait(msgbox(MyStr));
NavigateFullWaferMap;

set(handles.AcquireLowResFiducials_MenuItem,'Checked','on');
set(handles.AcquireHighResFiducials_MenuItem,'Enable','on'); %Next step


% --------------------------------------------------------------------
function AcquireHighResFiducials_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireHighResFiducials_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

%uiwait(msgbox('WARNING: YOU MUST CHECK TO SEE IF X<Y BACKLASH IS ON IN SmartSEM->Tools->User Preferences...->Stage->Backlash. Set X and Y to ''All Directions'''));

disp('Turning stage backlash ON in X and Y');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_X_BACKLASH','+ -');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_Y_BACKLASH','+ -');
% GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeString('DP_STAGE_BACKLASH', GuiGlobalsStruct.backlashState);


%Make directory for fiducial images and info
GuiGlobalsStruct.HighResFiducialsDirectory = sprintf('%s\\HighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.HighResFiducialsDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.HighResFiducialsDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.HighResFiducialsDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.HighResFiducialsDirectory);
end

GuiGlobalsStruct.ProgramState = 'Acquiring High Resolution Fiducials';
MyStr = sprintf('LEFT CLICK in full wafer display to move stage to that position. \nRIGHT CLICK to ZOOM. \nPress ''G'' Key to grab fiducial image at current position. \nPress ESC key to finish');
uiwait(msgbox(MyStr));
NavigateFullWaferMap;

set(handles.AcquireHighResFiducials_MenuItem,'Checked','on');
set(handles.AcquireExampleSectionImage_MenuItem,'Enable','on');

% --------------------------------------------------------------------
function AcquireExampleSectionImage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireExampleSectionImage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);


IsJustOptical = false;
if isfield(GuiGlobalsStruct, 'OpticalWaferImageDirectory')
    if exist(GuiGlobalsStruct.OpticalWaferImageDirectory, 'dir') 
        IsJustOptical = true;
    end
end


%Make directory for fiducial images and info
GuiGlobalsStruct.ExampleSectionImageDirectory = sprintf('%s\\ExampleSectionImageDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.ExampleSectionImageDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.ExampleSectionImageDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.ExampleSectionImageDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ExampleSectionImageDirectory);
end


if ~IsJustOptical %if we are not doing optical only then go through normal process, else skip most
    
    GuiGlobalsStruct.ProgramState = 'Acquiring Example Section Image';
    MyStr = sprintf('LEFT CLICK in full wafer display to move stage to that position. \nRIGHT CLICK to ZOOM. \nPress ''G'' Key to grab example section image at current position. \nPress ESC key to finish');
    uiwait(msgbox(MyStr));
    NavigateFullWaferMap;
    
    set(handles.AcquireExampleSectionImage_MenuItem,'Checked','on');
    set(handles.ContrastCompensate_MenuItem,'Enable','on');
    
else
    FullMapImage_FileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
    MyStr = sprintf('Loading image file: %s',FullMapImage_FileNameStr);
    disp(MyStr);
    FullMapImageToCropFrom = imread(FullMapImage_FileNameStr,'tif');
    h_fig = figure();
    imshow(FullMapImageToCropFrom,[0,255]);
    
    
    MyStr = sprintf('Use mouse to drag box to be around only one section. Should be a little larger than the section. ');
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
        
        SubImage = FullMapImageToCropFrom(UpLeftCorner_R:LowerRightCorner_R, UpLeftCorner_C:LowerRightCorner_C);

        imshow(SubImage,[0,255]);
        
        %Expand this image to match the faux size of the montage
        SubImage = imresize(SubImage, GuiGlobalsStruct.FullMapData.DownsampleFactor);
        
        ImageFileNameStr = sprintf('%s\\ExampleSectionImage.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
        imwrite(SubImage,ImageFileNameStr,'tif');
        
        MyStr = sprintf('Saved file: %s \n Click OK to continue.',ImageFileNameStr);
        uiwait(msgbox(MyStr));
        
        
        
        
    end
    
    if ishandle(h_fig)
        close(h_fig);
    end
    
    
    
    %uiwait(msgbox('Since this wafer is based on an optical image program is skipping next steps. Press OK when ready to proceed.'));
    
    set(handles.AcquireExampleSectionImage_MenuItem,'Checked','on');
    set(handles.CropExampleImage_MenuItem,'Enable','on');
%     set(handles.AcquireExampleSectionImage_MenuItem,'Checked','on');
%     set(handles.AutoMapAllSections_MenuItem,'Enable','on');
end


% --------------------------------------------------------------------
function ContrastCompensate_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ContrastCompensate_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct

uiwait(ContrastCompensateGUI);

%Update GUI with this image
FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
disp(sprintf('Loading image file: %s',FullWaferImageFileNameStr));
GuiGlobalsStruct.FullWaferDownsampledDisplayImage = imread(FullWaferImageFileNameStr,'tif');
UpdateFullWaferDisplay(handles);


set(handles.ContrastCompensate_MenuItem,'Checked','on');
set(handles.CropExampleImage_MenuItem,'Enable','on');



% --------------------------------------------------------------------
function CropExampleImage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CropExampleImage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CropExampleImage;

set(handles.CropExampleImage_MenuItem,'Checked','on');
set(handles.ThresholdImages_MenuItem,'Enable','on');


% --------------------------------------------------------------------
function ThresholdImages_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdImages_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(SectionMaskGUI);

set(handles.ThresholdImages_MenuItem,'Checked','on');
set(handles.AutoMapAllSections_MenuItem,'Enable','on');

% --------------------------------------------------------------------
function AutoMapAllSections_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AutoMapAllSections_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(AutoMapGUI);

set(handles.AutoMapAllSections_MenuItem,'Checked','on');
set(handles.PerformPixelToStageCalibration_MenuItem,'Enable','on');
%set(handles.AcquireSectionOverviewImages_MenuItem,'Enable','on');
set(handles.DisplaySectionCrosshairs_ToolbarButton,'state','on'); %default to displaying the sections
GuiGlobalsStruct.IsDisplayCoarseSectionList = true;
UpdateFullWaferDisplay(handles);


function StatusBar_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to StatusBar_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StatusBar_EditBox as text
%        str2double(get(hObject,'String')) returns contents of StatusBar_EditBox as a double


% --- Executes during object creation, after setting all properties.
function StatusBar_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StatusBar_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function SEMControl_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SEMControl_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function InitializeZeissSEMControl_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeZeissSEMControl_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

h_msgbox = msgbox('Initializing Zeiss API Interface...','modal');

IsOK = false;
try
    GuiGlobalsStruct.MyCZEMAPIClass = actxserver('VBComObjectWrapperForZeissAPI.KHZeissSEMWrapperComClass');
    IsOk = true;
catch MyException
    uiwait(msgbox('Problem initializing Zeiss API. Some program functionality will be unavialable.'));
    set(handles.InitializeZeissSEMControl_MenuItem,'Checked','off');
    close(h_msgbox);
end

if IsOK
    MyReturnInt = GuiGlobalsStruct.MyCZEMAPIClass.InitialiseRemoting;
    if(MyReturnInt == 0)
        MyMag = GuiGlobalsStruct.MyCZEMAPIClass.GetMag;
        MyStr = sprintf('Zeiss API successfully initialized. GetMag() = %0.5g',MyMag);
        StatusBarMessage(MyStr);
        GuiGlobalsStruct.IsZeissAPIInitialized = true;
        set(handles.InitializeZeissSEMControl_MenuItem,'Checked','on');
        %set(handles.InitializeZeissSEMControl_MenuItem,'Enable','off'); %do not allow to reinit
        close(h_msgbox);
    else
        close(h_msgbox);
        uiwait(msgbox('Problem initializing Zeiss API.'));
        StatusBarMessage('Problem initializing Zeiss API.');
        set(handles.InitializeZeissSEMControl_MenuItem,'Checked','off');
    end
end





% --------------------------------------------------------------------
function InitializeFibicsControl_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeFibicsControl_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

if ~GuiGlobalsStruct.IsZeissAPIInitialized
    uiwait(msgbox('Must initialize Zeiss SEM control first.'));
else
    uiwait(msgbox('About to initialize FIBICS API. MAKE SURE ATLAS SOFTWARE IS CLOSED. Press OK when ready...'));
    h_msgbox = msgbox('Programatically setting Zeiss SEM to 25x before init of FIBICS. This is necessary to maintain consistency of FOV calcs. between FIBICS sessions','modal');
   
    
    StartMag = 25;
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',StartMag);
    pause(0.5);
    close(h_msgbox);
    
    if GuiGlobalsStruct.MyCZEMAPIClass.GetMag() == StartMag
        GuiGlobalsStruct.MyCZEMAPIClass.Fibics_Initialise();
        
        for i=1:15
            MyStr = sprintf(' Fibics Initializing, pausing 15 seconds... %d', i);
            h_msgbox = msgbox(MyStr);
            pause(1);
            close(h_msgbox);
        end
        
        
        MyStr = sprintf('Fibics API successfully initialized.'); 
        StatusBarMessage(MyStr);
        GuiGlobalsStruct.IsFibicsAPIInitialized = true;
        set(handles.InitializeFibicsControl_MenuItem,'Checked','on');
        
        %bring the WaferMapper figure to the front again
        figure(GuiGlobalsStruct.HandleToWaferMapperFigure);
    else
        uiwait(msgbox('Problem setting Zeiss SEM mag.'));
        GuiGlobalsStruct.IsFibicsAPIInitialized = false;
        set(handles.InitializeFibicsControl_MenuItem,'Checked','off');
    end
end

% --------------------------------------------------------------------
function TestFibicsAcquire_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to TestFibicsAcquire_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

if ~GuiGlobalsStruct.IsFibicsAPIInitialized
    uiwait(msgbox('Must initialize Fibics control first.'));
else
    FileName = 'C:\Windows\Temp\TestFibicsAcquireImage.tif';
    delete(FileName);
    pause(.2);
    
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_AcquireImage(1024,1024,...
        1,FileName);
    while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
        pause(.2);
    end
    pause(.2);
    
    AttemptTime = 0; %sec
    IsReadOK = false;
    while (~IsReadOK) && (AttemptTime < 5)
        IsReadOK = true;
        try
            MyImage = imread(FileName,'tif');
        catch MyException
            IsReadOK = false;
            TimeInc = 0.1;
            pause(TimeInc);
            AttemptTime = AttemptTime + TimeInc;
        end
    end
    
    if IsReadOK
        h_fig = figure;
        imshow(MyImage,[0, 255]);
        uiwait(msgbox('Acquired image displayed. Press OK to proceed.'));
        if ishandle(h_fig)
            close(h_fig);
        end
    else
        uiwait(msgbox('Acquire failed.'));
    end
end


% --------------------------------------------------------------------
function FreeView_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to FreeView_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%TempCopy_IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
GuiGlobalsStruct.IsUseStageCorrection = false;
NavigateFullWaferMap;
%GuiGlobalsStruct.IsUseStageCorrection = TempCopy_IsUseStageCorrection;

% --------------------------------------------------------------------
function PerformPixelToStageCalibration_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PerformPixelToStageCalibration_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

uiwait(msgbox('WARNING: This calibration uses the FOV and pixel values for the Section Overviews!, Do not change after calibration is performed.'));

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

GuiGlobalsStruct.PixelToStageCalibrationDirectory = sprintf('%s\\PixelToStageCalibrationDirectory',GuiGlobalsStruct.WaferDirectory);
% 
% if exist(GuiGlobalsStruct.PixelToStageCalibrationDirectory, 'dir')
%     MyStr = sprintf('%s already exists. Calibration is used to interpert the section overview images.If you are sure you want to perform this then manually delete the directory.',...
%         GuiGlobalsStruct.PixelToStageCalibrationDirectory);
%     uiwait(msgbox(MyStr,'modal'));
%     return;
% else
%     [success,message,messageid] = mkdir(GuiGlobalsStruct.PixelToStageCalibrationDirectory);
% end



AnswerName = questdlg('Do you want to trust Atlas engine clibration', ...
    'Question', ...
    'Yes', 'No', 'Yes');


if strcmp(AnswerName,'No')

GuiGlobalsStruct.ProgramState = 'Acquiring Pixel To Stage Calibration Images';
MyStr = sprintf('LEFT CLICK in full wafer display to move stage to that position. \nRIGHT CLICK to ZOOM. \nPress ''G'' Key to grab example section image at current position. \nPress ESC key to finish');
uiwait(msgbox(MyStr));

IsDoCalForXAndY = false; %used in NavigateFullWaferMap script
NavigateFullWaferMap; %Note it is in that function that the multiple images will be taken


if IsDoCalForXAndY
   PerformPixelToStageCalibration(handles); 
else
   PerformPixelToStageCalibration_YDirOnly(handles);  %PerformPixelToStageCalibration_XDirOnly(handles); 
end

else
    
    
AnswerOverview = questdlg('View example overview anyway?', ...
    'Question', ...
    'Yes', 'No', 'Yes');
if strcmp(AnswerOverview,'Yes')    
    NavigateFullWaferMap;
end
    
    
    
    FOV_microns = GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns;
    ImageWidthInPixels = GuiGlobalsStruct.WaferParameters.SectionOverviewWidth_pixels;
    
    MicronsPerPixel_FromFibicsReadFOV = FOV_microns/ImageWidthInPixels;
    disp(sprintf('MicronsPerPixel_FromFibicsReadFOV = %0.5g', MicronsPerPixel_FromFibicsReadFOV));
    MicronsPerPixel_FromCalibration = MicronsPerPixel_FromFibicsReadFOV; % -YStageShift_Microns/YPixelShift; %Note negative sign
    disp(sprintf('MicronsPerPixel_FromCalibration = %0.5g', MicronsPerPixel_FromCalibration));
    
    PercentDifference = 100*((MicronsPerPixel_FromCalibration/MicronsPerPixel_FromFibicsReadFOV)-1);
    disp(sprintf('PercentDifference = %0.5g', PercentDifference));
    
    mkdir(GuiGlobalsStruct.PixelToStageCalibrationDirectory)
    CalibrationFileNameStr = sprintf('%s\\CalibrationFile.mat',GuiGlobalsStruct.PixelToStageCalibrationDirectory);
    save(CalibrationFileNameStr, 'MicronsPerPixel_FromCalibration', 'MicronsPerPixel_FromFibicsReadFOV');
    
    
    MyStr = sprintf('Using Calibration: \n  um/pix (from calibration) = %0.5g\n  um/pix (from Fibics) = %0.5g\n  Percent difference = %0.5g%%',...
        MicronsPerPixel_FromCalibration, MicronsPerPixel_FromFibicsReadFOV, PercentDifference);
    uiwait(msgbox(MyStr,'modal'));
    
    
    
    
    %FetchFibicsPixelToStageCalibration(handles);
end

set(handles.PerformPixelToStageCalibration_MenuItem,'Checked','on');
set(handles.AcquireSectionOverviewImages_MenuItem,'Enable','on');

% --------------------------------------------------------------------
function AcquireSectionOverviewImages_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireSectionOverviewImages_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

%Make directory for section overview images and info
GuiGlobalsStruct.SectionOverviewsDirectory = sprintf('%s\\SectionOverviewsDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.SectionOverviewsDirectory, 'dir')
    MyStr = sprintf('%s already exists. \nPress OK if you want to continue to acquire section overviews \nNote: Previous files will NOT be overwritten - this allows for continuation if interrupted or for easy retakes.',...
        GuiGlobalsStruct.SectionOverviewsDirectory);
    MyAnswer = questdlg(MyStr, 'Question', 'OK', 'Cancel', 'Cancel')
    if strcmp(MyAnswer,'Cancel')
        return;
    end
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.SectionOverviewsDirectory);
end

GuiGlobalsStruct.ProgramState = 'Acquiring Section Overview Images';
AcquireOverviewImages;

set(handles.AcquireSectionOverviewImages_MenuItem,'Checked','on');

set(handles.SectionOverviewProcessing_MenuItem,'Enable','on');
set(handles.ChooseSectionTemplateImage_MenuItem,'Enable','on');
set(handles.ChooseSectionTemplateImageSubsequentWafer_MenuItem,'Enable','on');



% --------------------------------------------------------------------
function DisplaySectionCrosshairs_ToolbarButton_OnCallback(hObject, eventdata, handles)
% hObject    handle to DisplaySectionCrosshairs_ToolbarButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
GuiGlobalsStruct.IsDisplayCoarseSectionList = true;
UpdateFullWaferDisplay(handles);


% --------------------------------------------------------------------
function DisplaySectionCrosshairs_ToolbarButton_OffCallback(hObject, eventdata, handles)
% hObject    handle to DisplaySectionCrosshairs_ToolbarButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
GuiGlobalsStruct.IsDisplayCoarseSectionList = false;
UpdateFullWaferDisplay(handles);



function SectionLabel_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to SectionLabel_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionLabel_EditBox as text
%        str2double(get(hObject,'String')) returns contents of SectionLabel_EditBox as a double
global GuiGlobalsStruct;

UpdateSectionOverviewDisplay(handles);

% --- Executes during object creation, after setting all properties.
function SectionLabel_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionLabel_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SectionDecrement_Button.
function SectionDecrement_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SectionDecrement_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

ValStr = get(handles.SectionLabel_EditBox,'String');
Val = str2double(ValStr);
if isnan(Val)
    set(handles.SectionLabel_EditBox,'String','1');
else
    if Val > 1
        Val = Val - 1;
    else
        Val = 0;
    end
    
    
    ValStr = num2str(Val);
    set(handles.SectionLabel_EditBox,'String',ValStr);
end


LabelStr = get(handles.SectionLabel_EditBox,'String');
PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
PopupMenuCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
WaferName = PopupMenuCellArray{PopupMenuIndex};

%Check if this directory exists and change to current wafer name if not
WaferDirName = sprintf('%s\\%s',...
    GuiGlobalsStruct.UTSLDirectory, WaferName);
if ~exist(WaferDirName, 'dir')
    WaferDirName = GuiGlobalsStruct.WaferDirectory;
end


ImageFileNameStr = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.tif',...
    WaferDirName, LabelStr);
if ~exist(ImageFileNameStr, 'file')

   if PopupMenuIndex == 1
       %This is first wafer, refuse to go on just put back to original
       Val = Val + 1;
       ValStr = num2str(Val);
       set(handles.SectionLabel_EditBox,'String',ValStr);
   else
       set(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value',PopupMenuIndex-1); %next wafer
       PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
       WaferName = PopupMenuCellArray{PopupMenuIndex};
       %determine the last section number of this wafer
       CoarseSectionListFileNameStr = sprintf('%s\\%s\\FullWaferTileImages\\CoarseSectionList.mat',...
            GuiGlobalsStruct.UTSLDirectory, WaferName);
       
       load(CoarseSectionListFileNameStr,'CoarseSectionList');
       LastSectionNumberStr = CoarseSectionList(length(CoarseSectionList)).Label;
       set(handles.SectionLabel_EditBox,'String',LastSectionNumberStr); %first section
   end
    
end

UpdateSectionOverviewDisplay(handles);

% --- Executes on button press in SectionIncrement_Button.
function SectionIncrement_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SectionIncrement_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;


ValStr = get(handles.SectionLabel_EditBox,'String');
Val = str2double(ValStr);
if isnan(Val)
    set(handles.SectionLabel_EditBox,'String','1');
else
    Val = Val + 1;
    ValStr = num2str(Val);
    set(handles.SectionLabel_EditBox,'String',ValStr);
end

%Put in code to change to next wafer if last section
LabelStr = get(handles.SectionLabel_EditBox,'String');
PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
PopupMenuCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
WaferName = PopupMenuCellArray{PopupMenuIndex};

%Check if this directory exists and change to current wafer name if not
WaferDirName = sprintf('%s\\%s',...
    GuiGlobalsStruct.UTSLDirectory, WaferName);
if ~exist(WaferDirName, 'dir')
    WaferDirName = GuiGlobalsStruct.WaferDirectory;
end

ImageFileNameStr = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.tif',...
    WaferDirName, LabelStr);
if ~exist(ImageFileNameStr, 'file')

   if PopupMenuIndex == length(PopupMenuCellArray)
       %This is last wafer, refuse to go on
       Val = Val - 1;
       ValStr = num2str(Val);
       set(handles.SectionLabel_EditBox,'String',ValStr);
   else
       set(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value',PopupMenuIndex+1); %next wafer
       set(handles.SectionLabel_EditBox,'String','1'); %first section
   end
    
end

UpdateSectionOverviewDisplay(handles);



function MasterDisableAndUncheckGuiItems(handles)
global GuiGlobalsStruct;

cla(handles.Axes_FullWaferDisplay);
cla(handles.Axes_SectionOverviewDisplay);
MyStr = sprintf('Loaded Stage Transform: none');
set(handles.StageCorrectionStatus_EditBox, 'String', MyStr);

set(handles.NewUTSL_MenuItem,'Enable','off');
set(handles.OpenUTSL_MenuItem,'Enable','off');
set(handles.NewWafer_MenuItem,'Enable','off');
set(handles.OpenWafer_MenuItem,'Enable','off');

set(handles.MapWaferOperations_MenuItem,'Enable','off');
%The following are in the MapWaferOperations menu
set(handles.FreeView_MenuItem,'Checked','off');
set(handles.FreeView_MenuItem,'Enable','off');

set(handles.AcquireFullWaferMontage_MenuItem,'Checked','off');
set(handles.AcquireFullWaferMontage_MenuItem,'Enable','off');

set(handles.AcquireLowResFiducials_MenuItem,'Checked','off');
set(handles.AcquireLowResFiducials_MenuItem,'Enable','off');

set(handles.AcquireHighResFiducials_MenuItem,'Checked','off');
set(handles.AcquireHighResFiducials_MenuItem,'Enable','off');

set(handles.AcquireExampleSectionImage_MenuItem,'Checked','off');
set(handles.AcquireExampleSectionImage_MenuItem,'Enable','off');

set(handles.ContrastCompensate_MenuItem,'Checked','off');
set(handles.ContrastCompensate_MenuItem,'Enable','off');

set(handles.CropExampleImage_MenuItem,'Checked','off');
set(handles.CropExampleImage_MenuItem,'Enable','off');

set(handles.ThresholdImages_MenuItem,'Checked','off');
set(handles.ThresholdImages_MenuItem,'Enable','off');

set(handles.AutoMapAllSections_MenuItem,'Checked','off');
set(handles.AutoMapAllSections_MenuItem,'Enable','off');

set(handles.PerformPixelToStageCalibration_MenuItem,'Checked','off');
set(handles.PerformPixelToStageCalibration_MenuItem,'Enable','off');

set(handles.AcquireSectionOverviewImages_MenuItem,'Checked','off');
set(handles.AcquireSectionOverviewImages_MenuItem,'Enable','off');

set(handles.SectionOverviewProcessing_MenuItem,'Enable','off');
%The following are in the Processing menu
set(handles.ChooseSectionTemplateImage_MenuItem,'Enable','off');
set(handles.ChooseSectionTemplateImageSubsequentWafer_MenuItem,'Enable','off');
set(handles.CropSectionTemplateImage_MenuItem,'Enable','off');
set(handles.AlignSectionOverviews_MenuItem,'Enable','off');


% set(handles.ReloadWaferOperations_MenuItem,'Enable','off');
% %The following are in the ReloadWaferOperations menu
% set(handles.DoAllStepsForStageCorrection_MenuItem,'Enable','off');
% set(handles.ReloadStageCorrection_MenuItem,'Enable','off');
% set(handles.FreeViewWithStageCorrection_MenuItem,'Enable','off');

%other menus
% set(handles.TargetPointSetup_MenuItem,'Enable','off');
% set(handles.MontageSetup_MenuItem,'Enable','off');
%set(handles.XML_MenuItem,'Enable','off');



% --- Executes on button press in MouseZoom_CheckBox.
function MouseZoom_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to MouseZoom_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MouseZoom_CheckBox
if get(hObject,'Value')
    UpdateSectionOverviewDisplay(handles);
    axes(handles.Axes_SectionOverviewDisplay);
    zoom on;
else
    UpdateSectionOverviewDisplay(handles);
    axes(handles.Axes_SectionOverviewDisplay);
    zoom off;
end


% --------------------------------------------------------------------
function ReloadWaferOperations_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ReloadWaferOperations_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function DoAllStepsForStageCorrection_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to DoAllStepsForStageCorrection_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%wipe out any existing stage transformation
if isfield(GuiGlobalsStruct,'StageTransform')
    GuiGlobalsStruct = rmfield(GuiGlobalsStruct,'StageTransform');
end

IsPauseForFeedback = false;

%Set scan rot to zero like during original wafer mapping.
GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',0);

%*** Reimage low res fiducials

GuiGlobalsStruct.ReimageLowResFiducialsDirectory = sprintf('%s\\ReimageLowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
if ~exist(GuiGlobalsStruct.ReimageLowResFiducialsDirectory, 'dir')
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ReimageLowResFiducialsDirectory);
end
ReimageFiducials(GuiGlobalsStruct.LowResFiducialsDirectory, GuiGlobalsStruct.ReimageLowResFiducialsDirectory, false);

%*** Calculate low res stage transformation and save
%function [StageTransform, FudgeScaleUsed] = CalculateOffsetOfAllFiducials(FiducialsDirectory, ReimageFiducialsDirectory, IsCalculateFudgeScale, FudgeScaleToUseOtherwise)
[StageTransform, FudgeScaleUsedForLowRes] = CalculateOffsetOfAllFiducials(GuiGlobalsStruct.LowResFiducialsDirectory, GuiGlobalsStruct.ReimageLowResFiducialsDirectory, true, 1)
%Save this as the new transform in GuiGlobalsStruct
GuiGlobalsStruct.StageTransform = StageTransform;
GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = (180/pi)*asin(GuiGlobalsStruct.StageTransform.tdata.T(1,2));
MyStr = sprintf('Calculated Stage Transform: ScanRot = %d deg, x_offset = %d, y_offset = %d',...
    GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees,...
    GuiGlobalsStruct.StageTransform.tdata.T(3,1),...
    GuiGlobalsStruct.StageTransform.tdata.T(3,2));
if IsPauseForFeedback
    uiwait(msgbox(MyStr));
else
    disp(MyStr);
end

%Save low res correction stage transformation
LowResStageTransformationFileName = sprintf('%s\\LowResStageTransformation.mat',GuiGlobalsStruct.ReimageLowResFiducialsDirectory);
StageTransformScanRotationAngleInDegrees = GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees;
StageTransform = GuiGlobalsStruct.StageTransform; 
save(LowResStageTransformationFileName, 'StageTransformScanRotationAngleInDegrees', 'StageTransform');


if IsPauseForFeedback
    %*** Reimage low res fiducials with correction
    GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory = sprintf('%s\\ReimageWithCorrectionLowResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
    if ~exist(GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory, 'dir')
        [success,message,messageid] = mkdir(GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory);
    end
    ReimageFiducials(GuiGlobalsStruct.LowResFiducialsDirectory, GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory, false);
    
    %*** Display how good this did and pause for user
    CheckCorrection(GuiGlobalsStruct.LowResFiducialsDirectory, ...
        GuiGlobalsStruct.ReimageLowResFiducialsDirectory, ...
        GuiGlobalsStruct.ReimageWithCorrectionLowResFiducialsDirectory);
    
    
    %uiwait(msgbox('Check low res correction results then press ok to continue.'));

    
end

%*** Reimage high res fiducials
if exist(GuiGlobalsStruct.HighResFiducialsDirectory,'dir')

GuiGlobalsStruct.ReimageHighResFiducialsDirectory = sprintf('%s\\ReimageHighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
if ~exist(GuiGlobalsStruct.ReimageHighResFiducialsDirectory, 'dir')
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ReimageHighResFiducialsDirectory);
end
ReimageFiducials(GuiGlobalsStruct.HighResFiducialsDirectory, GuiGlobalsStruct.ReimageHighResFiducialsDirectory, false);

%*** Calculate high res stage transformation and save
%function [StageTransform, FudgeScaleUsed] = CalculateOffsetOfAllFiducials(FiducialsDirectory, ReimageFiducialsDirectory, IsCalculateFudgeScale, FudgeScaleToUseOtherwise)
%NOTE: THE FudgeScaleUsedForLowRes VALUE SHOULD BE STILL APPROPRIATE TO USE
%AS LONG AS WE HAVE NOT DONE AN AUTOFOCUS
    
    [StageTransform, dummy] = CalculateOffsetOfAllFiducials(GuiGlobalsStruct.HighResFiducialsDirectory, GuiGlobalsStruct.ReimageHighResFiducialsDirectory, false, FudgeScaleUsedForLowRes);
end

%Save this as the new transform in GuiGlobalsStruct
GuiGlobalsStruct.StageTransform = StageTransform;
GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = (180/pi)*asin(GuiGlobalsStruct.StageTransform.tdata.T(1,2));
MyStr = sprintf('Calculated Stage Transform: ScanRot = %d deg, x_offset = %d, y_offset = %d',...
    GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees,...
    GuiGlobalsStruct.StageTransform.tdata.T(3,1),...
    GuiGlobalsStruct.StageTransform.tdata.T(3,2));
if IsPauseForFeedback
    uiwait(msgbox(MyStr));
else
    disp(MyStr);
end

%Save high res correction stage transformation
HighResStageTransformationFileName = sprintf('%s\\HighResStageTransformation.mat',GuiGlobalsStruct.ReimageHighResFiducialsDirectory);
StageTransformScanRotationAngleInDegrees = GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees;
StageTransform = GuiGlobalsStruct.StageTransform; 
save(HighResStageTransformationFileName, 'StageTransformScanRotationAngleInDegrees', 'StageTransform');


%*** Reimage high res fiducials with correction
if exist(GuiGlobalsStruct.HighResFiducialsDirectory,'dir')

GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory = sprintf('%s\\ReimageWithCorrectionHighResFiducialsDirectory',GuiGlobalsStruct.WaferDirectory);
if ~exist(GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory, 'dir')
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory);
end
ReimageFiducials(GuiGlobalsStruct.HighResFiducialsDirectory, GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory, false);


%*** Display how good this did and pause for user
CheckCorrection(GuiGlobalsStruct.HighResFiducialsDirectory, ...
    GuiGlobalsStruct.ReimageHighResFiducialsDirectory, ...
    GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory);


if IsPauseForFeedback
   uiwait(msgbox('Check high res correction results then press ok to continue.')); 
end

%Quantify how well this did
[StageTransform, dummy] = CalculateOffsetOfAllFiducials(GuiGlobalsStruct.HighResFiducialsDirectory, GuiGlobalsStruct.ReimageWithCorrectionHighResFiducialsDirectory, false, FudgeScaleUsedForLowRes);
r_error_meters_max = 0;
for FiducialNum = 1:length(GuiGlobalsStruct.FiducialAlignmentArray)
    XOffset_Meters = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).XOffset_Meters;
    YOffset_Meters = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).YOffset_Meters;
    
    MyStr = sprintf('Fiducial#%d: XOffset_Meters = %d, YOffset_Meters = %d',FiducialNum,XOffset_Meters,YOffset_Meters);
    disp(MyStr);
    
    r = sqrt(XOffset_Meters^2 + YOffset_Meters^2);
    if r > r_error_meters_max
        r_error_meters_max = r;
    end
end

MyStr = sprintf('Final stage error after correction = %d microns', 1000000*r_error_meters_max);
uiwait(msgbox(MyStr));

end
%Reload this final stage correction to make sure it is current
HighResStageTransformationFileName = sprintf('%s\\HighResStageTransformation.mat',GuiGlobalsStruct.ReimageHighResFiducialsDirectory);
load(HighResStageTransformationFileName);
GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = StageTransformScanRotationAngleInDegrees;
GuiGlobalsStruct.StageTransform = StageTransform; 
MyStr = sprintf('Loaded Stage Transform: ScanRot = %d deg, x_offset = %d, y_offset = %d',...
    GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees,...
    GuiGlobalsStruct.StageTransform.tdata.T(3,1),...
    GuiGlobalsStruct.StageTransform.tdata.T(3,2));
set(handles.StageCorrectionStatus_EditBox, 'String', MyStr);



% --------------------------------------------------------------------
function FreeViewWithStageCorrection_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to FreeViewWithStageCorrection_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.IsUseStageCorrection = true;
NavigateFullWaferMap;


% --------------------------------------------------------------------
function ReloadStageCorrection_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ReloadStageCorrection_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;


HighResStageTransformationFileName = sprintf('%s\\HighResStageTransformation.mat',GuiGlobalsStruct.ReimageHighResFiducialsDirectory);
load(HighResStageTransformationFileName);
GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees = StageTransformScanRotationAngleInDegrees;
GuiGlobalsStruct.StageTransform = StageTransform; 


MyStr = sprintf('Loaded Stage Transform: ScanRot = %d deg, x_offset = %d, y_offset = %d',...
    GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees,...
    GuiGlobalsStruct.StageTransform.tdata.T(3,1),...
    GuiGlobalsStruct.StageTransform.tdata.T(3,2));
set(handles.StageCorrectionStatus_EditBox, 'String', MyStr);


% --------------------------------------------------------------------
function SectionOverviewProcessing_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewProcessing_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ChooseSectionTemplateImage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseSectionTemplateImage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%NOTE: THIS ASSUMES YOU ARE DOING THE FIRST WAFER OF THE UTSL!!! SEE BELOW
%FUNCTION OF SUBSEQUENT WAFERS
global GuiGlobalsStruct;

%Make directory 
GuiGlobalsStruct.SectionOverviewTemplateDirectory = sprintf('%s\\SectionOverviewTemplateDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.SectionOverviewTemplateDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.SectionOverviewTemplateDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.SectionOverviewTemplateDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.SectionOverviewTemplateDirectory);
end

%Only allow user to choose an existing overview image in this UTSL and in
%this wafer (since it is the first wafer)
uiwait(msgbox('NOTE: You can only choose an existing overview image in this UTSL and this wafer (since it is the first wafer). Press OK to choose.'));


if exist([GuiGlobalsStruct.SectionOverviewsDirectory 'Filtered'],'dir')
    SODir = [GuiGlobalsStruct.SectionOverviewsDirectory 'Filtered'];
else
    SODir = GuiGlobalsStruct.SectionOverviewsDirectory;
end
DirListArray = dir(SODir);
n = 1;
ListOfTifFileNames = [];
for i=1:length(DirListArray)
    if (DirListArray(i).isdir == 0) && strcmp(DirListArray(i).name(end-3:end),'.tif')
        ListOfTifFileNames{n} = DirListArray(i).name;
        n = n + 1;
    end
end
if length(ListOfTifFileNames) > 0
    [SelectionNumber,isok] = listdlg('PromptString','Select a wafer dir:',...
        'SelectionMode','single',...
        'ListString',ListOfTifFileNames);
    
    if isok == 1
        ImageFileNameStr = sprintf('%s\\%s',SODir,ListOfTifFileNames{SelectionNumber});  
    else
        return;
    end
else
    uiwait(msgbox('No *.tif files found'));
    return;
end


h_fig = figure();
MyImage = imread(ImageFileNameStr);
imshow(MyImage, [0,255]);

NewImageFileNameStr = sprintf('%s\\SectionOverviewTemplate.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory); 
MyStr = sprintf('About to copy file: %s to new file: %s',ImageFileNameStr,NewImageFileNameStr);
ButtonName = questdlg(MyStr,'title','OK','Cancel','OK');
if strcmp(ButtonName,'OK')
    imwrite(MyImage,NewImageFileNameStr,'tif');
end

if ishandle(h_fig)
    close(h_fig);
end

set(handles.ChooseSectionTemplateImage_MenuItem,'Checked','on');
set(handles.CropSectionTemplateImage_MenuItem,'Enable','on');


% --------------------------------------------------------------------
function ChooseSectionTemplateImageSubsequentWafer_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseSectionTemplateImageSubsequentWafer_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%NOTE: THIS ASSUMES YOU ARE NOT DOING THE FIRST WAFER BUT ARE INSTEAD DOING
%A SUBSEQUENT WAFER OF THE UTSL!!! SEE ABOVE FUNCTION FOR FIRST WAFERS
global GuiGlobalsStruct;

%Make directory 
GuiGlobalsStruct.SectionOverviewTemplateDirectory = sprintf('%s\\SectionOverviewTemplateDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.SectionOverviewTemplateDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.SectionOverviewTemplateDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.SectionOverviewTemplateDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.SectionOverviewTemplateDirectory);
end

%Only allow user to choose an existing overview image in this UTSL
uiwait(msgbox('NOTE: You can only choose an existing overview image in this UTSL in a directory of aligned overview images. Press OK to choose.'));

%choose wafer in current UTSL
DirListArray = dir(GuiGlobalsStruct.UTSLDirectory);
n = 1;
ListOfDirNames = [];
for i=1:length(DirListArray)
    if (DirListArray(i).isdir == 1) && (DirListArray(i).name(1) ~= '.')
        ListOfDirNames{n} = DirListArray(i).name;
        n = n + 1;
    end
end
if length(ListOfDirNames) > 0
    [SelectionNumber,isok] = listdlg('PromptString','Select a wafer dir:',...
        'SelectionMode','single',...
        'ListString',ListOfDirNames);
    
    if isok == 1
        TempWaferDirectory = sprintf('%s\\%s',GuiGlobalsStruct.UTSLDirectory,ListOfDirNames{SelectionNumber});  
    else
        return;
    end
else
    uiwait(msgbox('No wafers found'));
    return;
end


TempSectionOverviewAlignedWithTemplateDirectory = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory',TempWaferDirectory); 

DirListArray = dir(TempSectionOverviewAlignedWithTemplateDirectory);
n = 1;
ListOfTifFileNames = [];
for i=1:length(DirListArray)
    if (DirListArray(i).isdir == 0) && strcmp(DirListArray(i).name(end-3:end),'.tif')
        ListOfTifFileNames{n} = DirListArray(i).name;
        n = n + 1;
    end
end
if length(ListOfTifFileNames) > 0
    [SelectionNumber,isok] = listdlg('PromptString','Select a wafer dir:',...
        'SelectionMode','single',...
        'ListString',ListOfTifFileNames);
    
    if isok == 1
        ImageFileNameStr = sprintf('%s\\%s',TempSectionOverviewAlignedWithTemplateDirectory,ListOfTifFileNames{SelectionNumber});  
    else
        return;
    end
else
    uiwait(msgbox('No *.tif files found'));
    return;
end


h_fig = figure();
MyImage = imread(ImageFileNameStr);
imshow(MyImage, [0,255]);

NewImageFileNameStr = sprintf('%s\\SectionOverviewTemplate.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory); 
MyStr = sprintf('About to copy file: %s to new file: %s',ImageFileNameStr,NewImageFileNameStr);
ButtonName = questdlg(MyStr,'title','OK','Cancel','OK');
if strcmp(ButtonName,'OK')
    imwrite(MyImage,NewImageFileNameStr,'tif');
end

if ishandle(h_fig)
    close(h_fig);
end

set(handles.ChooseSectionTemplateImage_MenuItem,'Checked','on');
set(handles.CropSectionTemplateImage_MenuItem,'Enable','on');



% --------------------------------------------------------------------
function AlignSectionOverviews_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AlignSectionOverviews_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Make directory for fiducial images and info
global GuiGlobalsStruct;

%Make directory 
GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory',GuiGlobalsStruct.WaferDirectory);

if exist(GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory, 'dir')
    MyStr = sprintf('%s already exists. Wafermapper will copy and backup the old directory.',...
        GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory);
    uiwait(msgbox(MyStr,'modal'));
    [success,message,messageid] = mkdirBackup(GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory);
else
    [success,message,messageid] = mkdir(GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory);
end

start=tic
GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType
try 
    alignType = GuiGlobalsStruct.SectionOverviewProcessingParameters.alignType;
catch 
    alignType = 'CC';
end

if strcmp(alignType,'CC')
    AlignOverviews_CrossCorrelation;
elseif strcmp(alignType,'CCE')
    AlignOverviews_CrossCorrelationLong;
elseif strcmp(alignType,'SURF');
    AlignOverviews
else
    'no alignment type defined'
    AlignOverviews_CrossCorrelation
end

toc(start)
set(handles.AlignSectionOverviews_MenuItem,'Checked','on');



% --------------------------------------------------------------------
function CropSectionTemplateImage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CropSectionTemplateImage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%Check that directory and SectionOverviewTemplate.tif exist
GuiGlobalsStruct.SectionOverviewTemplateDirectory = sprintf('%s\\SectionOverviewTemplateDirectory',GuiGlobalsStruct.WaferDirectory);
SectionOverviewTemplateFileNameStr = sprintf('%s\\SectionOverviewTemplate.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);

if ~exist(GuiGlobalsStruct.SectionOverviewTemplateDirectory, 'dir')
    MyStr = sprintf('%s does not exist.',...
        GuiGlobalsStruct.SectionOverviewTemplateDirectory);
    uiwait(msgbox(MyStr,'modal'));
    return;
end
if ~exist(SectionOverviewTemplateFileNameStr, 'file')
    MyStr = sprintf('%s does not exist.',...
        SectionOverviewTemplateFileNameStr);
    uiwait(msgbox(MyStr,'modal'));
    return;
end

CroppedImageFileNameStr = sprintf('%s\\SectionOverviewTemplateCropped.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
if exist(CroppedImageFileNameStr, 'file')
    MyStr = sprintf('%s already exists. If you are sure you wnat to replace then delete manually first.',...
        SectionOverviewTemplateFileNameStr);
    uiwait(msgbox(MyStr,'modal'));
    return;
end

CropSectionOverviewTemplate;
set(handles.CropSectionTemplateImage_MenuItem,'Checked','on');
set(handles.AlignSectionOverviews_MenuItem,'Enable','on');


function StageCorrectionStatus_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to StageCorrectionStatus_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StageCorrectionStatus_EditBox as text
%        str2double(get(hObject,'String')) returns contents of StageCorrectionStatus_EditBox as a double


% --- Executes during object creation, after setting all properties.
function StageCorrectionStatus_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StageCorrectionStatus_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MontageSetup_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MontageSetup_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ChooseTargetInInAligned_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseTargetInInAligned_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

axes(handles.Axes_SectionOverviewDisplay);
[x_mouse, y_mouse, button] = ginput(1);

%Place a visual marker here
GuiGlobalsStruct.IsDisplayMontageTarget = true;
GuiGlobalsStruct.MontageTarget.r = y_mouse;
GuiGlobalsStruct.MontageTarget.c = x_mouse;

%Remove any existing AlignedTargetList field since you are choosing a new
%target point
if isfield(GuiGlobalsStruct, 'AlignedTargetList')
    GuiGlobalsStruct = rmfield(GuiGlobalsStruct, 'AlignedTargetList');
end

UpdateSectionOverviewDisplay(handles);


% --- Executes on button press in GoToTargetPoint_Button.
function GoToTargetPoint_Button_Callback(hObject, eventdata, handles)
% hObject    handle to GoToTargetPoint_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GoToMontageTargetPointRotationAndFOV;




% --------------------------------------------------------------------
function SetNorthDirectionForMontage_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SetNorthDirectionForMontage_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
MyAnswer = inputdlg('Enter angle (0 to 360deg) of montage north relative to overview template north',...
    'Angle Dialog',1,{num2str(GuiGlobalsStruct.MontageTarget.MontageNorthAngle)});

if ~isempty(MyAnswer) %is empty if user canceled
    MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
else
    MyAnswer2Num = NaN;
end

if ~( isnan(MyAnswer2Num) || (MyAnswer2Num < 0) || (MyAnswer2Num > 360) )
    GuiGlobalsStruct.MontageTarget.MontageNorthAngle = MyAnswer2Num;
    UpdateSectionOverviewDisplay(handles);
else
    uiwait(msgbox('Illegal value. Not updating.')) ;
end


% --- Executes on button press in SetupZoomParameters_Button.
function SetupZoomParameters_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SetupZoomParameters_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
axes(handles.Axes_SectionOverviewDisplay);
zoom on;


% --- Executes on button press in LockCurrentZoomParameters_Button.
function LockCurrentZoomParameters_Button_Callback(hObject, eventdata, handles)
% hObject    handle to LockCurrentZoomParameters_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

axes(handles.Axes_SectionOverviewDisplay);
zoom off;

GuiGlobalsStruct.OverviewDisplay_xlim = get(handles.Axes_SectionOverviewDisplay, 'xlim');
GuiGlobalsStruct.OverviewDisplay_ylim = get(handles.Axes_SectionOverviewDisplay, 'ylim');


% --- Executes on button press in ResetZoomToFull_MenuItem.
function ResetZoomToFull_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ResetZoomToFull_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
axes(handles.Axes_SectionOverviewDisplay);
zoom out;

GuiGlobalsStruct.OverviewDisplay_xlim = get(handles.Axes_SectionOverviewDisplay, 'xlim');
GuiGlobalsStruct.OverviewDisplay_ylim = get(handles.Axes_SectionOverviewDisplay, 'ylim');


% --------------------------------------------------------------------
function SetMontageFieldOfView_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SetMontageFieldOfView_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
%ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER)
MyAnswer = inputdlg('Enter width of montage in microns','Montage Setup', 1, {num2str(GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons)});

if ~isempty(MyAnswer) %is empty if user canceled
    MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
else
    MyAnswer2Num = NaN;
end

if ~( isnan(MyAnswer2Num) || (MyAnswer2Num < 1) || (MyAnswer2Num > 4000) )
    GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons = MyAnswer2Num;
else
    uiwait(msgbox('Illegal value. Not updating.')) ;
    return
end

MyAnswer = inputdlg('Enter height of montage in microns','Montage Setup', 1, {num2str(GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons)});

if ~isempty(MyAnswer) %is empty if user canceled
    MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
else
    MyAnswer2Num = NaN;
end

if ~( isnan(MyAnswer2Num) || (MyAnswer2Num < 1) || (MyAnswer2Num > 4000) )
    GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons = MyAnswer2Num;
else
    uiwait(msgbox('Illegal value. Not updating.')) ;
    return
end

UpdateSectionOverviewDisplay(handles);





% --- Executes on selection change in WaferForSectionOverviewDisplay_PopupMenu.
function WaferForSectionOverviewDisplay_PopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to WaferForSectionOverviewDisplay_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WaferForSectionOverviewDisplay_PopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WaferForSectionOverviewDisplay_PopupMenu


% --- Executes during object creation, after setting all properties.
function WaferForSectionOverviewDisplay_PopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WaferForSectionOverviewDisplay_PopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AlignedSectionOverviewFileName_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to AlignedSectionOverviewFileName_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AlignedSectionOverviewFileName_EditBox as text
%        str2double(get(hObject,'String')) returns contents of AlignedSectionOverviewFileName_EditBox as a double
global GuiGlobalsStruct;

UpdateSectionOverviewDisplay(handles);

% --- Executes during object creation, after setting all properties.
function AlignedSectionOverviewFileName_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlignedSectionOverviewFileName_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --------------------------------------------------------------------
function TargetPointParameters_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to TargetPointParameters_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
%ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER)
MyAnswer = inputdlg('Enter width of Low Res Box (for alignment) in microns','Montage Setup', 1, {num2str(GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons)});

if ~isempty(MyAnswer) %is empty if user canceled
    MyAnswer2Num = str2double(MyAnswer{1}); %NaN if invalid or blank
else
    MyAnswer2Num = NaN;
end

if ~( isnan(MyAnswer2Num) || (MyAnswer2Num < 1) || (MyAnswer2Num > 4000) )
    GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons = MyAnswer2Num;
    GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons = MyAnswer2Num;
else
    uiwait(msgbox('Illegal value. Not updating.')) ;
    return
end


UpdateSectionOverviewDisplay(handles);


% --------------------------------------------------------------------
function GenerateListOfAlignedTargetPoints_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateListOfAlignedTargetPoints_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: This function starts at section1 wafer1 and crops the region of the
%SectionOverview image that is defined by the LowResForAlign box. It then
%goes to section2 and does a software alignment to this and recordes the
%offset needed to align these. It continues to the last section
global GuiGlobalsStruct;

GenerateListOfAlignedTargetPoints;


% --------------------------------------------------------------------
function TargetPointSetup_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to TargetPointSetup_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadExistingListOfAlignedTargetPoints_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadExistingListOfAlignedTargetPoints_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.AlignedTargetListsDirectory = sprintf('%s\\AlignedTargetListsDirectory',GuiGlobalsStruct.UTSLDirectory);



if ~exist(GuiGlobalsStruct.AlignedTargetListsDirectory, 'dir')
    MyStr = sprintf('Could not find directory: %s.',GuiGlobalsStruct.AlignedTargetListsDirectory);
    uiwait(msgbox(MyStr));
    return;
else
    DirListArray = dir(GuiGlobalsStruct.AlignedTargetListsDirectory);
    n = 1;
    ListOfDirNames = [];
    for i=1:length(DirListArray)
        if (DirListArray(i).isdir == 1) && (DirListArray(i).name(1) ~= '.')
            ListOfDirNames{n} = DirListArray(i).name;
            n = n + 1;
        end
    end
    
    if length(ListOfDirNames) > 0
        [SelectionNumber,isok] = listdlg('PromptString','Select:',...
            'SelectionMode','single',...
            'ListString',ListOfDirNames);
        
        if isok == 1
            GuiGlobalsStruct.AlignedTargetListDir = sprintf('%s\\%s',...
                GuiGlobalsStruct.AlignedTargetListsDirectory,ListOfDirNames{SelectionNumber});
            %load AlignedTargetList.mat
            DataFileNameStr = sprintf('%s\\AlignedTargetList.mat',GuiGlobalsStruct.AlignedTargetListDir);
            load(DataFileNameStr, 'AlignedTargetList');
            
            GuiGlobalsStruct.AlignedTargetList = AlignedTargetList;
            
            GuiGlobalsStruct.IsDisplayMontageTarget = true;
            
            %fill in all montage target point stuff from file
            GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons = AlignedTargetList.LowResForAlignWidthInMicrons;
            GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons = AlignedTargetList.LowResForAlignHeightInMicrons;
            GuiGlobalsStruct.MontageTarget.MicronsPerPixel = AlignedTargetList.MicronsPerPixel;
            if isfield(AlignedTargetList, 'AF_X_Offset_Microns')
                GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns= AlignedTargetList.AF_X_Offset_Microns;
                GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns= AlignedTargetList.AF_Y_Offset_Microns;
            end
            
           
            WaferNameIndex = find(strcmp(AlignedTargetList.ListOfWaferNames,GuiGlobalsStruct.WaferName))
            SectionIndex = 1;
            GuiGlobalsStruct.MontageTarget.r = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).r;
            GuiGlobalsStruct.MontageTarget.c = AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).c;
            
       
            %reset montage specific parameters to defaults
            GuiGlobalsStruct.MontageTarget.MontageNorthAngle = 0; %degrees
            GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons = 40.96;
            GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons = 40.96;
            
   
            
            UpdateSectionOverviewDisplay(handles);
            
        end
    else
        uiwait(msgbox('No AlignedTargetLists found.'));
        return;
    end
end


%Place a visual marker here


% --------------------------------------------------------------------
function AcquireMontageStackAtTargetPoint_MeuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireMontageStackAtTargetPoint_MeuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

AcquireMontageStackAtPointsOfTestStack;

%AcquireMontageStackAtTargetPoint;
%GenerateXMLofTargetPoints;


% --------------------------------------------------------------------
function CheckAndCorrectAlignmentGUI_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CheckAndCorrectAlignmentGUI_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AlignOverviewsGUI();


% --- Executes on button press in GenerateXMLforTarget_Button.
function GenerateXMLforTarget_Button_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLforTarget_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
GenerateXMLAtTargetPoint;


% --- Executes on button press in button_AcquireStackAtTargetPoint.
function button_AcquireStackAtTargetPoint_Callback(hObject, eventdata, handles)
% hObject    handle to button_AcquireStackAtTargetPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
AcquireStack;


% --- Executes on button press in GoToTargetPointWithImageBasedCorrection_Button.
function GoToTargetPointWithImageBasedCorrection_Button_Callback(hObject, eventdata, handles)
% hObject    handle to GoToTargetPointWithImageBasedCorrection_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%Make sure the TempImagesDirectory is back to its default (this is changed
%when taking a montage stack
GuiGlobalsStruct.TempImagesDirectory = sprintf('%s\\TempImagesDirectory',GuiGlobalsStruct.WaferDirectory);

%Determine the wafer name of the image currently displayed
PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
PopupMenuCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
WaferName_InDisplay = PopupMenuCellArray{PopupMenuIndex};
MyStr = sprintf('WaferName_InDisplay = %s', WaferName_InDisplay);
disp(MyStr);

% %Determine what wafer is loaded

WaferName_CurrentlyLoaded = GuiGlobalsStruct.WaferName;
MyStr = sprintf('WaferName_CurrentlyLoaded = %s', WaferName_CurrentlyLoaded);
disp(MyStr);

WaferName = WaferName_CurrentlyLoaded; %KH added 8-27-2011

if 1 ~= strcmp(WaferName_CurrentlyLoaded, WaferName_InDisplay)
    MyStr = sprintf('Wafer displayed (%s) is not the one currently loaded (%s)',...
        WaferName_InDisplay, WaferName_CurrentlyLoaded);
    uiwait(msgbox(MyStr));
else
   GoToTargetPointWithImageBasedStageCorrection; 
end


% --------------------------------------------------------------------
function SetMontageParameters_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SetMontageParameters_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
uiwait(MontageParametersGUI());

UpdateSectionOverviewDisplay(handles);




% --------------------------------------------------------------------
function CheckAndCorrectTargetPointAlignment_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CheckAndCorrectTargetPointAlignment_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


AlignTargetPointListGUI();

function SectionOverviewRobustRigidParameters_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewProcessingParameters_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(ProcessOverviewsRobustRigidParameters2());

% --------------------------------------------------------------------
function SectionOverviewProcessingParameters_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SectionOverviewProcessingParameters_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(SectionOverviewProcessingParametersGUI());

% --------------------------------------------------------------------
function WaferParameters_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to WaferParameters_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(WaferParametersGUI);


% --------------------------------------------------------------------
function AcquireTestStackAtTargetPoint_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireTestStackAtTargetPoint_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

AcquireTestStackAtTargetPoint;
%GenerateXMLofTargetPoints;


% --------------------------------------------------------------------
function GenerateVirtualSectionOverviews_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateVirtualSectionOverviews_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%Determine image size to match what would be taken in actual section
%overview
FOV_microns = GuiGlobalsStruct.WaferParameters.SectionOverviewFOV_microns; %4096; % 4096;

SizeOfPixelInTiles_microns =  GuiGlobalsStruct.WaferParameters.TileFOV_microns/GuiGlobalsStruct.WaferParameters.TileWidth_pixels;

    

WidthSubImage = FOV_microns/SizeOfPixelInTiles_microns;
HeightSubImage = WidthSubImage;


for SectionNum = 1:length(GuiGlobalsStruct.CoarseSectionList)
    
    
    r_IndexInFullMap = GuiGlobalsStruct.CoarseSectionList(SectionNum).rpeak*GuiGlobalsStruct.FullMapData.DownsampleFactor;
    c_IndexInFullMap = GuiGlobalsStruct.CoarseSectionList(SectionNum).cpeak*GuiGlobalsStruct.FullMapData.DownsampleFactor;
    Label = GuiGlobalsStruct.CoarseSectionList(SectionNum).Label;
    
    
    %***HARD-CODING. For AMW: fix this***
    WidthSubImage = 1024;
    HeightSubImage = 1024;
    
    [SubImage] = ExtractSubImageFromFullWaferTileMontage(r_IndexInFullMap, c_IndexInFullMap, WidthSubImage, HeightSubImage);
 
    figure(232);
    imshow(SubImage, [0, 255]);
    MyStr = sprintf('Section# = %d, Label = %s', SectionNum, Label);
    title(MyStr);
    
    
    pause(.1);
    
    
end


% --------------------------------------------------------------------
function XML_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to XML_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function GenerateXMLFromSectionList_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLFromSectionList_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GenerateXMLFromSectionList();

% --------------------------------------------------------------------
function GenerateXMLFromCurrentTargetPoint_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLFromCurrentTargetPoint_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GenerateXMLAtTargetPoint();

% --------------------------------------------------------------------
function GenerateXMLFromAlignedTargetPoints_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLFromAlignedTargetPoints_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GenerateXMLFromAlignedTargetPoints();

% --------------------------------------------------------------------
function TransformXMLUsingCurrentStageCorrection_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to TransformXMLUsingCurrentStageCorrection_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveMontageSetup_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMontageSetup_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

SavedMontageParameters = GuiGlobalsStruct.MontageParameters;

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediatly after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uiputfile('*.mat', 'Select file for Save As:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    OutputFileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);

save(OutputFileName, 'SavedMontageParameters');

% --------------------------------------------------------------------
function LoadExistingMontageSetup_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadExistingMontageSetup_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global GuiGlobalsStruct;

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediately after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uigetfile('*.mat', 'Select file to load:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    FileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);

load(FileName, 'SavedMontageParameters');

%EXIST('A','var')
if ~exist('SavedMontageParameters','var')
    beep;
    uiwait(msgbox('Not a valid MontageParameters file'));
    return;
end

FixMontageParametersDefaults(SavedMontageParameters)
% 
% GuiGlobalsStruct.MontageParameters.TileFOV_microns = SavedMontageParameters.TileFOV_microns;
% GuiGlobalsStruct.MontageParameters.TileWidth_pixels = SavedMontageParameters.TileWidth_pixels;
% GuiGlobalsStruct.MontageParameters.TileDwellTime_microseconds = SavedMontageParameters.TileDwellTime_microseconds;
% 
% GuiGlobalsStruct.MontageParameters.MontageNorthAngle = SavedMontageParameters.MontageNorthAngle;
% GuiGlobalsStruct.MontageParameters.NumberOfTileRows = SavedMontageParameters.NumberOfTileRows;
% GuiGlobalsStruct.MontageParameters.NumberOfTileCols = SavedMontageParameters.NumberOfTileCols;
% GuiGlobalsStruct.MontageParameters.PercentTileOverlap = SavedMontageParameters.PercentTileOverlap;
% 
% if isfield(SavedMontageParameters, 'XOffsetFromAlignTargetMicrons')
%     GuiGlobalsStruct.MontageParameters.XOffsetFromAlignTargetMicrons = SavedMontageParameters.XOffsetFromAlignTargetMicrons;
%     GuiGlobalsStruct.MontageParameters.YOffsetFromAlignTargetMicrons = SavedMontageParameters.YOffsetFromAlignTargetMicrons;
% end
% 
% if isfield(SavedMontageParameters, 'AF_X_Offset_Microns')
%     GuiGlobalsStruct.MontageParameters.AF_X_Offset_Microns = SavedMontageParameters.AF_X_Offset_Microns;
%     GuiGlobalsStruct.MontageParameters.AF_Y_Offset_Microns = SavedMontageParameters.AF_Y_Offset_Microns;
% end
% 
% if isfield(SavedMontageParameters, 'IsSingle_AF_ForWholeMontage')
%     GuiGlobalsStruct.MontageParameters.IsSingle_AF_ForWholeMontage = SavedMontageParameters.IsSingle_AF_ForWholeMontage;
%     GuiGlobalsStruct.MontageParameters.IsSingle_AFASAF_ForWholeMontage = SavedMontageParameters.IsSingle_AFASAF_ForWholeMontage;
%     GuiGlobalsStruct.MontageParameters.IsAFOnEveryTile = SavedMontageParameters.IsAFOnEveryTile;
%     GuiGlobalsStruct.MontageParameters.IsAFASAFOnEveryTile = SavedMontageParameters.IsAFASAFOnEveryTile;
%     GuiGlobalsStruct.MontageParameters.IsPlaneFit = SavedMontageParameters.IsPlaneFit;
%     GuiGlobalsStruct.MontageParameters.IsXFit = SavedMontageParameters.IsXFit;
%     GuiGlobalsStruct.MontageParameters.noFocus = SavedMontageParameters.noFocus;
%     GuiGlobalsStruct.MontageParameters.RowDistBetweenAFPointsMicrons = SavedMontageParameters.RowDistBetweenAFPointsMicrons;
%     GuiGlobalsStruct.MontageParameters.ColDistBetweenAFPointsMicrons = SavedMontageParameters.ColDistBetweenAFPointsMicrons;
% end
% 
% if isfield(SavedMontageParameters, 'AutoFocusStartMag') %added 12-8-2011
%     GuiGlobalsStruct.MontageParameters.AutoFocusStartMag = SavedMontageParameters.AutoFocusStartMag;
%     GuiGlobalsStruct.MontageParameters.IsPerformQualityCheckOnEveryAF = SavedMontageParameters.IsPerformQualityCheckOnEveryAF;
%     GuiGlobalsStruct.MontageParameters.AFQualityThreshold = SavedMontageParameters.AFQualityThreshold;
%     GuiGlobalsStruct.MontageParameters.IsPerformQualCheckAfterEachImage = SavedMontageParameters.IsPerformQualCheckAfterEachImage;
%     GuiGlobalsStruct.MontageParameters.ImageQualityThreshold = SavedMontageParameters.ImageQualityThreshold;
% end
% 
% if isfield(SavedMontageParameters, 'AutofunctionScanrate') %added 3-24-2012
%     GuiGlobalsStruct.MontageParameters.AutofunctionScanrate = SavedMontageParameters.AutofunctionScanrate;
% end
% 
% if isfield(SavedMontageParameters, 'IsSingle_AF_ForWholeMontage')
%     GuiGlobalsStruct.MontageParameters.IsAcquireOverviewImage = SavedMontageParameters.IsAcquireOverviewImage;
% end
% if isfield(SavedMontageParameters, 'IsTargetFocus')
%     GuiGlobalsStruct.MontageParameters.IsTargetFocus = SavedMontageParameters.IsTargetFocus;
% end
% if isfield(SavedMontageParameters, 'IBSCContrast') %Added 5-2013
%     GuiGlobalsStruct.MontageParameters.IBSCContrast = SavedMontageParameters.IBSCContrast;
% end
% if isfield(SavedMontageParameters, 'IBSCBrightness')
%     GuiGlobalsStruct.MontageParameters.IBSCBrightness = SavedMontageParameters.IBSCBrightness;
% end
% if isfield(SavedMontageParameters, 'ImageContrast')
%     GuiGlobalsStruct.MontageParameters.ImageContrast = SavedMontageParameters.ImageContrast;
% end
% if isfield(SavedMontageParameters, 'ImageBrightness')
%     GuiGlobalsStruct.MontageParameters.ImageBrightness = SavedMontageParameters.ImageBrightness;
% end
% if isfield(SavedMontageParameters, 'AFStartingWD') %Added 6-26-2013
%     GuiGlobalsStruct.MontageParameters.AFStartingWD = SavedMontageParameters.AFStartingWD;
% end
% if isfield(SavedMontageParameters, 'WDResetThreshold') %Added 6-27-2013
%     GuiGlobalsStruct.MontageParameters.WDResetThreshold = SavedMontageParameters.WDResetThreshold;
% end
% if isfield(SavedMontageParameters, 'StartingStigX') %Added 6-28-2013
%     GuiGlobalsStruct.MontageParameters.StartingStigX = SavedMontageParameters.StartingStigX;
% end
% if isfield(SavedMontageParameters, 'StartingStigY')
%     GuiGlobalsStruct.MontageParameters.StartingStigY = SavedMontageParameters.StartingStigY;
% end
% if isfield(SavedMontageParameters, 'StigResetThreshold')
%     GuiGlobalsStruct.MontageParameters.StigResetThreshold = SavedMontageParameters.StigResetThreshold;
% end
% 
% 
% GuiGlobalsStruct.MontageParameters.MontageOverviewImageFOV_microns = SavedMontageParameters.MontageOverviewImageFOV_microns;
% GuiGlobalsStruct.MontageParameters.MontageOverviewImageWidth_pixels = SavedMontageParameters.MontageOverviewImageWidth_pixels;
% GuiGlobalsStruct.MontageParameters.MontageOverviewImageDwellTime_microseconds = SavedMontageParameters.MontageOverviewImageDwellTime_microseconds;



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
GuiGlobalsStruct.MontageTarget.MicronsPerPixel = GuiGlobalsStruct.MontageParameters.MicronsPerPixel;


UpdateSectionOverviewDisplay(handles);
UpdateSectionOverviewDisplay(handles); %Note: I do not know why this has to be done twice but it does (updates incorrectly if not)

% --------------------------------------------------------------------
function LoadExistingTargetPoint_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadExistingTargetPoint_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediatly after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uigetfile('*.mat', 'Select file to load:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    FileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);

load(FileName, 'SavedMontageTargetPointParameters');

%EXIST('A','var')
if ~exist('SavedMontageTargetPointParameters','var')
    beep;
    uiwait(msgbox('Not a valid TargetPoint file'));
    return;
end

GuiGlobalsStruct.MontageTarget.r = SavedMontageTargetPointParameters.r;
GuiGlobalsStruct.MontageTarget.c = SavedMontageTargetPointParameters.c;
GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons = SavedMontageTargetPointParameters.LowResForAlignWidthInMicrons;
GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons = SavedMontageTargetPointParameters.LowResForAlignHeightInMicrons;
% GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns = SavedMontageTargetPointParameters.AF_X_Offset_Microns;
% GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns = SavedMontageTargetPointParameters.AF_Y_Offset_Microns;

GuiGlobalsStruct.IsDisplayMontageTarget = true;
UpdateSectionOverviewDisplay(handles);

% --------------------------------------------------------------------
function SaveTargetPoint_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveTargetPoint_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

SavedMontageTargetPointParameters.r = GuiGlobalsStruct.MontageTarget.r;
SavedMontageTargetPointParameters.c = GuiGlobalsStruct.MontageTarget.c;
SavedMontageTargetPointParameters.LowResForAlignWidthInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons;
SavedMontageTargetPointParameters.LowResForAlignHeightInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons; 
% SavedMontageTargetPointParameters.AF_X_Offset_Microns = GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns;
% SavedMontageTargetPointParameters.AF_Y_Offset_Microns = GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns;


%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediatly after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uiputfile('*.mat', 'Select file for Save As:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    OutputFileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);

save(OutputFileName, 'SavedMontageTargetPointParameters');


% --------------------------------------------------------------------
function SetupAutoFocusRelativePosition_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SetupAutoFocusRelativePosition_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

defaultAnswer = {num2str(GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns) , num2str(GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns)};
MyAnswer = inputdlg({'AF_X_Offset_Microns','AF_Y_Offset_Microns'},'AutoFocus point offset',1,defaultAnswer);

if ~isempty(MyAnswer) %is empty if user canceled
    MyAnswerNum_1 = str2double(MyAnswer{1}); %NaN if invalid or blank
    MyAnswerNum_2 = str2double(MyAnswer{2}); %NaN if invalid or blank
else
    MyAnswerNum_1 = NaN;
    MyAnswerNum_2 = NaN;
end

if ~( isnan(MyAnswerNum_1) || isnan(MyAnswerNum_2) )
    GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns = MyAnswerNum_1;
    GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns = MyAnswerNum_2;
else
    uiwait(msgbox('Illegal value. Not updating.')) ;
    return
end

UpdateSectionOverviewDisplay(handles);


% --------------------------------------------------------------------
function GenerateXMLFromStackOfImages_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLFromStackOfImages_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GenerateXMLFromStackOfImages();


% --------------------------------------------------------------------
function AcquireMontageStackMain_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireMontageStackMain_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AcquireMontageStack_Main(handles);


% --------------------------------------------------------------------
function Utilities_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to Utilities_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CollectStageStitchedIntoNewDir_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CollectStageStitchedIntoNewDir_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UtilityScript_CollectStageStitchedIntoNewFolder();


% --- Executes on button press in GoToNext_button.
function GoToNext_button_Callback(hObject, eventdata, handles)
% hObject    handle to GoToNext_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;


%First save current position info

Info.StageX_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
Info.StageY_Meters = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
Info.ScanRotation = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');
Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
Info.WorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
Info.Brightness = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
Info.Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
Info.StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
Info.StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');

if ~exist(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory, 'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR)
    disp(sprintf('Creating directory: %s',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory));
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory);
end

ValStr = get(handles.SectionLabel_EditBox,'String');
DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%s.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,ValStr);
save(DataFileNameStr,'Info');
disp(sprintf('Saved %s', DataFileNameStr));

%Then increment section number and go to it
SectionIncrement_Button_Callback(hObject, eventdata, handles); %callin increment button function above

%call function below
GoToCurrent_button_Callback(hObject, eventdata, handles);



function ManuallyCorrectedStagePositionInfo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ManuallyCorrectedStagePositionInfo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ManuallyCorrectedStagePositionInfo_edit as text
%        str2double(get(hObject,'String')) returns contents of ManuallyCorrectedStagePositionInfo_edit as a double


% --- Executes during object creation, after setting all properties.
function ManuallyCorrectedStagePositionInfo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ManuallyCorrectedStagePositionInfo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoToCurrent_button.
function GoToCurrent_button_Callback(hObject, eventdata, handles)
% hObject    handle to GoToCurrent_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

ValStr = get(handles.SectionLabel_EditBox,'String');
DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%s.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,ValStr);

if exist(DataFileNameStr)
    disp(sprintf('Loading %s', DataFileNameStr));
    load(DataFileNameStr,'Info');
    
    
    InfoTextStr = evalc('disp(Info)');
    set(handles.ManuallyCorrectedStagePositionInfo_edit, 'String', InfoTextStr);
    
    StageX_Meters = Info.StageX_Meters;
    StageY_Meters = Info.StageY_Meters;
    stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
    stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
    stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
    stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
    
    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
    disp(MyStr);
    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
        pause(.02)
    end
    wmBackLash
    

    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',Info.ScanRotation);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',Info.WorkingDistance);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_BRIGHTNESS',Info.Brightness);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_CONTRAST',Info.Contrast);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',Info.StigX);
    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',Info.StigY);


else
    InfoTextStr = 'No file. \n Going to open loop position.';
    set(handles.ManuallyCorrectedStagePositionInfo_edit, 'String', InfoTextStr);
    
    GoToMontageTargetPointRotationAndFOV;
end
    


% --------------------------------------------------------------------
function GenerateXMLFromManuallyCorrectedStagePosFiles_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateXMLFromManuallyCorrectedStagePosFiles_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GenerateXMLFromManuallyCorrectedStagePosFiles();


% --------------------------------------------------------------------
function GoToStagePosition_ToolbarButton_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to GoToStagePosition_ToolbarButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in GoToSectionCenter_pushbutton.
function GoToSectionCenter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToSectionCenter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsIncrement = false;
IsSave = false;
IsActualMove = true;
GoToSection_HelperFunction(handles, IsIncrement, IsSave, IsActualMove);


function SectionNumberForQuickManualTargeting_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to SectionNumberForQuickManualTargeting_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionNumberForQuickManualTargeting_EditBox as text
%        str2double(get(hObject,'String')) returns contents of SectionNumberForQuickManualTargeting_EditBox as a double


% --- Executes during object creation, after setting all properties.
function SectionNumberForQuickManualTargeting_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionNumberForQuickManualTargeting_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoToNextSectionCenter_pushbutton.
function GoToNextSectionCenter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToNextSectionCenter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsIncrement = true;
IsSave = false;
IsActualMove = true;
GoToSection_HelperFunction(handles, IsIncrement, IsSave, IsActualMove);


% --- Executes on button press in SaveAndGoToNextSectionCenter_pushbutton.
function SaveAndGoToNextSectionCenter_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAndGoToNextSectionCenter_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsIncrement = true;
IsSave = true;
IsActualMove = true;
GoToSection_HelperFunction(handles, IsIncrement, IsSave, IsActualMove);


% --- Executes on button press in StagePlay_button.
function StagePlay_button_Callback(hObject, eventdata, handles)
% hObject    handle to StagePlay_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.IsStopStagePlay = false;

IsSuccessfulMove = true;

while(IsSuccessfulMove && ~GuiGlobalsStruct.IsStopStagePlay)
    IsIncrement = true;
    IsSave = false;
    IsActualMove = true;
    [IsSuccessfulMove] = GoToSection_HelperFunction(handles, IsIncrement, IsSave , IsActualMove);
    pause(0.5);
end


% --- Executes on button press in StopStagePlay_button.
function StopStagePlay_button_Callback(hObject, eventdata, handles)
% hObject    handle to StopStagePlay_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

GuiGlobalsStruct.IsStopStagePlay = true;


% --- Executes on button press in GeneratePositionsFrom_button.
function GeneratePositionsFrom_button_Callback(hObject, eventdata, handles)
% hObject    handle to GeneratePositionsFrom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
%Make sure the TempImagesDirectory is back to its default (this is changed
%when taking a montage stack
GuiGlobalsStruct.TempImagesDirectory = sprintf('%s\\TempImagesDirectory',GuiGlobalsStruct.WaferDirectory);

GenerateManuallyCorrectedStagePositionsFromVarious();



function AlignedTargetOffset_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to AlignedTargetOffset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AlignedTargetOffset_EditBox as text
%        str2double(get(hObject,'String')) returns contents of AlignedTargetOffset_EditBox as a double


% --- Executes during object creation, after setting all properties.
function AlignedTargetOffset_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlignedTargetOffset_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function GoToFirstFiducialAndManuallySetCoarseOffset_Callback(hObject, eventdata, handles)
% hObject    handle to GoToFirstFiducialAndManuallySetCoarseOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
GoToFirstFiducial(GuiGlobalsStruct.LowResFiducialsDirectory);


% --------------------------------------------------------------------
function FreeViewWithOffset_MenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to FreeViewWithOffset_MenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%code to correct for offset between sigma and merlin mapped wafers
if isfield(GuiGlobalsStruct, 'StageOffsetForLowResFiducialTaking_X_Meters')
    StageOffsetForLowResFiducialTaking_X_Meters = GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_X_Meters;
    StageOffsetForLowResFiducialTaking_Y_Meters = GuiGlobalsStruct.StageOffsetForLowResFiducialTaking_Y_Meters;
else
    StageOffsetForLowResFiducialTaking_X_Meters = 0;
    StageOffsetForLowResFiducialTaking_Y_Meters = 0;
end


%TempCopy_IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
GuiGlobalsStruct.IsUseStageCorrection = false;
NavigateFullWaferMap;
%GuiGlobalsStruct.IsUseStageCorrection = TempCopy_IsUseStageCorrection;


% --- Executes on button press in killSwitch_pushbutton.
function killSwitch_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to killSwitch_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return
