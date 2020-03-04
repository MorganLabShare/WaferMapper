%GenerateListOfAlignedTargetPoints

%NOTE: This function starts at section1 wafer1 and crops the region of the
%SectionOverview image that is defined by the LowResForAlign box. It then
%goes to section2 and does a software alignment to this and recordes the
%offset needed to align these. It continues to the last section

%Save everythin in the following structure then save at end
AlignedTargetList.LowResForAlignWidthInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignWidthInMicrons;
AlignedTargetList.LowResForAlignHeightInMicrons = GuiGlobalsStruct.MontageTarget.LowResForAlignHeightInMicrons;
AlignedTargetList.MicronsPerPixel = GuiGlobalsStruct.MontageTarget.MicronsPerPixel;

%Create directory if needed
if ~isfield(GuiGlobalsStruct, 'AlignedTargetListsDirectory')
    GuiGlobalsStruct.AlignedTargetListsDirectory = sprintf('%s\\AlignedTargetListsDirectory',GuiGlobalsStruct.UTSLDirectory);
end

if ~exist( GuiGlobalsStruct.AlignedTargetListsDirectory, 'dir')
    %[SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR)
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(GuiGlobalsStruct.UTSLDirectory, 'AlignedTargetListsDirectory');
    if ~SUCCESS
        MyStr = sprintf('Could not create: %s', GuiGlobalsStruct.AlignedTargetListsDirectory);
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
        uiwait(msgbox(MyStr));
        return;
    end

else
    return;
end

%Setup how many images will be averaged to align with
NumberOfPreviousImages = 10;
for i = 1:NumberOfPreviousImages
    PreviousImagesArray(i).Image = [];
end
MeanOfPreviousImages = [];

for WaferNameIndex = 1:length(GuiGlobalsStruct.ListOfWaferNames)
    
    AlignedTargetList.ListOfWaferNames  = GuiGlobalsStruct.ListOfWaferNames;
    
    
    WaferName = GuiGlobalsStruct.ListOfWaferNames{WaferNameIndex}
    CoarseSectionListFileNameStr = sprintf('%s\\%s\\FullWaferTileImages\\CoarseSectionList.mat',...
        GuiGlobalsStruct.UTSLDirectory, WaferName);
    load(CoarseSectionListFileNameStr,'CoarseSectionList');
    
    for SectionIndex = 1:length(CoarseSectionList);
        LabelStr = CoarseSectionList(SectionIndex).Label;
        
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
        figure(100);
        subplot(1,2,1);
        imshow(NewImage, [0,255]);
        MyStr = sprintf('%s, Section# %s',WaferName,LabelStr);
        title(MyStr);
        drawnow;
        
        AnglesInDegreesToTryArray = [-1 0 +1]; %Note: Should be pretty close from overview alignment
        if ~isempty(MeanOfPreviousImages)
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
        NewImage_shifted = 0*NewImage;
        [MaxR, MaxC] = size(NewImage_shifted)
        for r = 1:MaxR
            for c = 1:MaxC
                New_r = r + r_offset;
                New_c = c + c_offset;
                if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
                    NewImage_shifted(New_r, New_c) = NewImage(r,c);
                end
            end
        end
        
        subplot(1,2,2);
        imshow(NewImage_shifted, [0,255]);
        ImageFileNameStr = sprintf('%s\\LowResAligned_%s_Section_%s.tif',...
            NewDirectory, WaferName, LabelStr);
        MyStr = sprintf('Writing file: %s',ImageFileNameStr);
        disp(MyStr);
        imwrite(NewImage_shifted, ImageFileNameStr, 'tif');
            
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
        
      
      
      
    end
    
    
    
end


DataFileNameStr = sprintf('%s\\AlignedTargetList.mat',NewDirectory);
save(DataFileNameStr, 'AlignedTargetList');
