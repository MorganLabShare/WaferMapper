function varargout = selectTilesGUI(varargin)
% SELECTTILESGUI MATLAB code for selectTilesGUI.fig
%      SELECTTILESGUI, by itself, creates a new SELECTTILESGUI or raises the existing
%      singleton*.
%
%      H = SELECTTILESGUI returns the handle to a new SELECTTILESGUI or the handle to
%      the existing singleton*.
%
%      SELECTTILESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTTILESGUI.M with the given input arguments.
%
%      SELECTTILESGUI('Property','Value',...) creates a new SELECTTILESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectTilesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectTilesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectTilesGUI

% Last Modified by GUIDE v2.5 20-Dec-2017 12:04:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @selectTilesGUI_OpeningFcn, ...
    'gui_OutputFcn',  @selectTilesGUI_OutputFcn, ...
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


% --- Executes just before selectTilesGUI is made visible.
function selectTilesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectTilesGUI (see VARARGIN)

% Choose default command line output for selectTilesGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectTilesGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


global GuiGlobalsStruct
clear selectTiles
% GuiGlobalsStruct.MontageParameters.allTiles = selectTiles.solidTiles(selectTiles.useTiles,:);



% --- Outputs from this function are returned to the command line.
function varargout = selectTilesGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global GuiGlobalsStruct


NumRowTiles = GuiGlobalsStruct.MontageParameters.NumberOfTileRows;
NumColTiles =  GuiGlobalsStruct.MontageParameters.NumberOfTileCols;
ch = checkerboard(1,max(NumRowTiles,NumColTiles))
field = ch(1:NumRowTiles,1:NumColTiles)*20+120;

fieldGrey = uint8(cat(3,field,field,field));

selectTiles.fieldGrey = fieldGrey;
[y x] = find(field+100);
solidTiles = [y x];
selectTiles.solidTiles = solidTiles;


if isfield(GuiGlobalsStruct.MontageParameters,'allTiles')
    
    allTiles = GuiGlobalsStruct.MontageParameters.allTiles;
    %allTiles(:,1) = max(solidTiles(:,1)) - allTiles(:,1) + 1;
else
    allTiles = solidTiles;
end

try tileInd = sub2ind([NumRowTiles NumColTiles],allTiles(:,1),allTiles(:,2));
catch err
    tileInd = 1:length(y);
end

selectTiles.useTiles = y*0;
selectTiles.useTiles(tileInd) = 1;

GuiGlobalsStruct.MontageParameters.selectTiles = selectTiles;
drawField(handles);
UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
figure(handles.figure1)






% --- Executes on button press in pushbutton_remove.
function pushbutton_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GuiGlobalsStruct

selectTiles = GuiGlobalsStruct.MontageParameters.selectTiles;
drawField(handles)

[x y] = ginput(1);
x = round(x); y = round(y);
selectTiles.useTiles((selectTiles.solidTiles(:,2) == x) & (selectTiles.solidTiles(:,1) == y)) = 0;
GuiGlobalsStruct.MontageParameters.selectTiles = selectTiles;
drawField(handles);
UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
figure(handles.figure1)


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GuiGlobalsStruct

selectTiles = GuiGlobalsStruct.MontageParameters.selectTiles;
drawField(handles)

[x y] = ginput(1);
x = round(x); y = round(y);
selectTiles.useTiles((selectTiles.solidTiles(:,2) == x) & (selectTiles.solidTiles(:,1) == y)) = 1;
GuiGlobalsStruct.MontageParameters.selectTiles = selectTiles;
drawField(handles);
UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
figure(handles.figure1)


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GuiGlobalsStruct 

close(gcf)

function drawField(handles)
global GuiGlobalsStruct

selectTiles = GuiGlobalsStruct.MontageParameters.selectTiles;

%set(handles.figure1,'visible','on');
figure(handles.figure1)

solidTiles = selectTiles.solidTiles;

hold off
image(selectTiles.fieldGrey)
axis off
hold on

maxDiv = max(solidTiles(:))/3;

for i = 1:length(selectTiles.useTiles)
    x = solidTiles(i,2);
    y = solidTiles(i,1);
    if selectTiles.useTiles(i)
        scatter(x,y,'sizedata',2000/maxDiv,'marker','s','markerfacecolor',[0 1 0],'markerfacealpha',.3)
    else
        scatter(x,y,'sizedata',2000/maxDiv,'marker','x','markerfacecolor',[1 0 0],'markerfacealpha',.3, ...
            'linewidth',10/maxDiv,'markeredgecolor',[1 0 0])
    end
end

allTiles = selectTiles.solidTiles(selectTiles.useTiles>0,:);
%allTiles(:,1) = max(solidTiles(:,1))- allTiles(:,1) + 1;
GuiGlobalsStruct.MontageParameters.allTiles = allTiles;

hold off


% --- Executes on button press in pushbutton_none.
function pushbutton_none_Callback(hObject, eventdata, handles)

global GuiGlobalsStruct

GuiGlobalsStruct.MontageParameters.selectTiles.useTiles = GuiGlobalsStruct.MontageParameters.selectTiles.useTiles * 0;
drawField(handles);
UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
figure(handles.figure1)


% --- Executes on button press in pushbutton_all.
function pushbutton_all_Callback(hObject, eventdata, handles)

global GuiGlobalsStruct

GuiGlobalsStruct.MontageParameters.selectTiles.useTiles = GuiGlobalsStruct.MontageParameters.selectTiles.useTiles * 0 +1;

drawField(handles);
UpdateSectionOverviewDisplay(GuiGlobalsStruct.handles_FromWaferMapper);
figure(handles.figure1)













