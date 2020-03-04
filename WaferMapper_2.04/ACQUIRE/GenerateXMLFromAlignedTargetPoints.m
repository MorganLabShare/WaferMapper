function [  ] = GenerateXMLFromAlignedTargetPoints()
%This function generates a Fibics readable xml stage map from the currently
%loaded aligned target points list.
global GuiGlobalsStruct;

ButtonName = questdlg('Do you want to apply the current stage transform?', 'Question', 'Yes', 'No', 'No');

% %Determine what wafer is loaded
WaferNameIndex = 0;
for i = 1:length(GuiGlobalsStruct.ListOfWaferNames)
    WaferName = GuiGlobalsStruct.ListOfWaferNames{i};
    WaferDirName = sprintf('%s\\%s',...
        GuiGlobalsStruct.UTSLDirectory, WaferName);
    if strcmp(GuiGlobalsStruct.WaferDirectory, WaferDirName)
        WaferNameIndex = i;
    end
end
if WaferNameIndex == 0
    MyStr = sprintf('Could not find index of current wafer in loaded target points.');
    uiwait(msgbox(MyStr));
    return;
end
WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex};

%Walk through all sections
for SectionIndex = 1:length(GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray)
    MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
    %WaferNameIndex
    %SectionIndex
    
    GuiGlobalsStruct.MontageTarget.MicronsPerPixel = MySection.SectionOveriewInfo.ReadFOV_microns/MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageX_Meters;
    GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = MySection.SectionOveriewInfo.StageY_Meters;
    GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = MySection.SectionOveriewInfo.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = MySection.SectionOveriewInfo.ImageHeightInPixels;
    
    GuiGlobalsStruct.MontageTarget.Alignment_r_offset = MySection.AlignmentParameters.r_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_c_offset = MySection.AlignmentParameters.c_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = MySection.AlignmentParameters.AngleOffsetInDegrees;
    GuiGlobalsStruct.MontageTarget.LabelStr = MySection.LabelStr;
    
    
    %First get target point coords in pixels relative to center of image
    y_pixels = -( GuiGlobalsStruct.MontageTarget.r - floor(GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels/2) );
    x_pixels = GuiGlobalsStruct.MontageTarget.c - floor(GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels/2);
    
    %Then apply a rotation of this
    theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees;
    cosTheta = cos(theta_rad);
    sinTheta = sin(theta_rad);
    x_prime_pixels = cosTheta*x_pixels + sinTheta*y_pixels;
    y_prime_pixels = -sinTheta*x_pixels + cosTheta*y_pixels;
    
    %HERE IS WHERE I ADD IN THE CORRECTION FROM THE AlignedTargetList
    r_offset = MySection.YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
    c_offset = - MySection.XOffsetOfNewInPixels;
    GuiGlobalsStruct.MontageTarget.Alignment_r_offset = GuiGlobalsStruct.MontageTarget.Alignment_r_offset...
        +r_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_c_offset = GuiGlobalsStruct.MontageTarget.Alignment_c_offset...
        +c_offset;
    
    %Then apply the translation offsets that were needed to align this image
    x_prime_pixels = x_prime_pixels - GuiGlobalsStruct.MontageTarget.Alignment_c_offset;
    y_prime_pixels = y_prime_pixels + GuiGlobalsStruct.MontageTarget.Alignment_r_offset;
    
    %now convert this to stage coordinates
    StageX_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview;
    StageY_Meters_CenterOriginalOverview = GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview;
    
    StageX_Meters = StageX_Meters_CenterOriginalOverview - ...
        x_prime_pixels*(GuiGlobalsStruct.MontageTarget.MicronsPerPixel/1000000);
    StageY_Meters = StageY_Meters_CenterOriginalOverview - ...
        y_prime_pixels*(GuiGlobalsStruct.MontageTarget.MicronsPerPixel/1000000);%Note: This function already applies the stage correction transformation
    %and angle correction
    ScanRot_Degrees = -GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees;% -GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
    
    %Apply the current stage transformation if it exists
    if isfield(GuiGlobalsStruct,'StageTransform')
        if ~isempty(GuiGlobalsStruct.StageTransform)
            
            if strcmp(ButtonName, 'Yes')
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                ScanRot_Degrees = ScanRot_Degrees + GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees;
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
            end
        end
    end
    
    %NOTE: YOU NEED TO CHECK IF BETWEEN 0 and 360 and correct here
    if ScanRot_Degrees > 360
        ScanRot_Degrees = ScanRot_Degrees - 360;
    end
    
    if ScanRot_Degrees < 0
        ScanRot_Degrees = ScanRot_Degrees + 360;
    end
   
    disp(sprintf('Section# %d', SectionIndex));
    disp(sprintf('   StageX_Meters = %d',StageX_Meters));
    disp(sprintf('   StageY_Meters = %d',StageY_Meters));
    disp(sprintf('   ScanRot_Degrees = %d',ScanRot_Degrees));

    XMLInfoArray(SectionIndex).StageX_Meters = StageX_Meters;
    XMLInfoArray(SectionIndex).StageY_Meters = StageY_Meters;
    XMLInfoArray(SectionIndex).ScanRot_Degrees = ScanRot_Degrees;
    
end

%**Generate XML stage map

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediatly after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uiputfile('*.xml', 'Select file for Save As:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    OutputXMLFileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);


MyStr = sprintf('Generating file: %s', OutputXMLFileName);
h_fig = msgbox(MyStr);



%Read in TemplateFibicsXML.xml
TemplateFibicsXMLFileName = '.\TemplateFibicsXML.xml';
txt=sprintf('Loading xml stage map %s ...',TemplateFibicsXMLFileName); disp(txt);
[tree1, rootname1, dom1]=xml_read(TemplateFibicsXMLFileName);

%Create a duplicate copy of the original xml tree
tree2 = tree1;
%remove all 'Ref' fields from this new tree
i = 1;
IsMoreRefsToRemove = true;
while IsMoreRefsToRemove
    tag = sprintf('Ref%i',i);
    if isfield(tree2,tag)
        tree2 = rmfield(tree2, tag);
        i = i + 1;
    else
        IsMoreRefsToRemove = false;
    end
    
end


for i = 1:length(XMLInfoArray)
        tag = sprintf('Ref%i',i);
        LabelStr = num2str(i);
        
        Info.StageX_Meters = XMLInfoArray(i).StageX_Meters;
        Info.StageY_Meters = XMLInfoArray(i).StageY_Meters;
        Info.ScanRotation = XMLInfoArray(i).ScanRot_Degrees;
        
        %Use current settings to populate non-position info
        Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
        Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
        Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
        Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
        Info.WorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
        Info.Brightness = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
        Info.Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
        Info.StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
        Info.StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');
        
        %copy the first Ref field of the template XML to the new tree
        command=sprintf('tree2.%s = tree1.Ref1;',tag); eval(command);
        
        %Update position info etc in this new ref in tree2
        command=sprintf('tree2.%s.Name=LabelStr;',tag); eval(command);
        
        
        command=sprintf('tree2.%s.Stage.X=-1000000*Info.StageX_Meters;',tag); eval(command);
        command=sprintf('tree2.%s.Stage.Y=-1000000*Info.StageY_Meters;',tag); eval(command);
        command=sprintf('tree2.%s.Beam.ScanRot=Info.ScanRotation;',tag); eval(command);
        
        command=sprintf('tree2.%s.Stage.Rot=Info.stage_r;',tag); eval(command);
        command=sprintf('tree2.%s.Stage.Tilt=Info.stage_t;',tag); eval(command); %should always be 0
        command=sprintf('tree2.%s.Stage.Z=1000000*Info.stage_z;',tag); eval(command); %should always be 25000
        command=sprintf('tree2.%s.Beam.WD=Info.WorkingDistance;',tag); eval(command); %KH check       
        command=sprintf('tree2.%s.Detector.B=Info.Brightness;',tag); eval(command); %KH check
        command=sprintf('tree2.%s.Detector.C=Info.Contrast;',tag); eval(command); %KH check
        command=sprintf('tree2.%s.Beam.StigX=Info.StigX;',tag); eval(command); %KH check
        command=sprintf('tree2.%s.Beam.StigY=Info.StigY;',tag); eval(command); %KH check
    
        
        %make sure to update total number of points
        command=sprintf('tree2.NumPoints = i;',tag); eval(command);
  
    
end


% Write new XML File
txt=sprintf('Writing stage map to %s ...',OutputXMLFileName); disp(txt);
xml_write(OutputXMLFileName,tree2,rootname1);

if ishandle(h_fig)
    close(h_fig);
end


