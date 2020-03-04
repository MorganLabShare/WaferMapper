function UpdateSectionOverviewDisplay(handles)
global GuiGlobalsStruct;


%note: The wafer we are loading the aligned section overview from is not
%necessarilly the one currently loaded.
PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
PopupMenuCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
WaferName = PopupMenuCellArray{PopupMenuIndex};

%Check if this directory exists and change to current wafer name if not
WaferDirName = sprintf('%s\\%s',...
    GuiGlobalsStruct.UTSLDirectory, WaferName);
if ~exist(WaferDirName, 'dir')
    WaferDirName = GuiGlobalsStruct.WaferDirectory;
end

DownSampleFactor = 1; %Leave this at 1 for now, not sure if the code works well with different valuse


LabelStr = get(handles.SectionLabel_EditBox,'String');





ImageFileNameStr = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.tif',...
    WaferDirName, LabelStr);

%Return if this file and or directory has not yet been created
if ~exist(ImageFileNameStr, 'file')
    MyStr = sprintf('Could not find %s.',ImageFileNameStr);
    disp(MyStr);
    %uiwait(msgbox(MyStr));
    
    axes(handles.Axes_SectionOverviewDisplay);
    imshow(255*ones(500,500), [0,255]);
    h_text = text(10,10,'Could not find aligned section overview file.');
    %set(h_text,'FontSize',6);
    return;
end

set(handles.AlignedSectionOverviewFileName_EditBox, 'String', 'Loading...');

%Only once do we load a full res image to determine its size
if ~isfield(GuiGlobalsStruct,'SectionOverviewImageWidthInPixels')
    GuiGlobalsStruct.MyImage = imread(ImageFileNameStr, 'tif');
    [MaxR, MaxC] = size(GuiGlobalsStruct.MyImage);
    GuiGlobalsStruct.SectionOverviewImageWidthInPixels = MaxC;
    GuiGlobalsStruct.SectionOverviewImageHeightInPixels = MaxR;
end

MyImage = imread(ImageFileNameStr, 'PixelRegion',...
    {[1 DownSampleFactor GuiGlobalsStruct.SectionOverviewImageWidthInPixels], [1 DownSampleFactor GuiGlobalsStruct.SectionOverviewImageHeightInPixels]});
axes(handles.Axes_SectionOverviewDisplay);
imshow(MyImage, [0,255]);
set(handles.AlignedSectionOverviewFileName_EditBox, 'String', ImageFileNameStr);

%This maintains zoom across different sections displayed
if isfield(GuiGlobalsStruct, 'OverviewDisplay_xlim')
    set(handles.Axes_SectionOverviewDisplay, 'xlim', GuiGlobalsStruct.OverviewDisplay_xlim)
    set(handles.Axes_SectionOverviewDisplay, 'ylim',GuiGlobalsStruct.OverviewDisplay_ylim)
end


%KH Put code in to use the computed AlignedTargetList offsets
SectionIndex = str2num(LabelStr);
WaferNameIndex = -1;
if isfield(GuiGlobalsStruct, 'AlignedTargetList')
    for i = 1:length(GuiGlobalsStruct.AlignedTargetList.ListOfWaferNames)
        if 1 == strcmp(GuiGlobalsStruct.AlignedTargetList.ListOfWaferNames{i},WaferName)
            WaferNameIndex = i;
        end
    end
    if ~(WaferNameIndex == -1)
        MySection = GuiGlobalsStruct.AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex);
        
        %KH New code for putting in the offset calculated in the AlignedTargetList
        if isfield(MySection, 'YOffsetOfNewInPixels')
            r_offset = MySection.YOffsetOfNewInPixels;  %offset calculated in the AlignedTargetList
            c_offset = - MySection.XOffsetOfNewInPixels; %offset calculated in the AlignedTargetList
            GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset = r_offset;
            GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset = c_offset;
        else
            GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset = 0;
            GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset = 0;
        end
        
    end
else
    GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset = 0;
    GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset = 0;
end

DisplayStr = sprintf('');
set(handles.AlignedTargetOffset_EditBox,'String',DisplayStr);

if GuiGlobalsStruct.IsDisplayMontageTarget
    r_target = floor(GuiGlobalsStruct.MontageTarget.r/DownSampleFactor); %these are in pixel units of full res overview
    c_target = floor(GuiGlobalsStruct.MontageTarget.c/DownSampleFactor);    
    
    
    %START NEW CODE: Offset the displayed target point by the amount specified
    %by the aligned target list (which should be 0 if does not exist)
%     disp('AlignedTargetList Offsets:') ;
%     disp(sprintf('r_offset = %d', GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset));
%     disp(sprintf('c_offset = %d', GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset));
%     disp('_----------------------------') ;
    if isfield(GuiGlobalsStruct, 'AlignedTargetList')    
        DisplayStr = sprintf('Using AlignedTargetList Offsets: %d, %d', GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset,...
            GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset);
        r_target = r_target - GuiGlobalsStruct.MontageTarget.AlignedTargetList_r_offset;
        c_target = c_target - GuiGlobalsStruct.MontageTarget.AlignedTargetList_c_offset;
    else
        DisplayStr = sprintf('Not using AlignedTargetList offsets.');
    end
    set(handles.AlignedTargetOffset_EditBox,'String',DisplayStr);
    %END NEW CODE
    
    
    
    %***** Display the center cross with long north axis
    LineLength = 50;
    
    %Then apply a rotation of this
    theta_rad = (pi/180)*GuiGlobalsStruct.MontageTarget.MontageNorthAngle;
    cosTheta = cos(theta_rad);
    sinTheta = sin(theta_rad);
    
    c_target_north_UnitVector = sinTheta;
    r_target_north_UnitVector = -cosTheta;
    h1_NorthLine = line([c_target, c_target+2*LineLength*c_target_north_UnitVector],...
        [r_target, r_target+2*LineLength*r_target_north_UnitVector]); %north line is twice as long
    set(h1_NorthLine,'Color',[1 0 0]);
    
    c_target_south_UnitVector = -c_target_north_UnitVector;
    r_target_south_UnitVector = -r_target_north_UnitVector;
    h1_SouthLine = line([c_target, c_target+LineLength*c_target_south_UnitVector],...
        [r_target, r_target+LineLength*r_target_south_UnitVector]);
    set(h1_SouthLine,'Color',[1 0 0]);
    
    c_target_east_UnitVector = cosTheta;
    r_target_east_UnitVector = sinTheta;
    h1_EastLine = line([c_target, c_target+LineLength*c_target_east_UnitVector],...
        [r_target, r_target+LineLength*r_target_east_UnitVector]);
    set(h1_EastLine,'Color',[1 0 0]);
    
    
    c_target_west_UnitVector = -c_target_east_UnitVector;
    r_target_west_UnitVector = -r_target_east_UnitVector;
    h1_WestLine = line([c_target, c_target+LineLength*c_target_west_UnitVector],...
        [r_target, r_target+LineLength*r_target_west_UnitVector]);
    set(h1_WestLine,'Color',[1 0 0]);
    
    %AutoFocus point display
    AF_C_Offset_InPixels =  GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns/GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
    AF_R_Offset_InPixels =  GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns/GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
    
    r_AF_target = r_target + AF_R_Offset_InPixels*r_target_north_UnitVector + AF_C_Offset_InPixels*c_target_north_UnitVector; 
    c_AF_target = c_target + AF_R_Offset_InPixels*r_target_east_UnitVector + AF_C_Offset_InPixels*c_target_east_UnitVector;
    h1_AF_NorthSouthLine = line([c_AF_target-0.5*LineLength*c_target_north_UnitVector, c_AF_target+0.5*LineLength*c_target_north_UnitVector],...
        [r_AF_target-0.5*LineLength*r_target_north_UnitVector, r_AF_target+0.5*LineLength*r_target_north_UnitVector]); %north line is twice as long
    set(h1_AF_NorthSouthLine,'Color',[0 0 1]);    
    h1_AF_EastWestLine = line([c_AF_target-0.5*LineLength*c_target_east_UnitVector, c_AF_target+0.5*LineLength*c_target_east_UnitVector],...
        [r_AF_target-0.5*LineLength*r_target_east_UnitVector, r_AF_target+0.5*LineLength*r_target_east_UnitVector]);
    set(h1_AF_EastWestLine,'Color',[0 0 1]);
    
    %***** Display the montage bounds squares
    DropoutListFileName = sprintf('%s\\MontageTileDropOutList.txt',GuiGlobalsStruct.WaferDirectory);
    if exist(DropoutListFileName,'file')
        DropOutListArray = dlmread(DropoutListFileName,',');
    else
        DropOutListArray = [];
    end
    MontageHalfWidthInPixels = 0.5*(GuiGlobalsStruct.MontageTarget.MontageTileWidthInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel);
    MontageHalfHeightInPixels = 0.5*(GuiGlobalsStruct.MontageTarget.MontageTileHeightInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel);
    RowDistanceBetweenTileCentersInPixels = 2*MontageHalfHeightInPixels*(1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);
    ColDistanceBetweenTileCentersInPixels = 2*MontageHalfWidthInPixels*(1-GuiGlobalsStruct.MontageTarget.PercentTileOverlap/100);
    
    C_OffsetFromAlignTarget_InPixels = GuiGlobalsStruct.MontageTarget.XOffsetFromAlignTargetMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
    R_OffsetFromAlignTarget_InPixels = GuiGlobalsStruct.MontageTarget.YOffsetFromAlignTargetMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
    
    NumRowTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileRows;
    NumColTiles = GuiGlobalsStruct.MontageTarget.NumberOfTileCols;
    if isfield(GuiGlobalsStruct.MontageParameters,'allTiles')
        allTiles = GuiGlobalsStruct.MontageParameters.allTiles;
        
    else
       [y x] = find(ones(NumRowTiles,NumColTiles));
       allTiles = [x y];
    end
    checkTiles = allTiles;
    checkTiles(:,1) = NumRowTiles-allTiles(:,1)+1;
    
    for RowIndex = 1:NumRowTiles
        for ColIndex = 1:NumColTiles 
            
            IsDropOut = false;
            [NumDropOuts, dummy] = size(DropOutListArray);
            for DropOutListIndex = 1:NumDropOuts
                %NOTE: reversal of rows
                if (DropOutListArray(DropOutListIndex, 1) == (NumRowTiles-RowIndex)+1) && (DropOutListArray(DropOutListIndex, 2) == ColIndex) 
                    IsDropOut = true;
                end
            end
            
            if sum(((checkTiles(:,1) == RowIndex) + (checkTiles(:,2) == ColIndex))==2)
                boxCol = [1 0 0];                
                IsDropOut = 0;
            else
                boxCol = [.2 .1 .1];
                IsDropOut = 1;
            end
            
                
            
            if ~IsDropOut
                TileCenterRowOffsetInPixels = ((RowIndex -((NumRowTiles+1)/2)) * RowDistanceBetweenTileCentersInPixels) + R_OffsetFromAlignTarget_InPixels;
                TileCenterColOffsetInPixels = ((ColIndex -((NumColTiles+1)/2)) * ColDistanceBetweenTileCentersInPixels) + C_OffsetFromAlignTarget_InPixels;
                
                r_target_offset = r_target + TileCenterRowOffsetInPixels*r_target_north_UnitVector + TileCenterColOffsetInPixels*c_target_north_UnitVector;
                c_target_offset = c_target + TileCenterRowOffsetInPixels*r_target_east_UnitVector + TileCenterColOffsetInPixels*c_target_east_UnitVector;
                
                r_TopRight = r_target_offset + MontageHalfWidthInPixels*r_target_east_UnitVector + MontageHalfHeightInPixels*r_target_north_UnitVector;
                c_TopRight = c_target_offset + MontageHalfWidthInPixels*c_target_east_UnitVector + MontageHalfHeightInPixels*c_target_north_UnitVector;
                
                r_TopLeft = r_target_offset + MontageHalfWidthInPixels*r_target_west_UnitVector + MontageHalfHeightInPixels*r_target_north_UnitVector;
                c_TopLeft = c_target_offset + MontageHalfWidthInPixels*c_target_west_UnitVector + MontageHalfHeightInPixels*c_target_north_UnitVector;
                
                r_BottomLeft = r_target_offset + MontageHalfWidthInPixels*r_target_west_UnitVector + MontageHalfHeightInPixels*r_target_south_UnitVector;
                c_BottomLeft = c_target_offset + MontageHalfWidthInPixels*c_target_west_UnitVector + MontageHalfHeightInPixels*c_target_south_UnitVector;
                
                r_BottomRight = r_target_offset + MontageHalfWidthInPixels*r_target_east_UnitVector + MontageHalfHeightInPixels*r_target_south_UnitVector;
                c_BottomRight = c_target_offset + MontageHalfWidthInPixels*c_target_east_UnitVector + MontageHalfHeightInPixels*c_target_south_UnitVector;
                
                h1_TopMontageLine = line([c_TopLeft, c_TopRight],...
                    [r_TopLeft, r_TopRight]);
                set(h1_TopMontageLine,'Color',boxCol);
                
                h1_BottomMontageLine = line([c_BottomLeft, c_BottomRight],...
                    [r_BottomLeft, r_BottomRight]);
                set(h1_BottomMontageLine,'Color',boxCol);
                
                h1_LeftMontageLine = line([c_TopLeft, c_BottomLeft],...
                    [r_TopLeft, r_BottomLeft]);
                set(h1_LeftMontageLine,'Color',boxCol);
                
                h1_RightMontageLine = line([c_TopRight, c_BottomRight],...
                    [r_TopRight, r_BottomRight]);
                set(h1_RightMontageLine,'Color',boxCol);
            end
        end
    end
    

    
    %***** Display the low res box (for alignment) bounds square
    %Note: This is not rotated
    LowResForAlignHalfWidthInPixels = 0.5*(GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel);
    LowResForAlignHalfHeightInPixels = 0.5*(GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel);
    
    r_TopRight = r_target - LowResForAlignHalfHeightInPixels;%*r_target_east_UnitVector + MontageHalfHeightInPixels*r_target_north_UnitVector;
    c_TopRight = c_target + LowResForAlignHalfWidthInPixels;%*c_target_east_UnitVector + MontageHalfHeightInPixels*c_target_north_UnitVector;
    
    r_TopLeft = r_target - LowResForAlignHalfHeightInPixels;%*r_target_west_UnitVector + MontageHalfHeightInPixels*r_target_north_UnitVector;
    c_TopLeft = c_target - LowResForAlignHalfWidthInPixels;%*c_target_west_UnitVector + MontageHalfHeightInPixels*c_target_north_UnitVector;
    
    r_BottomLeft = r_target + LowResForAlignHalfHeightInPixels;%*r_target_west_UnitVector + MontageHalfHeightInPixels*r_target_south_UnitVector;
    c_BottomLeft = c_target - LowResForAlignHalfWidthInPixels;%*c_target_west_UnitVector + MontageHalfHeightInPixels*c_target_south_UnitVector;
    
    r_BottomRight = r_target + LowResForAlignHalfHeightInPixels;%*r_target_east_UnitVector + MontageHalfHeightInPixels*r_target_south_UnitVector;
    c_BottomRight = c_target + LowResForAlignHalfWidthInPixels;%*c_target_east_UnitVector + MontageHalfHeightInPixels*c_target_south_UnitVector;
    
    
    h1_TopLowResForAlignLine = line([c_TopLeft, c_TopRight],...
        [r_TopLeft, r_TopRight]);
    set(h1_TopLowResForAlignLine,'Color',[1 1 0]);
    
    h1_BottomLowResForAlignLine = line([c_BottomLeft, c_BottomRight],...
        [r_BottomLeft, r_BottomRight]);
    set(h1_BottomLowResForAlignLine,'Color',[1 1 0]);
    
    h1_LeftLowResForAlignLine = line([c_TopLeft, c_BottomLeft],...
        [r_TopLeft, r_BottomLeft]);
    set(h1_LeftLowResForAlignLine,'Color',[1 1 0]);
    
    h1_RightLowResForAlignLine = line([c_TopRight, c_BottomRight],...
        [r_TopRight, r_BottomRight]);
    set(h1_RightLowResForAlignLine,'Color',[1 1 0]);
    
end


%Determine what section we are on and record target parameters
LabelStr = get(handles.SectionLabel_EditBox,'String');

%DataFileNameStr = sprintf('%s\\SectionOverview_%s.mat',GuiGlobalsStruct.SectionOverviewsDirectory,LabelStr);
DataFileNameStr = sprintf('%s\\SectionOverviewsDirectory\\SectionOverview_%s.mat',...
    WaferDirName, LabelStr);

%AlignmentDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,LabelStr);
AlignmentDataFileNameStr = sprintf('%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.mat',...
    WaferDirName, LabelStr);

if exist(DataFileNameStr, 'file') && exist(AlignmentDataFileNameStr, 'file')
    

        
        
    %load(DataFileNameStr, 'SectionOveriewInfo'); %old file format
    load(DataFileNameStr, 'Info');
    load(AlignmentDataFileNameStr, 'AlignmentParameters');
    
    GuiGlobalsStruct.MontageTarget.MicronsPerPixel = Info.ReadFOV_microns/Info.ImageWidthInPixels; %KH need to replace with actual FOV info of image
    GuiGlobalsStruct.MontageTarget.StageX_Meters_CenterOriginalOverview = Info.StageX_Meters;
    GuiGlobalsStruct.MontageTarget.StageY_Meters_CenterOriginalOverview = Info.StageY_Meters;
    GuiGlobalsStruct.MontageTarget.OverviewImageWidthInPixels = Info.ImageWidthInPixels;
    GuiGlobalsStruct.MontageTarget.OverviewImageHeightInPixels = Info.ImageHeightInPixels;
    
    GuiGlobalsStruct.MontageTarget.Alignment_r_offset = AlignmentParameters.r_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_c_offset = AlignmentParameters.c_offset;
    GuiGlobalsStruct.MontageTarget.Alignment_AngleOffsetInDegrees = AlignmentParameters.AngleOffsetInDegrees;
    GuiGlobalsStruct.MontageTarget.LabelStr = LabelStr;
    
else
    MyStr = sprintf('Could not find %s and/or %s',DataFileNameStr, AlignmentDataFileNameStr);
    uiwait(msgbox(MyStr));
end



end







