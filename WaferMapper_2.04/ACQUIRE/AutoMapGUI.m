function varargout = AutoMapGUI(varargin)
% AUTOMAPGUI MATLAB code for AutoMapGUI.fig
%      AUTOMAPGUI, by itself, creates a new AUTOMAPGUI or raises the existing
%      singleton*.
%
%      H = AUTOMAPGUI returns the handle to a new AUTOMAPGUI or the handle to
%      the existing singleton*.
%
%      AUTOMAPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOMAPGUI.M with the given input arguments.
%
%      AUTOMAPGUI('Property','Value',...) creates a new AUTOMAPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AutoMapGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AutoMapGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AutoMapGUI

% Last Modified by GUIDE v2.5 26-May-2011 18:24:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AutoMapGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AutoMapGUI_OutputFcn, ...
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


% --- Executes just before AutoMapGUI is made visible.
function AutoMapGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AutoMapGUI (see VARARGIN)

% Choose default command line output for AutoMapGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AutoMapGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global GuiGlobalsStruct;
global AutoMapGUIGlobals;

if isfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_xlim')
    AutoMapGUIGlobals = rmfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_xlim');   
    AutoMapGUIGlobals = rmfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_ylim');   
end

set(handles.slider_SectionDetectThreshold, 'Min', .1);
set(handles.slider_SectionDetectThreshold, 'Max', 1);
set(handles.slider_SectionDetectThreshold, 'Value', .8);
GuiGlobalsStruct.SectionDetectThreshold = get(handles.slider_SectionDetectThreshold,'Value');
set(handles.editbox_SectionDetectThreshold, 'String', num2str(GuiGlobalsStruct.SectionDetectThreshold));

%load Full wafer map image and apply light filtering
FullWaferImageFileNameStr = sprintf('%s\\FullMapImage.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
MyStr = sprintf('Loading image file: %s',FullWaferImageFileNameStr);
FullMapImage = imread(FullWaferImageFileNameStr,'tif');
%H_gaussian = fspecial('gaussian',[7 7],3); %fspecial('gaussian',[5 5],1.5);
%FullMapImage = imfilter(FullMapImage,H_gaussian);
GuiGlobalsStruct.FullMapImage = FullMapImage;
axes(handles.axes_FullMapDisplay);
imshow(GuiGlobalsStruct.FullMapImage,[0,255]);

%load example section image and apply light filtering



if isfield(GuiGlobalsStruct, 'ExampleSectionImageDirectory')
    SubImageForTemplateFileNameStr = sprintf('%s\\ExampleSectionImageCropped.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
    if exist(SubImageForTemplateFileNameStr, 'file')
        
        SubImageForTemplate = imread(SubImageForTemplateFileNameStr,'tif');
        %SubImageForTemplate = imfilter(SubImageForTemplate,H_gaussian);
        GuiGlobalsStruct.SubImageForTemplate = SubImageForTemplate;
        % axes(handles.axes_ImageDisplay);
        % imshow(GuiGlobalsStruct.SubImageForTemplate,[0,255]);
        
        %%%%%%%%%%
        %load Full wafer map thresholded image
        FullMapImage_Thresholded_FileNameStr = sprintf('%s\\FullMapImage_Thresholded.tif',GuiGlobalsStruct.FullWaferTileImagesDirectory);
        MyStr = sprintf('Loading image file: %s',FullMapImage_Thresholded_FileNameStr);
        FullMapImage_Thresholded = imread(FullMapImage_Thresholded_FileNameStr,'tif');
        
        %load example section thresholded image
        ExampleSectionImage_Thresholded_FileNameStr = sprintf('%s\\ExampleSectionImage_Thresholded.tif',GuiGlobalsStruct.ExampleSectionImageDirectory);
        MyStr = sprintf('Loading image file: %s',ExampleSectionImage_Thresholded_FileNameStr);
        ExampleSectionImage_Thresholded = imread(ExampleSectionImage_Thresholded_FileNameStr,'tif');
        
        
        
        %%%%%%%%%%%
        
        
        %Make smaller images for actaul convolutions
        DownSampleFactor = GuiGlobalsStruct.FullMapData.DownsampleFactor;
        FurtherDownSampleFactor_ForCoarseMatch = GuiGlobalsStruct.WaferParameters.AutoMapFurtherDownsampleFactor; %2;
        GuiGlobalsStruct.FurtherDownSampleFactor_ForCoarseMatch = FurtherDownSampleFactor_ForCoarseMatch; %needed in other function
        %First reduce images to coarse level
        GuiGlobalsStruct.SubImageForAreaToMatch = imresize(FullMapImage_Thresholded,1/FurtherDownSampleFactor_ForCoarseMatch);
        GuiGlobalsStruct.SubImageForTemplate = imresize(ExampleSectionImage_Thresholded,(1/DownSampleFactor)*(1/FurtherDownSampleFactor_ForCoarseMatch)); %Note: the FullMapImage was
        %already scaled down by DownSampleFactor
        
        %Perform actual convolution here and display in separate window (must be in
        %separate figure because axes do not have independent Colormap property
        PerformFullWaferConvolution;
        axes(handles.axes_FullMapDisplay);
        imshow(GuiGlobalsStruct.FullMapImage,[0,255]);

        %imshow(GuiGlobalsStruct.C_ValidRegion_ArrayOfMax);
        colorbar;
        
        
        
        MyStr = sprintf('Vary the Section Detection Threshold slider until red dots appear on all sections with no spurious detections.\n Then click ''Show Found Sections'' button');
        uiwait(msgbox(MyStr, 'modal'));
        
    else %assume this is just optical or something and just go to pick step
        %gray out the ShowFoundSections_Button button
        set(handles.ShowFoundSections_Button, 'Enable', 'off');
    end
else
    %gray out the ShowFoundSections_Button button
    set(handles.ShowFoundSections_Button, 'Enable', 'off');
end
    


% --- Outputs from this function are returned to the command line.
function varargout = AutoMapGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






% --- Executes on slider movement.
function slider_SectionDetectThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to slider_SectionDetectThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global GuiGlobalsStruct;
GuiGlobalsStruct.SectionDetectThreshold = get(hObject,'Value');
set(handles.editbox_SectionDetectThreshold, 'String', num2str(GuiGlobalsStruct.SectionDetectThreshold));

% axes(handles.axes_ImageDisplay);
% cla;

axes(handles.axes_FullMapDisplay);

Iraw = GuiGlobalsStruct.FullMapImage;
I = GuiGlobalsStruct.C_ValidRegion_ArrayOfMax;
Iraw = imresize(Iraw,size(I));


Ired = Iraw;
Ired(I>=GuiGlobalsStruct.SectionDetectThreshold) = 256;
Iraw(I>=GuiGlobalsStruct.SectionDetectThreshold) = 0;
Icol = uint8(cat(3,Ired,Iraw,Iraw));
imshow(Icol);

colorbar;



% --- Executes during object creation, after setting all properties.
function slider_SectionDetectThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_SectionDetectThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editbox_SectionDetectThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editbox_SectionDetectThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editbox_SectionDetectThreshold as text
%        str2double(get(hObject,'String')) returns contents of editbox_SectionDetectThreshold as a double


% --- Executes during object creation, after setting all properties.
function editbox_SectionDetectThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbox_SectionDetectThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowFoundSections_Button.
function ShowFoundSections_Button_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFoundSections_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AutoMapGUIGlobals;

MyStr = 'Press OK to start finding sections. Press ''esc'' top break.';
uiwait(msgbox(MyStr));

set(handles.AddDeleteSections_Button,'enable','off');
set(handles.AutoNumberSections_Button,'enable','off');
set(handles.SaveSectionList_Button,'enable','off');

if isfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_xlim')
    AutoMapGUIGlobals = rmfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_xlim');   
    AutoMapGUIGlobals = rmfield(AutoMapGUIGlobals, 'axes_FullMapDisplay_ylim');   
end

%clear CoarseSectionList and FullMapDisplay
GuiGlobalsStruct.CoarseSectionList = []; %blank this out
axes(handles.axes_FullMapDisplay);
cla;
imshow(GuiGlobalsStruct.FullMapImage,[0,255]);


C_ValidRegion_ArrayOfMax_FullMapScale = imresize(GuiGlobalsStruct.C_ValidRegion_ArrayOfMax, GuiGlobalsStruct.FurtherDownSampleFactor_ForCoarseMatch);

[BestMatchMax, imax] = max(C_ValidRegion_ArrayOfMax_FullMapScale(:));

%Zero out edges of this map because it will crash below if it finds a
%section too close to the edge
[RR,CC] = size(GuiGlobalsStruct.SubImageForTemplate);
RR = RR*GuiGlobalsStruct.FurtherDownSampleFactor_ForCoarseMatch;
CC = CC*GuiGlobalsStruct.FurtherDownSampleFactor_ForCoarseMatch;

C_ValidRegion_ArrayOfMax_FullMapScale(1:(RR/2)+1, :) = 0;
C_ValidRegion_ArrayOfMax_FullMapScale(end-((RR/2)+1):end, :) = 0;
C_ValidRegion_ArrayOfMax_FullMapScale(:, 1:(CC/2)+1) = 0;
C_ValidRegion_ArrayOfMax_FullMapScale(:, end-((CC/2)+1):end) = 0;

IsStillMoreSectionsToFind = true;
i = 0;
GuiGlobalsStruct.LastKeyPressed = ' ';
while IsStillMoreSectionsToFind
    i = i + 1;
    
    
    %allow user break
    if strcmp(GuiGlobalsStruct.LastKeyPressed, 'escape')
        break;
    end
    
    
     %Pick out the row col of the peak
    [MyMax, imax] = max(C_ValidRegion_ArrayOfMax_FullMapScale(:));
    [rpeak, cpeak] = ind2sub(size(C_ValidRegion_ArrayOfMax_FullMapScale),imax(1));

    %Zero out a region around this peak the size of the SubImageForTemplate
    
    C_ValidRegion_ArrayOfMax_FullMapScale((rpeak-(RR/2):rpeak+(RR/2)), (cpeak-(CC/2):cpeak+(CC/2)) ) = 0; 
    
    
    MatchPercentOfMax = 100*(MyMax); %Original: 100*(MyMax/BestMatchMax);
    if MatchPercentOfMax < 100*GuiGlobalsStruct.SectionDetectThreshold %80  %Set cutoff for auto detection of sections at 80%
        IsStillMoreSectionsToFind = false;
    else
        
        GuiGlobalsStruct.CoarseSectionList(i).rpeak = rpeak;
        GuiGlobalsStruct.CoarseSectionList(i).cpeak = cpeak;
        GuiGlobalsStruct.CoarseSectionList(i).Label = '';
        GuiGlobalsStruct.CoarseSectionList(i).IsDeleted = false; %sections are never deleted just marked as such and not displayed
        
       
    
        axes(handles.axes_FullMapDisplay);
        
 
        
        
        h1 = line([cpeak-20, cpeak+20],[rpeak, rpeak]);
        h2 = line([cpeak, cpeak],[rpeak-20, rpeak+20]);
        set(h1,'Color',[1 0 0]);
        set(h2,'Color',[1 0 0]);
        pause(.05); %to allow escape key check
    end
end



set(handles.AddDeleteSections_Button,'enable','on');
set(handles.AutoNumberSections_Button,'enable','on');
set(handles.SaveSectionList_Button,'enable','on');

MyStr = 'Completed finding sections.';
uiwait(msgbox(MyStr));

% --- Executes on button press in AddDeleteSections_Button.
function AddDeleteSections_Button_Callback(hObject, eventdata, handles)
% hObject    handle to AddDeleteSections_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AutoMapGUIGlobals;

MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
if MyVal == 1
    IsDisplayCrosshairsAndLabels = true;
else
    IsDisplayCrosshairsAndLabels = false;
end

RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);


MyStr = sprintf('LEFT click to ADD section \n RIGHT click to zoom in at mouse point\n press ''X'' to zoom out\n  MIDDLE click to DELETE section \n press ''S'' to do a stage movement to point \n press ''L'' to relabel section\n press ''Z'' to zoom in to 3X3 image  \n Press ''Esc'' to go on to next step');
uiwait(msgbox(MyStr,'modal'));

NativePixelWidth_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageWidthInPixels;
NativePixelHeight_mm = (GuiGlobalsStruct.FullMapData.TileFOV_microns/1000)/GuiGlobalsStruct.FullMapData.ImageHeightInPixels;



axes(handles.axes_FullMapDisplay);
while(1)
    
    
    [x_mouse, y_mouse, button] = ginput(1)
    
    %disp(sprintf('button = %d', button));
    
    if button == 27 %'Esc'
        break;
    end
    
    if button == 115 %'s' %stage movment to poisiton to check out
        DownSamplePixelWidth_mm = NativePixelWidth_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        DownSamplePixelHeight_mm = NativePixelHeight_mm*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        
        
        X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - x_mouse*DownSamplePixelWidth_mm
        Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + y_mouse*DownSamplePixelHeight_mm
        
        StageX_Meters = X_Stage_mm/1000;
        StageY_Meters = Y_Stage_mm/1000;
        
        if isfield(GuiGlobalsStruct, 'MyCZEMAPIClass')
            
            disp('Getting stage position');
            stage_x = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
            stage_y = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
            stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
            stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
            stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
            stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
            MyStr = sprintf('Stage Position(x,y,z,t,r,m) = (%0.7g, %0.7g, %0.7g, %0.7g, %0.7g, %0.7g, )'...
                ,stage_x,stage_y,stage_z,stage_t,stage_r, stage_m);
            disp(MyStr);
            disp(' ');
            
            %*** Do stage correction here if requested
            if GuiGlobalsStruct.IsUseStageCorrection
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
            end
            
            
            MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
            disp(MyStr);
            GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
            while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                pause(.02)
            end
            wmBackLash
            
        end
        
    end
    
    if button == 3 % right click zoon in

        %axes_FullMapDisplay_xlim: [0.5000 2.1255e+003]
        %axes_FullMapDisplay_ylim: [0.5000 2.6255e+003]
        set(handles.axes_FullMapDisplay, 'xlim', [x_mouse-400, x_mouse+400]);
        set(handles.axes_FullMapDisplay, 'ylim', [y_mouse-400, y_mouse+400]);
        
        AutoMapGUIGlobals.axes_FullMapDisplay_xlim = get(handles.axes_FullMapDisplay, 'xlim');
        AutoMapGUIGlobals.axes_FullMapDisplay_ylim = get(handles.axes_FullMapDisplay, 'ylim');
    end
    
    if button == 120 %'x' zoom to full
        [ymax, xmax] = size(GuiGlobalsStruct.FullMapImage);
        set(handles.axes_FullMapDisplay, 'xlim', [0.5, xmax]);
        set(handles.axes_FullMapDisplay, 'ylim', [0.5, ymax]);
        AutoMapGUIGlobals.axes_FullMapDisplay_xlim = get(handles.axes_FullMapDisplay, 'xlim');
        AutoMapGUIGlobals.axes_FullMapDisplay_ylim = get(handles.axes_FullMapDisplay, 'ylim');
    end
    
    %Add new section
    if (button == 1) || (button == 122) %left mouse click means add section, 'z' means zoom in to 3x3 before add section
        IsAbort = false;
        if (button == 122)
            
            Mouse_r_IndexInFullMap = y_mouse*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            Mouse_c_IndexInFullMap = x_mouse*GuiGlobalsStruct.FullMapData.DownsampleFactor;
            
            Mouse_TileR = 1+floor(Mouse_r_IndexInFullMap/GuiGlobalsStruct.FullMapData.ImageHeightInPixels);
            Mouse_TileC = 1+floor(Mouse_c_IndexInFullMap/GuiGlobalsStruct.FullMapData.ImageWidthInPixels);
        
            %determine which tile R,C the user clicked in
            AccumulatorImage3x3 = Read3x3TileImages(Mouse_TileR, Mouse_TileC);
            h_3x3fig = figure();
            
            
            imshow(AccumulatorImage3x3,[0,255]);
            set(h_3x3fig, 'Position', get(0,'Screensize')); %This maximizes the window for best resolution
            
            [x_mouse_in3x3, y_mouse_in3x3, button_in3x3] = ginput(1);
            if button_in3x3 == 27 %'Esc'
                if ishandle(h_3x3fig)
                    close(h_3x3fig);
                end
                IsAbort = true;
            end
            
            %Caluclate x_mouse_inFullResolutionPixels
            y_mouse_inFullResolutionPixels = (Mouse_TileR-2)*GuiGlobalsStruct.FullMapData.ImageHeightInPixels + y_mouse_in3x3;
            x_mouse_inFullResolutionPixels = (Mouse_TileC-2)*GuiGlobalsStruct.FullMapData.ImageHeightInPixels + x_mouse_in3x3;
            
%             X_Stage_mm = GuiGlobalsStruct.FullMapData.LeftStageX_mm + 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) - x_mouse_inFullResolutionPixels*NativePixelWidth_mm
%             Y_Stage_mm = GuiGlobalsStruct.FullMapData.TopStageY_mm - 0.5*(GuiGlobalsStruct.FullMapData.TileFOV_microns/1000) + y_mouse_inFullResolutionPixels*NativePixelHeight_mm
            
            if ishandle(h_3x3fig)
                close(h_3x3fig);
            end
        
            
            y_mouse = y_mouse_inFullResolutionPixels/GuiGlobalsStruct.FullMapData.DownsampleFactor;
            x_mouse = x_mouse_inFullResolutionPixels/GuiGlobalsStruct.FullMapData.DownsampleFactor;
            
            disp(sprintf('x_mouse = %d, y_mouse = %d', x_mouse, y_mouse));
            
        else %button == 1
  
        end
        
        
        if IsAbort == false
            
            
            %There probably is a CoarseSectionList by this point created by the
            %auto map, but if user skipped the automap and wants to do
            %everything manually we need to init the GuiGlobalsStruct.CoarseSectionList
            % here.
            if ~isfield(GuiGlobalsStruct,'CoarseSectionList')
                GuiGlobalsStruct.CoarseSectionList = [];
                NewSectionNum = 1;
            else
                NewSectionNum = 1+length(GuiGlobalsStruct.CoarseSectionList);
            end
            
            
            GuiGlobalsStruct.CoarseSectionList(NewSectionNum).rpeak = y_mouse;
            GuiGlobalsStruct.CoarseSectionList(NewSectionNum).cpeak = x_mouse;
            GuiGlobalsStruct.CoarseSectionList(NewSectionNum).IsDeleted = false;
            
            
            MyLabel{1} = '';
            GuiGlobalsStruct.CoarseSectionList(NewSectionNum).Label = MyLabel{1};
            
            MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
            if MyVal == 1
                IsDisplayCrosshairsAndLabels = true;
            else
                IsDisplayCrosshairsAndLabels = false;
            end
            
        end
        
        RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);
    end
    
    if (button == 77) || (button == 108) %'l' or 'L' change label
        
        for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
            x = GuiGlobalsStruct.CoarseSectionList(i).cpeak;
            y = GuiGlobalsStruct.CoarseSectionList(i).rpeak;
            
            MouseToSectionDist = sqrt(  (x-x_mouse)^2 + (y-y_mouse)^2 );
            
            if (MouseToSectionDist < 50) && (~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted)
                MyLabel = inputdlg('Enter Label:');
                if length(MyLabel) == 0 %this corrects for user cancel
                    MyLabel{1} = '';
                end
                GuiGlobalsStruct.CoarseSectionList(i).Label = MyLabel{1};
            end
        end
        
        MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
        if MyVal == 1
            IsDisplayCrosshairsAndLabels = true;
        else
            IsDisplayCrosshairsAndLabels = false;
        end
        
        RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);
    end
        
    


    %Delete section
    if button == 2   %middle mouse means delete

        
        for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
            x = GuiGlobalsStruct.CoarseSectionList(i).cpeak;
            y = GuiGlobalsStruct.CoarseSectionList(i).rpeak;
            
            MouseToSectionDist = sqrt(  (x-x_mouse)^2 + (y-y_mouse)^2 );
            
            if (MouseToSectionDist < 50) && (~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted)
                GuiGlobalsStruct.CoarseSectionList(i).IsDeleted = true;
            end
        end
        
        
        MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
        if MyVal == 1
            IsDisplayCrosshairsAndLabels = true;
        else
            IsDisplayCrosshairsAndLabels = false;
        end
        
        RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);
    end
    
    
    
end



% --- Executes on button press in AutoNumberSections_Button.
function AutoNumberSections_Button_Callback(hObject, eventdata, handles)
% hObject    handle to AutoNumberSections_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%First purge the deleted sections and any previouse lables
n=1;
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)   
    if(~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted)
        CoarseSectionList_Copy(n) = GuiGlobalsStruct.CoarseSectionList(i);
        CoarseSectionList_Copy(n).Label = '';
        CoarseSectionList_Copy(n).IsDeleted = false;    
        n=n+1;
    end
end
GuiGlobalsStruct.CoarseSectionList = CoarseSectionList_Copy; %Replace original with copy

%Defining ordering style Booleans
MyVal = get(handles.OrderStripsFromLeftToRight_CheckBox,'value');
if MyVal == 1   
    IsOrderStripsFromLeft = true;
else
    IsOrderStripsFromLeft = false;
end
MyVal = get(handles.OrderSectionsFromTopToBottom_CheckBox,'value');
if MyVal == 1   
    IsOrderSectionsFromTopToBottom = true;
else
    IsOrderSectionsFromTopToBottom = false;
end


%Compute distance from left side
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
    cpeak = GuiGlobalsStruct.CoarseSectionList(i).cpeak;
    DistanceFromLeftSide(i) = cpeak; 
end
%Now use this "DistanceFromLeftSide" to reorder 
%[Y,I] = SORT(X,DIM,MODE)
if IsOrderStripsFromLeft
    [Y,I] = sort(DistanceFromLeftSide,2,'ascend');
else
    [Y,I] = sort(DistanceFromLeftSide,2,'descend');
end
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
    DistanceFromLeftSideOrdered_CoarseSectionList(i) = GuiGlobalsStruct.CoarseSectionList(I(i));
end


% if IsNewspaperOrdering
%     %do nothing
% else
%     %just reverse
%     PseudoDistanceFromTopLeftCorner = -PseudoDistanceFromTopLeftCorner;
% end


%Walk through and assign strip labels
MicronsPerPixel = GuiGlobalsStruct.FullMapData.DownsampleFactor*...
    (GuiGlobalsStruct.FullMapData.TileFOV_microns/GuiGlobalsStruct.FullMapData.ImageWidthInPixels);
MaxWidthInPixelsBeforeNewStrip = (1/MicronsPerPixel)*3000; %3mm
StripNum = 1;
DistanceFromLeftSideOrdered_CoarseSectionList(1).StripNum = StripNum;
for i = 2:length(DistanceFromLeftSideOrdered_CoarseSectionList)
    cpeak_Previous = DistanceFromLeftSideOrdered_CoarseSectionList(i-1).cpeak;
    cpeak_Current = DistanceFromLeftSideOrdered_CoarseSectionList(i).cpeak;
    if abs(cpeak_Current - cpeak_Previous) > MaxWidthInPixelsBeforeNewStrip
        StripNum = StripNum + 1;
    end
    DistanceFromLeftSideOrdered_CoarseSectionList(i).StripNum = StripNum;
end
TotalNumberOfStrips = StripNum;

%Now use StripNum to sort
for i = 1:length(DistanceFromLeftSideOrdered_CoarseSectionList)
    StripNumArray(i) = DistanceFromLeftSideOrdered_CoarseSectionList(i).StripNum; 
end
%[Y,I] = SORT(X,DIM,MODE)
[Y,I] = sort(StripNumArray);
for i = 1:length(DistanceFromLeftSideOrdered_CoarseSectionList)
    StripNumOrdered_CoarseSectionList(i) = DistanceFromLeftSideOrdered_CoarseSectionList(I(i));
end

%START: for debug only
GuiGlobalsStruct.tempStripNumOrdered_CoarseSectionList = StripNumOrdered_CoarseSectionList;
%END: for debug only

%Now separate into separate lists one for each strip
PreviousStripNum = 0;
for i = 1:length(StripNumOrdered_CoarseSectionList)
    StripNum = DistanceFromLeftSideOrdered_CoarseSectionList(i).StripNum;
    if StripNum~=PreviousStripNum
        n = 1; %restart index since we have moved to next strip
    end
        
    StripList(StripNum).CoarseSectionList(n) = StripNumOrdered_CoarseSectionList(i);
    PreviousStripNum = StripNum;
    n = n + 1;
end

%Sort each of these based on rpeak
for StripNum = 1:TotalNumberOfStrips
    rpeakArray = [];
    for i = 1:length(StripList(StripNum).CoarseSectionList)
        rpeakArray(i) = StripList(StripNum).CoarseSectionList(i).rpeak;
    end
    %[Y,I] = SORT(X,DIM,MODE)
    if IsOrderSectionsFromTopToBottom
        [Y,I] = sort(rpeakArray,2,'ascend');
    else
        [Y,I] = sort(rpeakArray,2,'descend');
    end
    for i = 1:length(StripList(StripNum).CoarseSectionList)
        StripList(StripNum).OrderedCoarseSectionList(i) = StripList(StripNum).CoarseSectionList(I(i));
    end
end


%Put back inot a single ordered SectionList
n = 1;
for StripNum = 1:TotalNumberOfStrips
    for i = 1:length(StripList(StripNum).OrderedCoarseSectionList)
        FinalOrderedCoarseSectionList(n) = StripList(StripNum).OrderedCoarseSectionList(i);
        n = n+1;
    end
end



%Overwrite original
GuiGlobalsStruct.CoarseSectionList = FinalOrderedCoarseSectionList;
%Assign lables
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
    GuiGlobalsStruct.CoarseSectionList(i).Label = num2str(i);
    %GuiGlobalsStruct.CoarseSectionList(i).Label = num2str(GuiGlobalsStruct.CoarseSectionList(i).StripNum);
end

MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
if MyVal == 1   
    IsDisplayCrosshairsAndLabels = true;
else
    IsDisplayCrosshairsAndLabels = false;
end

RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);


function ReorderBasedOnSectionLabelsAndRemoveDeleted()
global GuiGlobalsStruct;
%TO DO:Put in code to get rid of deleted sections and make sure labels are
%ordered correctly and are numbers (others will be deleted)


%reorder based on section labels and get rid of deleted sections
%Note: Duplicate labels will be eliminated here as well
for i = 1:length(GuiGlobalsStruct.CoarseSectionList)
    SectionNumber = GuiGlobalsStruct.CoarseSectionList(i).Label
    
    [SectionNumber,IsOK]=str2num(GuiGlobalsStruct.CoarseSectionList(i).Label);
    if IsOK && ~GuiGlobalsStruct.CoarseSectionList(i).IsDeleted
        CorrectedCopyOfCoarseSectionList(SectionNumber) = GuiGlobalsStruct.CoarseSectionList(i);
    end
end

%check for empty entries (that would have been created if above skipped
%labels
for i = 1:length(CorrectedCopyOfCoarseSectionList)
   if isempty(CorrectedCopyOfCoarseSectionList(i).Label)
       MyStr = sprintf('Missing a section labeled %d. Please review then try again.', i); 
       uiwait(msgbox(MyStr));
       return;
   end 
end

%update the original
GuiGlobalsStruct.CoarseSectionList = CorrectedCopyOfCoarseSectionList;

% --- Executes on button press in SaveSectionList_Button.
function SaveSectionList_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSectionList_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

ReorderBasedOnSectionLabelsAndRemoveDeleted();



CoarseSectionListFileName = sprintf('%s\\CoarseSectionList.mat', GuiGlobalsStruct.FullWaferTileImagesDirectory);
if exist(CoarseSectionListFileName, 'file')
    MyStr = sprintf('%s already exists. Manually erase then press again (saftey precatuion)', CoarseSectionListFileName);
    uiwait(msgbox(MyStr));
    return;
else
    CoarseSectionList = GuiGlobalsStruct.CoarseSectionList;
    save(CoarseSectionListFileName,'CoarseSectionList');
    MyStr = sprintf('Saved: %s, Close AutoMapGUI to go on to next step.', CoarseSectionListFileName);
    uiwait(msgbox(MyStr));
end

%Close this GUI
close(handles.output);



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





% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

%disp(sprintf('Key pressed = %c', eventdata.Character));

GuiGlobalsStruct.LastKeyPressed = eventdata.Key;


% --- Executes on button press in OrderStripsFromLeftToRight_CheckBox.
function OrderStripsFromLeftToRight_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to OrderStripsFromLeftToRight_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OrderStripsFromLeftToRight_CheckBox
MyVal = get(handles.OrderStripsFromLeftToRight_CheckBox,'value');
disp(sprintf('MyVal = %d',MyVal));

% --- Executes on button press in OrderSectionsFromTopToBottom_CheckBox.
function OrderSectionsFromTopToBottom_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to OrderSectionsFromTopToBottom_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OrderSectionsFromTopToBottom_CheckBox
MyVal = get(handles.OrderSectionsFromTopToBottom_CheckBox,'value');
disp(sprintf('MyVal = %d',MyVal));


% --- Executes on button press in checkbox_DisplayCrosshairsAndLabels.
function checkbox_DisplayCrosshairsAndLabels_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DisplayCrosshairsAndLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DisplayCrosshairsAndLabels


MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
if MyVal == 1   
    IsDisplayCrosshairsAndLabels = true;
else
    IsDisplayCrosshairsAndLabels = false;
end

RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);


% --- Executes during object creation, after setting all properties.
function ShowFoundSections_Button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShowFoundSections_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function DisplayCurrentSection(handles)
global GuiGlobalsStruct;

MySectionNumberStr = get(handles.SectionNumber_edit, 'String');

MyWidthString = get(handles.WidthInPixels_edit,'String');
[w, IsOK] = str2num(MyWidthString);
if IsOK && w>=100 && w<=2000
    WidthSubImage = floor(w);
else
    WidthSubImage = 1000;
    set(handles.WidthInPixels_edit,'String',num2str(WidthSubImage));
end

MyHeightString = get(handles.HeightInPixels_edit,'String');
[h, IsOK] = str2num(MyHeightString);
if IsOK && h>=100 && h<=2000
    HeightSubImage = floor(h);
else
    HeightSubImage = 1000;
    set(handles.HeightInPixels_edit,'String',num2str(HeightSubImage));
end


%[X,OK]=STR2NUM(S)
[SectionNum, IsOK] = str2num(MySectionNumberStr)
if ~IsOK
    axes(handles.axes_ImageDisplay);
    cla;
    %uiwait(msgbox('Bad section number'));
else
    if (SectionNum >= 1) && (SectionNum <= length(GuiGlobalsStruct.CoarseSectionList))
        
        r_IndexInFullMap = GuiGlobalsStruct.CoarseSectionList(SectionNum).rpeak*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        c_IndexInFullMap = GuiGlobalsStruct.CoarseSectionList(SectionNum).cpeak*GuiGlobalsStruct.FullMapData.DownsampleFactor;
        Label = GuiGlobalsStruct.CoarseSectionList(SectionNum).Label;
        
        set(handles.SectionLabel_edit, 'String', Label);
        
        
        
        
        
        [SubImage] = ExtractSubImageFromFullWaferTileMontage(r_IndexInFullMap, c_IndexInFullMap, WidthSubImage, HeightSubImage);
        
        axes(handles.axes_ImageDisplay);
        imshow(SubImage, [0, 255]);
    else
        axes(handles.axes_ImageDisplay);
        cla;
        %uiwait(msgbox('Section number out of range'));
    end
    
    
end
        

% --- Executes on button press in RemoveDeletedAndReorderBasedOnLabels_button.
function RemoveDeletedAndReorderBasedOnLabels_button_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveDeletedAndReorderBasedOnLabels_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

ReorderBasedOnSectionLabelsAndRemoveDeleted();

MyVal = get(handles.checkbox_DisplayCrosshairsAndLabels,'value');
if MyVal == 1   
    IsDisplayCrosshairsAndLabels = true;
else
    IsDisplayCrosshairsAndLabels = false;
end
RefreshDisplayOfAutoMapGUI(handles.axes_FullMapDisplay, IsDisplayCrosshairsAndLabels);



function SectionNumber_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionNumber_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionNumber_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionNumber_edit as a double
global GuiGlobalsStruct;

DisplayCurrentSection(handles);

% --- Executes during object creation, after setting all properties.
function SectionNumber_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionNumber_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Next_pushbutton.
function Next_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Next_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

MySectionNumberStr = get(handles.SectionNumber_edit, 'String');

%[X,OK]=STR2NUM(S)
[SectionNum, IsOK] = str2num(MySectionNumberStr)
if IsOK
    if (SectionNum+1) <= length(GuiGlobalsStruct.CoarseSectionList)
        SectionNum = SectionNum + 1;
        set(handles.SectionNumber_edit, 'String',num2str(SectionNum));
        DisplayCurrentSection(handles);
    end
end

% --- Executes on button press in Prev_pushbutton.
function Prev_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Prev_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;

MySectionNumberStr = get(handles.SectionNumber_edit, 'String');

%[X,OK]=STR2NUM(S)
[SectionNum, IsOK] = str2num(MySectionNumberStr)
if IsOK
    if (SectionNum-1) >= 1
        SectionNum = SectionNum - 1;
        set(handles.SectionNumber_edit, 'String',num2str(SectionNum));
        DisplayCurrentSection(handles);
    end
end

% --- Executes on button press in Play_pushbutton.
function Play_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AutoMapGUIGlobals;

AutoMapGUIGlobals.IsStopPlay = false;
IsAtEnd = false;

while ~IsAtEnd && ~AutoMapGUIGlobals.IsStopPlay
    MySectionNumberStr = get(handles.SectionNumber_edit, 'String');
    
    %[X,OK]=STR2NUM(S)
    [SectionNum, IsOK] = str2num(MySectionNumberStr);
    if ~IsOK
        SectionNum = 1;
    end
    
    
    SectionNum = SectionNum + 1;
    if SectionNum > length(GuiGlobalsStruct.CoarseSectionList)
        IsAtEnd = true;
    else
        set(handles.SectionNumber_edit, 'String',num2str(SectionNum));
        DisplayCurrentSection(handles);
    end
    
end


% --- Executes on button press in Stop_pushbutton.
function Stop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AutoMapGUIGlobals;

AutoMapGUIGlobals.IsStopPlay = true;



function SectionLabel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SectionLabel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SectionLabel_edit as text
%        str2double(get(hObject,'String')) returns contents of SectionLabel_edit as a double


% --- Executes during object creation, after setting all properties.
function SectionLabel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SectionLabel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WidthInPixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to WidthInPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthInPixels_edit as text
%        str2double(get(hObject,'String')) returns contents of WidthInPixels_edit as a double




% --- Executes during object creation, after setting all properties.
function WidthInPixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthInPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightInPixels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HeightInPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightInPixels_edit as text
%        str2double(get(hObject,'String')) returns contents of HeightInPixels_edit as a double


% --- Executes during object creation, after setting all properties.
function HeightInPixels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightInPixels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes_FullMapDisplay);
zoom on;

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
global AutoMapGUIGlobals;
axes(handles.axes_FullMapDisplay);
zoom off;

AutoMapGUIGlobals.axes_FullMapDisplay_xlim = get(handles.axes_FullMapDisplay, 'xlim');
AutoMapGUIGlobals.axes_FullMapDisplay_ylim = get(handles.axes_FullMapDisplay, 'ylim');

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GuiGlobalsStruct;
axes(handles.axes_FullMapDisplay);
zoom out;

AutoMapGUIGlobals.axes_FullMapDisplay_xlim = get(handles.axes_FullMapDisplay, 'xlim');
AutoMapGUIGlobals.axes_FullMapDisplay_ylim = get(handles.axes_FullMapDisplay, 'ylim');
