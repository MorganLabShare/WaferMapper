function varargout = ProcessOverviewsRobustRigidParameters2(varargin)
% PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2 MATLAB code for ProcessOverviewsRobustRigidParameters2.fig
%      PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2, by itself, creates a new PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2 or raises the existing
%      singleton*.
%
%      H = PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2 returns the handle to a new PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2 or the handle to
%      the existing singleton*.
%
%      PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2.M with the given input arguments.
%
%      PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2('Property','Value',...) creates a new PROCESSOVERVIEWSROBUSTRIGIDPARAMETERS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcessOverviewsRobustRigidParameters2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcessOverviewsRobustRigidParameters2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcessOverviewsRobustRigidParameters2

% Last Modified by GUIDE v2.5 26-Jul-2013 16:45:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcessOverviewsRobustRigidParameters2_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcessOverviewsRobustRigidParameters2_OutputFcn, ...
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


% --- Executes just before ProcessOverviewsRobustRigidParameters2 is made visible.
function ProcessOverviewsRobustRigidParameters2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProcessOverviewsRobustRigidParameters2 (see VARARGIN)

% Choose default command line output for ProcessOverviewsRobustRigidParameters2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProcessOverviewsRobustRigidParameters2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
UpdateAllFields(handles);


function UpdateAllFields(handles)
global GuiGlobalsStruct;
filestruct = dir([GuiGlobalsStruct.SectionOverviewsDirectory '\*.tif']);
numsections=length(filestruct);
set(handles.slider1,'Max',numsections);
set(handles.slider1,'SliderStep',[1/numsections 5/numsections]);
set(handles.slider2,'Max',numsections);
set(handles.slider2,'SliderStep',[1/numsections 5/numsections]);

% --- Outputs from this function are returned to the command line.
function varargout = ProcessOverviewsRobustRigidParameters2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in EnhanceConstrast_CheckBox.
function EnhanceConstrast_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to EnhanceConstrast_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnhanceConstrast_CheckBox



function InitialDownsample_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to InitialDownsample_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InitialDownsample_EditBox as text
%        str2double(get(hObject,'String')) returns contents of InitialDownsample_EditBox as a double


% --- Executes during object creation, after setting all properties.
function InitialDownsample_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InitialDownsample_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.




function Octaves_EditBox_Callback(hObject, eventdata, handles)








function Octaves_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumOctaves_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Threshhold_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to Threshhold_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshhold_EditBox as text
%        str2double(get(hObject,'String')) returns contents of Threshhold_EditBox as a double


% --- Executes during object creation, after setting all properties.
function Threshhold_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshhold_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CenterFraction_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to CenterFraction_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CenterFraction_EditBox as text
%        str2double(get(hObject,'String')) returns contents of CenterFraction_EditBox as a double


% --- Executes during object creation, after setting all properties.
function CenterFraction_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CenterFraction_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MedianFilter_CheckBox.
function MedianFilter_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to MedianFilter_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MedianFilter_CheckBox



function MinVal_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to MinVal_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinVal_EditBox as text
%        str2double(get(hObject,'String')) returns contents of MinVal_EditBox as a double


% --- Executes during object creation, after setting all properties.
function MinVal_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinVal_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxVal_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to MaxVal_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxVal_EditBox as text
%        str2double(get(hObject,'String')) returns contents of MaxVal_EditBox as a double


% --- Executes during object creation, after setting all properties.
function MaxVal_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxVal_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PixRadius_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to PixRadius_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixRadius_EditBox as text
%        str2double(get(hObject,'String')) returns contents of PixRadius_EditBox as a double


% --- Executes during object creation, after setting all properties.
function PixRadius_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixRadius_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DistThresh_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to DistThresh_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DistThresh_EditBox as text
%        str2double(get(hObject,'String')) returns contents of DistThresh_EditBox as a double


% --- Executes during object creation, after setting all properties.
function DistThresh_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DistThresh_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NBest_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to NBest_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NBest_EditBox as text
%        str2double(get(hObject,'String')) returns contents of NBest_EditBox as a double


% --- Executes during object creation, after setting all properties.
function NBest_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NBest_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinInliers_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to MinInliers_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinInliers_EditBox as text
%        str2double(get(hObject,'String')) returns contents of MinInliers_EditBox as a double


% --- Executes during object creation, after setting all properties.
function MinInliers_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinInliers_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Delta_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to Delta_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Delta_EditBox as text
%        str2double(get(hObject,'String')) returns contents of Delta_EditBox as a double


% --- Executes during object creation, after setting all properties.
function Delta_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Delta_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Lambda_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to Lambda_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lambda_EditBox as text
%        str2double(get(hObject,'String')) returns contents of Lambda_EditBox as a double


% --- Executes during object creation, after setting all properties.
function Lambda_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lambda_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeSteps_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSteps_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeSteps_EditBox as text
%        str2double(get(hObject,'String')) returns contents of TimeSteps_EditBox as a double


% --- Executes during object creation, after setting all properties.
function TimeSteps_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSteps_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDetChange_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDetChange_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDetChange_EditBox as text
%        str2double(get(hObject,'String')) returns contents of MaxDetChange_EditBox as a double


% --- Executes during object creation, after setting all properties.
function MaxDetChange_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDetChange_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value=get(hObject,'Value');
set(hObject,'Value',round(value));
set(handles.Section1_EditBox,'String',num2str(int8(round(value))));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value=get(hObject,'Value');
set(hObject,'Value',round(value));
set(handles.Section2_EditBox,'String',num2str(int8(round(value))));


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Section1_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to Section1_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Section1_EditBox as text
%        str2double(get(hObject,'String')) returns contents of Section1_EditBox as a double


% --- Executes during object creation, after setting all properties.
function Section1_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Section1_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Section2_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to Section2_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Section2_EditBox as text
%        str2double(get(hObject,'String')) returns contents of Section2_EditBox as a double


% --- Executes during object creation, after setting all properties.
function Section2_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Section2_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [I1,I2]=readUserSelectedImages(handles)
global GuiGlobalsStruct;
%get the list of files and directories
SURFOptions=GetSURFOptionsFromHandles(handles);
[Files,MatFiles,labels]=GetSortedImagesAndMatfiles(GuiGlobalsStruct.SectionOverviewsDirectory);

%pull out which sections the user has chosen
sect1=round(str2double(get(handles.Section1_EditBox,'String')));
sect2=round(str2double(get(handles.Section2_EditBox,'String')));

%calculate the Pixel region corresponding to the given center_fraction
PixelRegion=DefinePixelRegionFromCenterFrac(Files{1},SURFOptions.center_frac);

I1=imread(Files{sect1},'PixelRegion',PixelRegion);
I2=imread(Files{sect2},'PixelRegion',PixelRegion);

% --- Executes on button press in TestSURF_Button.
function TestSURF_Button_Callback(hObject, eventdata, handles)
% hObject    handle to TestSURF_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%pull out the SURF options from the GUI
SURFOptions=GetSURFOptionsFromHandles(handles);

%read in images user selected (pulling out center_frac inside function)
[I1,I2]=readUserSelectedImages(handles);

%extract the SURF points
p1=OpenSurf(I1,SURFOptions);
p2=OpenSurf(I2,SURFOptions);

%update GUI with the number of points
set(handles.NumPtsIn1_Text,'String',sprintf('# pts in 1: %d',length(p1)));
set(handles.NumPtsIn2_Text,'String',sprintf('# pts in 2: %d',length(p2)));

%plot out the results
%shift the points for image 2 right by the width of image 1
for j=1:length(p2)
    p2(j).x=p2(j).x+size(I1,2);
end

%make a concatenated image
I = zeros([size(I1,1) size(I1,2)*2 size(I1,3)],'double');
I(:,1:size(I1,2),:)=double(I1);
I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=double(I2);
I=I/255.0;
%select main axes and make sure whatever comes next overwrites what is
%there
axes(handles.MainAxes);
hold off;
%user a modified version of OpenSurf's function to plot points
PaintSURF_modified(I,[p1 p2]);
hold on;
%draw a vertical line to seperate two images
line([size(I1,2) size(I1,2)],[1 size(I1,1)]);


function Options=GetSURFOptionsFromHandles(handles)
% handles    structure with handles and user data (see GUIDATA)
Options.verbose=0; %whether to produce a verbose output for debugging
Options.init_sample=round(str2double(get(handles.InitialDownsample_EditBox,'String')));
Options.octaves=round(str2double(get(handles.Octaves_EditBox,'String'))); %how many octaves of upsampling to try
Options.tresh=str2double(get(handles.Threshhold_EditBox,'String')); %what threshold to use (lower for more features, raise for fewer)
Options.center_frac=str2double(get(handles.CenterFraction_EditBox,'String'));

function Options=GetRanSacOptionsFromHandles(handles)
% handles    structure with handles and user data (see GUIDATA)
Options.verbose=0; %whether to produce a verbose output for debugging
Options.dist_thresh=str2double(get(handles.DistThresh_EditBox,'String'));
Options.NBest=round(str2double(get(handles.NBest_EditBox,'String'))); %how many octaves of upsampling to try
Options.Model=get(get(handles.Model_Panel,'SelectedObject'),'Tag'); %what threshold to use (lower for more features, raise for fewer)
Options.MaxDetChange=str2double(get(handles.MaxDetChange_EditBox,'String'));

% --- Executes on button press in TestRanSac_Button.
function TestRanSac_Button_Callback(hObject, eventdata, handles)
% hObject    handle to TestRanSac_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;


%get the SURF and RANSAC options from the user
SURFOptions=GetSURFOptionsFromHandles(handles);
RanSacOptions=GetRanSacOptionsFromHandles(handles);
tic
%read in images user selected (pulling out center_frac inside function)
[I1,I2]=readUserSelectedImages(handles);

%extract the SURF features
p1=OpenSurf(I1,SURFOptions);
p2=OpenSurf(I2,SURFOptions);
t1=toc; %time after reading both images and calculating surf points
%find the best correspondances between the two images
[Pos1,Pos2]=find_best_SURF_match(p1,p2,RanSacOptions.NBest);

%setup the ransac options
ransacCoef.minPtNum=2;   %for a rigid or similarity transform 2 is the number needed
ransacCoef.iterNum= round(.25*nchoosek(size(Pos1,1),2)); %run through a number of iterations equal to the number of points
ransacCoef.thDist= RanSacOptions.dist_thresh*size(I1,1); %should be within 20 microns to be right
ransacCoef.thInlrRatio=.02; %at least 5 percent should be right
ransacCoef.thDet=RanSacOptions.MaxDetChange;

%run Ransac
[f inlierIdx] = ransac1( flipdim(Pos1',1),flipdim(Pos2',1),ransacCoef,@fit_rigid,@EuclideanDistance,@getDeterminantOfAffineTransform);
M=f.tdata.T(1:2,1:2);
t2=toc;%time after running ransac



%update GUI with information on SURF points and inliers after ransac
set(handles.NumInliers_Text,'String',sprintf('NumInliers: %d',length(inlierIdx)));
set(handles.NumPtsIn1_Text,'String',sprintf('# pts in 1: %d',length(p1)));
set(handles.NumPtsIn2_Text,'String',sprintf('# pts in 2: %d',length(p2)));
set(handles.Determinant_Text','String',sprintf('Determinant^.5: %3.2f',sqrt(det(M))));
readSURFtime=t1/2;
ransactime=t2-t1;
numsections=get(handles.slider1,'Max');
numadjacent=round(str2double(get(handles.NumAdjacent_EditBox,'String')));
numlong=round(str2double(get(handles.LongRangeN_EditBox,'String')));

totaltime_sec=readSURFtime*numsections+numadjacent*numsections+numlong*numsections;
totaltime_min=totaltime_sec/60;
if totaltime_min<120
    set(handles.EstTime_Text,'String',sprintf('Estimated Total Time:%3.2f min',totaltime_min));
else
    set(handles.EstTime_Text,'String',sprintf('Estimated Total Time:%3.2f hrs',totaltime_min/60));
end

%plot the correspondances in the MainAxes
axes(handles.MainAxes);
hold off;
PlotCorrespondances(I1,I2,Pos1,Pos2,inlierIdx)


function NumAdjacent_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to NumAdjacent_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumAdjacent_EditBox as text
%        str2double(get(hObject,'String')) returns contents of NumAdjacent_EditBox as a double


% --- Executes during object creation, after setting all properties.
function NumAdjacent_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumAdjacent_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LongRangeDelta_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to LongRangeDelta_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LongRangeDelta_EditBox as text
%        str2double(get(hObject,'String')) returns contents of LongRangeDelta_EditBox as a double


% --- Executes during object creation, after setting all properties.
function LongRangeDelta_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LongRangeDelta_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LongRangeN_EditBox_Callback(hObject, eventdata, handles)
% hObject    handle to LongRangeN_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LongRangeN_EditBox as text
%        str2double(get(hObject,'String')) returns contents of LongRangeN_EditBox as a double


% --- Executes during object creation, after setting all properties.
function LongRangeN_EditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LongRangeN_EditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
