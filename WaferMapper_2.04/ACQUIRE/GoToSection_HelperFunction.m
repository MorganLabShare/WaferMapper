function [IsSuccessfulMove] = GoToSection_HelperFunction(handles, IsIncrement, IsSave , IsActualMove)
global GuiGlobalsStruct;

IsSuccessfulMove = false;

if isfield(GuiGlobalsStruct, 'StageTransform') 
    if ~isempty(GuiGlobalsStruct.StageTransform) 
        GuiGlobalsStruct.IsUseStageCorrection = true;
    else
        GuiGlobalsStruct.IsUseStageCorrection = false;
    end
else
    GuiGlobalsStruct.IsUseStageCorrection = false;
end

%make sure the directory exists, make it if not
if ~isfield(GuiGlobalsStruct, 'ManuallyCorrectedStagePositionsDirectory')
    GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory = sprintf('%s\\ManuallyCorrectedStagePositionsDirectory',GuiGlobalsStruct.WaferDirectory);
end
if ~exist(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory, 'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR)
    disp(sprintf('Creating directory: %s',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory));
    [success,message,messageid] = mkdir(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory);
end

MySectionNumStrCellArray = get(handles.SectionNumberForQuickManualTargeting_EditBox, 'String');
if iscell(MySectionNumStrCellArray)
    MySectionNumStr = MySectionNumStrCellArray{1};
else
    MySectionNumStr = MySectionNumStrCellArray;
end
MySectionNum = str2num(MySectionNumStr);


if isempty(MySectionNum)
    uiwait(msgbox('Not a legal section number'));
    return;
else
    MySectionNum = floor(MySectionNum);
    disp(sprintf('MySectionNum = %d',MySectionNum));
    
    if ~isfield(GuiGlobalsStruct , 'CoarseSectionList')
        uiwait(msgbox('No CoarseSectionList found'));
        return;
    else
        
        %%% First save current position info if requested
        if IsSave   
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
            if isfield(GuiGlobalsStruct, 'StageTransform')
                Info.StageTransformAtTimeOfSave = GuiGlobalsStruct.StageTransform;
            else
                Info.StageTransformAtTimeOfSave = [];
            end
            
            
            
            
            DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,MySectionNum);
            save(DataFileNameStr,'Info');
            disp(sprintf('Saved %s', DataFileNameStr));
        end
        
        %%% Second increment number if requested
        if IsIncrement
            MySectionNum = MySectionNum + 1;
        end
        
        
        
        if (MySectionNum < 1) || (MySectionNum > length(GuiGlobalsStruct.CoarseSectionList))
            uiwait(msgbox('Section number out of range'));
            return;
        else
            set(handles.SectionNumberForQuickManualTargeting_EditBox, 'String', num2str(MySectionNum));
            
            %Lastly, look to see if there is already a saved manual position file. 
            %  If there is then go to that position, if not then goto 
            %  the one detictated by the coarse section list
            IsGoToDataFilePosition = false;
            if exist(GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory, 'dir')
                DataFileNameStr = sprintf('%s\\CorrectedStagePosition_%d.mat',GuiGlobalsStruct.ManuallyCorrectedStagePositionsDirectory,MySectionNum);
                disp(sprintf('Looking for: %s',DataFileNameStr));
                if exist(DataFileNameStr, 'file')
                    disp(sprintf('Loading %s', DataFileNameStr));
                    load(DataFileNameStr,'Info');
                    IsGoToDataFilePosition = true;
                end
            end
            
            if IsGoToDataFilePosition

                
                InfoTextStr = evalc('disp(Info)');
            
                set(handles.ManuallyCorrectedStagePositionInfo_edit, 'String', InfoTextStr);
                
                StageX_Meters = Info.StageX_Meters;
                StageY_Meters = Info.StageY_Meters;
                stage_z = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
                stage_t = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
                stage_r = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
                stage_m = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');
                
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
                        GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',GuiGlobalsStruct.StageTransformScanRotationAngleInDegrees);
                        disp(sprintf('After transform (%d, %d)',StageX_Meters, StageY_Meters));
                    end
                end
                
                
                
                if IsActualMove
                    MyStr = sprintf('Moving stage to(%0.5g, %0.5g)',StageX_Meters,StageY_Meters);
                    disp(MyStr);
                    %%%%
                    %One Backlash is perfomed here
                    %%%%
                    GuiGlobalsStruct.MyCZEMAPIClass.MoveStage(StageX_Meters,StageY_Meters,stage_z,stage_t,stage_r,stage_m);
                    while(strcmp(GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeString('DP_STAGE_IS'),'Busy'))
                        pause(.02)
                    end
                    wmBackLash
                    GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',Info.ScanRotation);
                    IsSuccessfulMove = true;
                end
                
                %Ignore these for now
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_SCANROTATION',Info.ScanRotation);
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_WD',Info.WorkingDistance);
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_BRIGHTNESS',Info.Brightness);
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_CONTRAST',Info.Contrast);
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_X',Info.StigX);
                %                     GuiGlobalsStruct.MyCZEMAPIClass.Set_PassedTypeSingle('AP_STIG_Y',Info.StigY);
                
            
            else
                InfoTextStr = 'No file. \n Going to section center position.';
                set(handles.ManuallyCorrectedStagePositionInfo_edit, 'String', InfoTextStr);
                
                
                y_mouse = GuiGlobalsStruct.CoarseSectionList(MySectionNum).rpeak
                x_mouse = GuiGlobalsStruct.CoarseSectionList(MySectionNum).cpeak
                
                IsUseStageCorrection = GuiGlobalsStruct.IsUseStageCorrection;
                GoToStagePositionBasedOnFullWaferOverviewCoords(x_mouse, y_mouse, IsUseStageCorrection, true);
                
            end
            
            UpdateFullWaferDisplay(handles);
        end
        
        
    end
    
    
end
