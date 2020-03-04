function [  ] = GenerateXMLFromStackOfImages()
%This function generates a Fibics readable xml stage map from the currently
%loaded aligned target points list.
global GuiGlobalsStruct;

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
BackCD = cd; %remember the current working directory, is restored immediatly after file dialog
cd(GuiGlobalsStruct.WaferDirectory);
[filename, pathname] = uigetfile('*.mat', 'Select first image file''s *.mat file:');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
    cd(BackCD);
    return;
else
    FileName = fullfile(pathname, filename);
    disp(['User selected ', fullfile(pathname, filename)])
end
cd(BackCD);


% MyStr = sprintf('User choose file: %s', FileName);
% uiwait(msgbox(MyStr));
%parse this name to remove last number 
UnderscoreIndices = strfind(FileName, '_');
FileNameWithoutLastNumber = FileName(1:UnderscoreIndices(end));

n = 1;
while true
    DataFileName = sprintf('%s%d.mat',FileNameWithoutLastNumber,n);
    if ~exist(DataFileName, 'file')
        break;
    else
        disp(DataFileName);
    end
    n = n + 1;
end

TotalNumberOfSections = n-1;
MyStr = sprintf('About to process %d files', TotalNumberOfSections);
uiwait(msgbox(MyStr));


for SectionNum = 1:TotalNumberOfSections
    DataFileName = sprintf('%s%d.mat',FileNameWithoutLastNumber,SectionNum);
    load(DataFileName);
    if ~isfield(Info,'StageX_Meters')
        MyStr = sprintf('Could not fine Info.StageX_Meters field in file %s',DataFileName);
        uiwait(msgbox(MyStr));
        return;
    end
    
    disp(sprintf('Sec#%d: StageX_Meters = %d', SectionNum, Info.StageX_Meters));
    
    disp(sprintf('Section# %d', SectionNum));
    disp(sprintf('   StageX_Meters = %d',Info.StageX_Meters));
    disp(sprintf('   StageY_Meters = %d',Info.StageY_Meters));
    disp(sprintf('   ScanRotation = %d',Info.ScanRotation));

    XMLInfoArray(SectionNum).StageX_Meters = Info.StageX_Meters;
    XMLInfoArray(SectionNum).StageY_Meters = Info.StageY_Meters;
    XMLInfoArray(SectionNum).ScanRot_Degrees = Info.ScanRotation;
    
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


end


