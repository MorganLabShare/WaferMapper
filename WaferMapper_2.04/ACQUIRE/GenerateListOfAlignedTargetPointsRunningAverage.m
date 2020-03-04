%GenerateListOfAlignedTargetPoints




%NOTE: This function starts at the currently open section inthe WaferMapper GUI and crops the region of the
%SectionOverview image that is defined by the LowResForAlign box. It then
%goes to section2 and does a software alignment to this and recordes the
%offset needed to align these. It continues to the last section

global GuiGlobalsStruct;




%Determine the wafer name of the image currently displayed
PopupMenuIndex = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'Value');
PopupMenuCellArray = get(handles.WaferForSectionOverviewDisplay_PopupMenu,'String');
WaferName_InDisplay = PopupMenuCellArray{PopupMenuIndex};
SectionNumStr = get(handles.SectionLabel_EditBox,'String');

SectionToAlignTo_WaferNameIndex = PopupMenuIndex;
SectionToAlignTo_SectionIndex = str2num(SectionNumStr);


MyStr = sprintf('Sections will be aligned from WaferName=%s, (WaferNameIndex=%d), SectionNum=%d. Press OK to proceed.',...
    WaferName_InDisplay, SectionToAlignTo_WaferNameIndex, SectionToAlignTo_SectionIndex);

AnswerStr = questdlg(MyStr, ...
                         'Question', ...
                         'OK', 'Cancel', 'OK');

if isempty(AnswerStr)
   return; 
end
if strcmp(AnswerStr, 'Cancel')
    return;
end


%START: KH new code 1-15-2012
MyStr = sprintf('Create aligned target list only for WaferName=%s?',...
    WaferName_InDisplay);
AnswerStr = questdlg(MyStr, ...
                         'Question', ...
                         'Just This Wafer', 'All Wafers', 'All Wafers');
if isempty(AnswerStr)
   return; 
end
if strcmp(AnswerStr, 'Just This Wafer')
    IsDoJustThisWafer = true;
else
    IsDoJustThisWafer = false;
end                            
%END: KH new code 1-15-2012

%Setup how many images will be averaged to align with
NumberOfPreviousImages = 10; %10;
uiwait(msgbox(sprintf('Number of images to use for running average = %d. Press OK to continue.', NumberOfPreviousImages)));



%Save everythin in the following structure then save at end
AlignedTargetList.LowResForAlignWidthInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons;
AlignedTargetList.LowResForAlignHeightInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons;
AlignedTargetList.MicronsPerPixel = GuiGlobalsStruct.MontageTarget.MicronsPerPixel;
AlignedTargetList.AF_X_Offset_Microns = GuiGlobalsStruct.MontageTarget.AF_X_Offset_Microns;
AlignedTargetList.AF_Y_Offset_Microns = GuiGlobalsStruct.MontageTarget.AF_Y_Offset_Microns;

%Create directory if needed
if ~isfield(GuiGlobalsStruct, 'AlignedTargetListsDirectory')
    GuiGlobalsStruct.AlignedTargetListsDirectory = sprintf('%s\\AlignedTargetListsDirectory',GuiGlobalsStruct.UTSLDirectory);
end

if ~exist( GuiGlobalsStruct.AlignedTargetListsDirectory, 'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR)
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(GuiGlobalsStruct.UTSLDirectory, 'AlignedTargetListsDirectory');
    if ~SUCCESS
        MyStr = sprintf('Could not create: %s', GuiGlobalsStruct.AlignedTargetListsDirectory);
        disp(sprintf('Could not create: %s', GuiGlobalsStruct.AlignedTargetListsDirectory));
        uiwait(msgbox(MyStr));
        return;
    end
end

%Ask for name of this AlignedTargetList and make a directory
MyAnswer = inputdlg('Enter new name for this AlignedTargetList');
if ~isempty(MyAnswer) %is empty if user canceled
    NewDirectory = sprintf('%s\\%s',GuiGlobalsStruct.AlignedTargetListsDirectory,MyAnswer{1});
    if exist(NewDirectory)
        MyStr = sprintf('Directory already exists: %s', NewDirectory);
        uiwait(msgbox(MyStr));
        return;
    end
    
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(GuiGlobalsStruct.AlignedTargetListsDirectory, MyAnswer{1});
    if ~SUCCESS
        MyStr = sprintf('Could not create: %s', NewDirectory);
        disp(MyStr);
        uiwait(msgbox(MyStr));
        return;
    end

else
    return;
end


%Setup WAITBAR
%Perform quick calculation of how many images will be aligned. This is ONLY FOR WAITBAR
if IsDoJustThisWafer
    WaferName = GuiGlobalsStruct.ListOfWaferNames{SectionToAlignTo_WaferNameIndex};
    CoarseSectionListFileNameStr = sprintf('%s\\%s\\FullWaferTileImages\\CoarseSectionList.mat',...
        GuiGlobalsStruct.UTSLDirectory, WaferName);
    load(CoarseSectionListFileNameStr,'CoarseSectionList');
    Waitbar_TotalNumberOfImagesToAlign = length(CoarseSectionList);
    disp(sprintf('About to align a total of %d images across one wafer',Waitbar_TotalNumberOfImagesToAlign)); 
else
    Waitbar_TotalNumberOfImagesToAlign = 0;
    for WaferNameIndex = 1:length(GuiGlobalsStruct.ListOfWaferNames)
        WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex};
        CoarseSectionListFileNameStr = sprintf('%s\\%s\\FullWaferTileImages\\CoarseSectionList.mat',...
            GuiGlobalsStruct.UTSLDirectory, WaferName);
        load(CoarseSectionListFileNameStr,'CoarseSectionList');
        Waitbar_TotalNumberOfImagesToAlign = Waitbar_TotalNumberOfImagesToAlign + length(CoarseSectionList);
    end
    disp(sprintf('About to align a total of %d images across %d wafers',Waitbar_TotalNumberOfImagesToAlign, length(GuiGlobalsStruct.ListOfWaferNames))); 
end
GuiGlobalsStruct.IsUserCancelWaitBar = false;
GuiGlobalsStruct.h_waitbar = waitbar(0,'Generating aligned target points...',  'WindowStyle' , 'modal', 'CreateCancelBtn', 'UserCancelWaitBar();');
Waitbar_SectionNumber = 1;

%perform actual alignments
for FowardBackwardIndex = 1:2
    if FowardBackwardIndex == 1
        IsGoingForward = true;
    else
        IsGoingForward = false;
    end
    
    %Setup how many images will be averaged to align with
    %NumberOfPreviousImages = 10; %set above
    for i = 1:NumberOfPreviousImages
        PreviousImagesArray(i).Image = [];
    end
    MeanOfPreviousImages = [];
    
    if  IsGoingForward
        StartingWaferNameIndex = SectionToAlignTo_WaferNameIndex;
        WaferNameIndexIncrementSign = 1;
        if IsDoJustThisWafer
            EndingWaferNameIndex = StartingWaferNameIndex;
        else
            EndingWaferNameIndex = length(GuiGlobalsStruct.ListOfWaferNames);
        end
    else
        StartingWaferNameIndex = SectionToAlignTo_WaferNameIndex;
        WaferNameIndexIncrementSign = -1;
        if IsDoJustThisWafer
            EndingWaferNameIndex = StartingWaferNameIndex;
        else
            EndingWaferNameIndex = 1;
        end
    end
    
    for WaferNameIndex = StartingWaferNameIndex:WaferNameIndexIncrementSign:EndingWaferNameIndex
        
        
        
        AlignedTargetList.ListOfWaferNames  = GuiGlobalsStruct.ListOfWaferNames;
        
        
        WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex}
        CoarseSectionListFileNameStr = sprintf('%s\\%s\\FullWaferTileImages\\CoarseSectionList.mat',...
            GuiGlobalsStruct.UTSLDirectory, WaferName);
        load(CoarseSectionListFileNameStr,'CoarseSectionList');
        
        
        if  IsGoingForward
            if WaferNameIndex == StartingWaferNameIndex
                StartingSectionIndex = SectionToAlignTo_SectionIndex;
            else
                StartingSectionIndex = 1;
            end
            SectionIndexIncrementSign = 1;
            EndingSectionIndex = length(CoarseSectionList);
        else
            if WaferNameIndex == StartingWaferNameIndex
                StartingSectionIndex = SectionToAlignTo_SectionIndex;
            else
                StartingSectionIndex = length(CoarseSectionList);
            end
            SectionIndexIncrementSign = -1;
            EndingSectionIndex = 1;
        end
        
        for SectionIndex = StartingSectionIndex:SectionIndexIncrementSign:EndingSectionIndex;
            LabelStr = CoarseSectionList(SectionIndex).Label;
            
            
            %WAITBAR stuff
            if exist('SecondsToAlignedPreviousSection', 'var')
                UpdatedMessageStr = sprintf('# %d of %d. Time to complete %0.5g min', Waitbar_SectionNumber, Waitbar_TotalNumberOfImagesToAlign, ...
                    ((Waitbar_TotalNumberOfImagesToAlign-(Waitbar_SectionNumber-1))*SecondsToAlignedPreviousSection)/60);
            else
                UpdatedMessageStr = sprintf('Aligning section# %d of %d. Time to complete ...', Waitbar_SectionNumber, Waitbar_TotalNumberOfImagesToAlign);
            end
            waitbar(Waitbar_SectionNumber/Waitbar_TotalNumberOfImagesToAlign,GuiGlobalsStruct.h_waitbar, UpdatedMessageStr);
            if GuiGlobalsStruct.IsUserCancelWaitBar
                return;
            end
            StartTimeOfThisSection = tic;
            
            
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).LabelStr = LabelStr;
            
            
            ImageFileNameStr = sprintf('%s\\%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.tif',...
                GuiGlobalsStruct.UTSLDirectory, WaferName, LabelStr);
            
            r = round(GuiGlobalsStruct.MontageTarget.r);
            c = round(GuiGlobalsStruct.MontageTarget.c);
            half_w = round(0.5*(GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel));
            half_h = round(0.5*(GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons/GuiGlobalsStruct.MontageTarget.MicronsPerPixel));
            
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).ImageFileNameStr = ImageFileNameStr;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).r = r;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).c = c;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_w = half_w;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).half_h = half_h;
            
            
            NewImage = imread(ImageFileNameStr, 'PixelRegion',...
                {[r-half_h r+half_h], [c-half_w c+half_w]});
           
            IsPlotResults = false; 
            
            if IsPlotResults
                figure(100);
                subplot(1,2,1);
                imshow(NewImage, [0,255]);
                MyStr = sprintf('%s, Section# %s',WaferName,LabelStr);
                title(MyStr);
                drawnow;
            end
            
            AnglesInDegreesToTryArray = [-1 0 +1]; %Note: Should be pretty close from overview alignment
            if ~isempty(MeanOfPreviousImages) %KH KH KH Remove this it is to deal with bad first section!!!
                OriginalImage = uint8(MeanOfPreviousImages);
            else
                OriginalImage = NewImage; %just align first with it self for simplicity of code
            end
            
            MyStr = sprintf('%s',CoarseSectionListFileNameStr');
            disp(MyStr);
            [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] =...
                CalcPixelOffsetAndAngleBetweenTwoImages(OriginalImage, NewImage, AnglesInDegreesToTryArray)
            
            %*** create a new aligned image 'NewImage_shifted' *********************************
            r_offset = YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
            c_offset = - XOffsetOfNewInPixels;
            New_r = r - r_offset;
            New_c = c - c_offset;
            %now use these to grab a new image from the aligned overview
            NewImage_shifted = imread(ImageFileNameStr, 'PixelRegion',...
                {[New_r-half_h New_r+half_h], [New_c-half_w New_c+half_w]});
            
            
            %Also grab a 3x larger image centered at same region
            NewImage_x3LargerROI_shifted = imread(ImageFileNameStr, 'PixelRegion',...
                {[New_r-(half_h*3+1) New_r+(half_h*3+1)], [New_c-(half_w*3+1) New_c+(half_w*3+1)]});
            
            
            
            if IsPlotResults
                subplot(1,2,2);
                imshow(NewImage_shifted, [0,255]);
            end
            
            ImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
                    NewDirectory, WaferName, LabelStr);
            MyStr = sprintf('Writing file: %s',ImageFileNameStr);
            disp(MyStr);
            imwrite(NewImage_shifted, ImageFileNameStr, 'tif');
            
            ImageFile_x3LargerROI_NameStr = sprintf('%s\\LowResAligned_x3LargerROI_%s_Section_%s.tif',...
                NewDirectory, WaferName, LabelStr);
            MyStr = sprintf('Writing file: %s',ImageFile_x3LargerROI_NameStr);
            disp(MyStr);
            imwrite(NewImage_x3LargerROI_shifted, ImageFile_x3LargerROI_NameStr, 'tif');
            
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).XOffsetOfNewInPixels = XOffsetOfNewInPixels;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).YOffsetOfNewInPixels = YOffsetOfNewInPixels;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).AngleOffsetOfNewInDegrees = AngleOffsetOfNewInDegrees;
            
            %Update the previous image history and MeanOfPreviousImages with this new aligned image
            for i = 1:NumberOfPreviousImages
                ArrayIndex = (NumberOfPreviousImages-i)+1;
                if ArrayIndex > 1
                    PreviousImagesArray(ArrayIndex).Image = PreviousImagesArray(ArrayIndex-1).Image;
                else
                    PreviousImagesArray(ArrayIndex).Image = double(NewImage_shifted);
                end
            end
            n = 0;
            MeanOfPreviousImages = 0*double(NewImage);
            for i = 1:NumberOfPreviousImages
                if ~isempty(PreviousImagesArray(i).Image)
                    n=n+1;
                    MeanOfPreviousImages = MeanOfPreviousImages + PreviousImagesArray(i).Image;
                end
            end
            MeanOfPreviousImages = MeanOfPreviousImages/n;
            
            
            %Load section overview AlignmentDataFile and copy info into this section's file
            DataFileNameStr = sprintf('%s\\%s\\SectionOverviewsDirectory\\SectionOverview_%s.mat',...
                GuiGlobalsStruct.UTSLDirectory, WaferName, LabelStr);
            
            AlignmentDataFileNameStr = sprintf('%s\\%s\\SectionOverviewsAlignedWithTemplateDirectory\\SectionOverviewAligned_%s.mat',...
                GuiGlobalsStruct.UTSLDirectory, WaferName, LabelStr);
            
            if exist(DataFileNameStr, 'file') && exist(AlignmentDataFileNameStr, 'file')
                load(DataFileNameStr, 'Info');
                load(AlignmentDataFileNameStr, 'AlignmentParameters');
            else
                MyStr = sprintf('Could not find %s and/or %s',DataFileNameStr, AlignmentDataFileNameStr);
                uiwait(msgbox(MyStr));
                return;
            end
            
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).SectionOveriewInfo = Info;
            AlignedTargetList.WaferArray(WaferNameIndex).SectionArray(SectionIndex).AlignmentParameters = AlignmentParameters;
            
            
            TocAfterAllProcessing = toc(StartTimeOfThisSection);
            disp(sprintf('   Time for full processing of this section %0.5g seconds', TocAfterAllProcessing));
            SecondsToAlignedPreviousSection = TocAfterAllProcessing;
            Waitbar_SectionNumber = Waitbar_SectionNumber + 1;
        end
        
        
        
    end
    
end


DataFileNameStr = sprintf('%s\\AlignedTargetList.mat',NewDirectory);
save(DataFileNameStr, 'AlignedTargetList');


if ishandle(GuiGlobalsStruct.h_waitbar)
     delete(GuiGlobalsStruct.h_waitbar);
end