function [  ] = GenerateXMLFromManuallyCorrectedStagePosFiles()
%This function generates a Fibics readable xml stage map from the currently
%loaded aligned target points list.
global GuiGlobalsStruct;

Current_WorkingDistance = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');
Current_Brightness = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
Current_Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
Current_StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
Current_StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');

NewSectionIndexAcountingForSkips = 0;
for SectionIndex = 1:length(GuiGlobalsStruct.CoarseSectionList)
    DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,SectionIndex);
    if exist(DataFileNameStr)
        NewSectionIndexAcountingForSkips = NewSectionIndexAcountingForSkips + 1;
        disp(sprintf('Loading %s', DataFileNameStr));
        load(DataFileNameStr,'Info');

        
        XMLInfoArray(NewSectionIndexAcountingForSkips).NewSectionIndexAcountingForSkips = NewSectionIndexAcountingForSkips;
        XMLInfoArray(NewSectionIndexAcountingForSkips).SectionIndexFromCoarseSectionList = SectionIndex;
        
        StageX_Meters = Info.StageX_Meters;
        StageY_Meters = Info.StageY_Meters;
        %If there was no stage transform during the original save
        %then you should apply the current stage transform (if one
        %exists) to this stored position
        if isempty(Info.StageTransformAtTimeOfSave)
            IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
            if IsUseStageCorrection
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
            end
        else %if there was a stage transform during the original save then first apply the inverse  of the original saved transform,
            % then apply the current transform
            disp(sprintf('Before inv transform (%d, %d)',StageX_Meters, StageY_Meters));
            [StageX_Meters, StageY_Meters] = tforminv(Info.StageTransformAtTimeOfSave,[StageX_Meters],[StageY_Meters]);
            disp(sprintf('After inv transform (%d, %d)',StageX_Meters, StageY_Meters));
            IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
            if IsUseStageCorrection
                disp(sprintf('Before transform (%d, %d)',StageX_Meters, StageY_Meters));
                [StageX_Meters, StageY_Meters] = tformfwd(GuiGlobalsStruct.StageTransform,[StageX_Meters],[StageY_Meters]);
                GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees)
                disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
            end
        end
        
        
        XMLInfoArray(NewSectionIndexAcountingForSkips).StageX_Meters = StageX_Meters;
        XMLInfoArray(NewSectionIndexAcountingForSkips).StageY_Meters = StageY_Meters;
        XMLInfoArray(NewSectionIndexAcountingForSkips).ScanRot_Degrees = Info.ScanRotation;
        
        IsUseCurrentStigEtc = true;
        if IsUseCurrentStigEtc
            XMLInfoArray(NewSectionIndexAcountingForSkips).WorkingDistance = Current_WorkingDistance;
            XMLInfoArray(NewSectionIndexAcountingForSkips).Brightness = Current_Brightness;
            XMLInfoArray(NewSectionIndexAcountingForSkips).Contrast = Current_Contrast;
            XMLInfoArray(NewSectionIndexAcountingForSkips).StigX = Current_StigX;
            XMLInfoArray(NewSectionIndexAcountingForSkips).StigY = Current_StigY;
        else
            
            XMLInfoArray(NewSectionIndexAcountingForSkips).WorkingDistance = Info.WorkingDistance;
            XMLInfoArray(NewSectionIndexAcountingForSkips).Brightness = Info.Brightness;
            XMLInfoArray(NewSectionIndexAcountingForSkips).Contrast = Info.Contrast;
            XMLInfoArray(NewSectionIndexAcountingForSkips).StigX = Info.StigX;
            XMLInfoArray(NewSectionIndexAcountingForSkips).StigY = Info.StigY;
            
        end
        
        
    else
        disp(sprintf('Could not find file: %s, skipping.',DataFileNameStr));
       
    end
    

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
        LabelStr = num2str(XMLInfoArray(i).SectionIndexFromCoarseSectionList);
        
        Info.StageX_Meters = XMLInfoArray(i).StageX_Meters;
        Info.StageY_Meters = XMLInfoArray(i).StageY_Meters;
        Info.ScanRotation = XMLInfoArray(i).ScanRot_Degrees;
        

        
        %Use current settings to populate non-position info
        Info.stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
        Info.stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
        Info.stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
        Info.stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
        
        Info.WorkingDistance = XMLInfoArray(i).WorkingDistance;
        Info.Brightness = XMLInfoArray(i).Brightness;
        Info.Contrast = XMLInfoArray(i).Contrast;
        Info.StigX = XMLInfoArray(i).StigX;
        Info.StigY = XMLInfoArray(i).StigY;
        
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


