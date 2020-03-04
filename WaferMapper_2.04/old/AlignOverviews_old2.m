%AlignOverviews

start = tic;

%load SectionOverviewTemplateCroppedFilledPeriphery.tif image, then apply light filtering
FileNameStr = sprintf('%s\\SectionOverviewTemplateCroppedFilledPeriphery.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
SectionOverviewTemplateCroppedFilled = imread(FileNameStr,'tif');
H_gaussian = fspecial('gaussian',[5 5],1.5); %fspecial('gaussian',[9 9],5); %fspecial('gaussian',[5 5],1.5);
CenteredTemplateImage = imfilter(SectionOverviewTemplateCroppedFilled,H_gaussian);

%determine max label in the SectionOverviewsDirectory
MaxLabelNum = -1;
DirList = dir(GuiGlobalsStruct.SectionOverviewsDirectory);
for i = 1:length(DirList)
    if length(DirList(i).name) > 5
        if strcmp(DirList(i).name(((end-length('.tif'))+1:end)), '.tif')
            %Extract Label
            Label = DirList(i).name(length('SectionOverview_')+1:end-4);
            LableNum = str2num(Label);
            if LableNum > MaxLabelNum
                MaxLabelNum = LableNum;
            end
        end
    end
end

MyStr = sprintf('About to process %d sections.', MaxLabelNum);
uiwait(msgbox(MyStr));

for i = 1:MaxLabelNum
    Label = num2str(i);
    %load overview image and apply light filtering
    OverviewImageFileNameStr = sprintf('%s\\SectionOverview_%s.tif',GuiGlobalsStruct.SectionOverviewsDirectory,Label);
    disp(sprintf('Loading image file: %s',OverviewImageFileNameStr));
    OverviewImage = imread(OverviewImageFileNameStr,'tif');
    OverviewImage = imfilter(OverviewImage,H_gaussian);
    
    %downsample
    %Determine downsample factor
    [TempWidth, dummy] = size(OverviewImage);
    DSFactor = ceil(TempWidth/256); %ceil(TempWidth/512);%Note: this will always make sure that the max image size to the alignment routine is 512x512
    %DSFactor = 8;
    OriginalImageDS = imresize(CenteredTemplateImage,1/DSFactor,'bilinear'); %Must down sample by 8x to prevent out of memory error on fibics computer
    ReImagedImageDS = imresize(OverviewImage,1/DSFactor,'bilinear');
    

    
    %Determine angle and offset
    CenterAngle = GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle;
    AngleIncrement = GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement;
    NumMultiResSteps = GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps;
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] =...
        CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImageDS, ReImagedImageDS,...
        CenterAngle, AngleIncrement, NumMultiResSteps)
    
%original bad code
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Display and save results ( OverviewImage, CenteredTemplateImage_BlackBoardersForDisplay)
%     AngleOffsetInDegrees = -AngleOffsetOfNewInDegrees
%     OverviewImage_rotated = imrotate(OverviewImage,AngleOffsetInDegrees,'crop'); %note negative on angle
%     r_offset = YOffsetOfNewInPixels*DSFactor; %Note: Here is where the reversed Y-Axis sign change is fixed
%     c_offset = - XOffsetOfNewInPixels*DSFactor;
%     OverviewImage_rotated_shifted = 0*OverviewImage_rotated;
%     [MaxR, MaxC] = size(OverviewImage_rotated)
%     for r = 1:MaxR
%         for c = 1:MaxC
%             New_r = r + r_offset;
%             New_c = c + c_offset;
%             if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
%                 OverviewImage_rotated_shifted(New_r, New_c) = OverviewImage_rotated(r,c);
%             end
%         end
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display and save results ( OverviewImage, CenteredTemplateImage_BlackBoardersForDisplay)
    AngleOffsetInDegrees = -AngleOffsetOfNewInDegrees
    OverviewImage_rotated = imrotate(OverviewImage,AngleOffsetInDegrees,'crop'); %note negative on angle
    
    %Start: handle coord transform reordering
    AngleOffsetInRadians = AngleOffsetInDegrees*(pi/180);
    XOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*cos(AngleOffsetInRadians) - YOffsetOfNewInPixels*sin(AngleOffsetInRadians);
    YOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*sin(AngleOffsetInRadians) + YOffsetOfNewInPixels*cos(AngleOffsetInRadians);
    %End: handle coord transform reordering 
    
    r_offset = YOffsetOfNewInPixels_Transformed*DSFactor; %Note: Here is where the reversed Y-Axis sign change is fixed
    c_offset = - XOffsetOfNewInPixels_Transformed*DSFactor;
    OverviewImage_rotated_shifted = 0*OverviewImage_rotated;
    [MaxR, MaxC] = size(OverviewImage_rotated)
    for r = 1:MaxR
        for c = 1:MaxC
            New_r = round(r + r_offset);
            New_c = round(c + c_offset);
            if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
                OverviewImage_rotated_shifted(New_r, New_c) = OverviewImage_rotated(r,c);
            end
        end
    end
    
    %GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory = 'C:\MasterUTSLDirectory\CortexUTSL004\Wafer005\SectionOverviewsAlignedWithTemplateDirectory';
    OverviewImageAlignedFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.tif',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
    OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
    
    imwrite(OverviewImage_rotated_shifted,OverviewImageAlignedFileNameStr,'tif');
    AlignmentParameters.r_offset = r_offset;
    AlignmentParameters.c_offset = c_offset;
    AlignmentParameters.AngleOffsetInDegrees = AngleOffsetInDegrees;
    save(OverviewAlignedDataFileNameStr, 'AlignmentParameters');
    
    
    ColorCombinedImage(:,:,1) = OverviewImage_rotated_shifted;
    ColorCombinedImage(:,:,2) = CenteredTemplateImage;
    ColorCombinedImage(:,:,3) = 0*ColorCombinedImage(:,:,1);
    figure(555);
    imshow(ColorCombinedImage);
    
    
    toc(start)
end




