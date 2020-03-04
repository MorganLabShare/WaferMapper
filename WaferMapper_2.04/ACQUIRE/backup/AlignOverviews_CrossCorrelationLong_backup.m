%AlignOverviews

start = tic;

alignSize = 512;

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
%uiwait(msgbox(MyStr));
pause(.01);

GuiGlobalsStruct.IsUserCancelWaitBar = false;
% GuiGlobalsStruct.h_waitbar = waitbar(0,'Aligning sections...',  'WindowStyle' , 'modal', 'CreateCancelBtn', 'UserCancelWaitBar();');
showFrame = figure;
AP(MaxLabelNum).AlignmentParameters = [];
for i = 1:MaxLabelNum
    disp(sprintf('Aligning section %d of %d', i,MaxLabelNum));
    
%     if exist('SecondsToAlignedPreviousSection', 'var')
%         UpdatedMessageStr = sprintf('Aligning section# %d of %d. Time to complete %0.5g minutes', i, MaxLabelNum, ...
%             ((MaxLabelNum-(i-1))*SecondsToAlignedPreviousSection)/60);
%     else
%         UpdatedMessageStr = sprintf('Aligning section# %d of %d. Time to complete ...', i, MaxLabelNum);
%     end
%     waitbar(i/MaxLabelNum,GuiGlobalsStruct.h_waitbar, UpdatedMessageStr);
%     if GuiGlobalsStruct.IsUserCancelWaitBar
%         return;
%     end
%      
    StartTimeOfThisSection = tic;
    
    Label = num2str(i);
    %load overview image and apply light filtering
    OverviewImageFileNameStr = sprintf('%s\\SectionOverview_%s.tif',GuiGlobalsStruct.SectionOverviewsDirectory,Label);
    disp(sprintf('   Loading image file: %s',OverviewImageFileNameStr));
    OverviewImage = imread(OverviewImageFileNameStr,'tif');
    OverviewImage = double(OverviewImage);
    
    TocAfterRead = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to read this section %0.5g seconds', TocAfterRead));
    
    %START: KH Make background average value code 9_17_2011 
    [MaxR, MaxC] = size(OverviewImage);
    Temp1 = mean(OverviewImage(1:MaxR, 1));
    Temp2 = mean(OverviewImage(1:MaxR, MaxC));
    Temp3 = mean(OverviewImage(1, 1:MaxC));
    Temp4 = mean(OverviewImage(MaxR, 1:MaxC));
    AverageBorderGrayScale = uint8((Temp1 + Temp2 + Temp3 + Temp4)/4);
    %END: KH Make background average value code 9_17_2011 
    OverviewImage = imfilter(OverviewImage,H_gaussian);
    
    %downsample
    %Determine downsample factor
    [TempWidth, dummy] = size(OverviewImage);
    DSFactor = ceil(TempWidth/alignSize); %ceil(TempWidth/256);%ceil(TempWidth/512);%Note: this will always make sure that the max image size to the alignment routine is 512x512
    %DSFactor = 8;
    
    %%
    OriginalImageDS = imresize(CenteredTemplateImage,1/DSFactor,'bilinear'); %Must down sample by 8x to prevent out of memory error on fibics computer
    ReImagedImageDS = imresize(OverviewImage,1/DSFactor,'bilinear');
    
%     Filter Downsampled images
    OriginalImageDS = mexHatSection(OriginalImageDS);
    ReImagedImageDS = mexHatSection(ReImagedImageDS);
    
   
    
    %image(ReImagedImageDS)
    %%
    TocAfterPreProcessing = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to pre process this section %0.5g seconds', TocAfterPreProcessing - TocAfterRead));
    
    %Determine angle and offset
    CenterAngle = GuiGlobalsStruct.SectionOverviewProcessingParameters.CenterAngle;
    AngleIncrement = GuiGlobalsStruct.SectionOverviewProcessingParameters.AngleIncrement;
    NumMultiResSteps = GuiGlobalsStruct.SectionOverviewProcessingParameters.NumMultiResSteps;
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] =...
        CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImageDS, ReImagedImageDS,...
        CenterAngle, AngleIncrement, NumMultiResSteps);
    
    TocAfterCalcAlignment = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to calculate alignment this section %0.5g seconds', TocAfterCalcAlignment - TocAfterPreProcessing));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display and save results ( OverviewImage, CenteredTemplateImage_BlackBoardersForDisplay)
    AngleOffsetInDegrees = -AngleOffsetOfNewInDegrees;
    
    %START: KH Make background average value code 9_17_2011
    %     [MaxR, MaxC] = size(OverviewImage);
    %     for r = 1:MaxR
    %         for c = 1:MaxC
    %            if OverviewImage(r,c) == 0;
    %              OverviewImage(r,c) = 1; %Bump all original black pixels up to a 1 value
    %            end
    %         end
    %     end
    %Fast matlab code to do same: A(A==0) = 1
    OverviewImage(OverviewImage==0) = 1;
    %END: KH Make background average value code 9_17_2011
    
    TocAfterChangeBackground = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to change background this section %0.5g seconds', TocAfterChangeBackground - TocAfterCalcAlignment));
    
    OverviewImage_rotated = imrotate(OverviewImage,AngleOffsetInDegrees,'crop'); %note negative on angle
    
    TocAfterRotate = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to rotate this section %0.5g seconds', TocAfterRotate - TocAfterChangeBackground));
    
    %Start: handle coord transform reordering
    AngleOffsetInRadians = AngleOffsetInDegrees*(pi/180);
    XOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*cos(AngleOffsetInRadians) - YOffsetOfNewInPixels*sin(AngleOffsetInRadians);
    YOffsetOfNewInPixels_Transformed = XOffsetOfNewInPixels*sin(AngleOffsetInRadians) + YOffsetOfNewInPixels*cos(AngleOffsetInRadians);
    %End: handle coord transform reordering 
    
    r_offset = YOffsetOfNewInPixels_Transformed*DSFactor; %Note: Here is where the reversed Y-Axis sign change is fixed
    c_offset = - XOffsetOfNewInPixels_Transformed*DSFactor;
    OverviewImage_rotated_shifted = 0*OverviewImage_rotated;
    [MaxR, MaxC] = size(OverviewImage_rotated);
    for r = 1:MaxR
        for c = 1:MaxC
            New_r = round(r + r_offset);
            New_c = round(c + c_offset);
            if (New_r > 0) && (New_r <=MaxR) && (New_c > 0) && (New_c <=MaxC)
                OverviewImage_rotated_shifted(New_r, New_c) = OverviewImage_rotated(r,c);
            end
        end
    end
    
%     image(OverviewImage_rotated_shifted);
%     'showing shifted rotated'
%     pause(.1)
    
    TocAfterShift = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to shift this section %0.5g seconds', TocAfterShift - TocAfterRotate));
    
    
    %START: KH Make background average value code 9_17_2011
    %     [MaxR, MaxC] = size(OverviewImage_rotated_shifted);
    %     for r = 1:MaxR
    %         for c = 1:MaxC
    %            if OverviewImage_rotated_shifted(r,c) == 0;
    %              OverviewImage_rotated_shifted(r,c) = AverageBorderGrayScale; %fill in all transform produced border pixels with original background average
    %            end
    %         end
    %     end
    %Fast matlab code to do same: A(A==0) = 1
    OverviewImage_rotated_shifted(OverviewImage_rotated_shifted==0) = AverageBorderGrayScale;
    %END: KH Make background average value code 9_17_2011 
     figure(showFrame)
    subplot(1,3,1)
    image(OriginalImageDS)
    subplot(1,3,2)
    image(ReImagedImageDS)
    colormap gray(256)
    pause(.01)
    figure(showFrame)
    subplot(1,3,3)
    image(OverviewImage_rotated_shifted)
    
    
    TocAfterBackgoundToAverage = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to set background to average this section %0.5g seconds', TocAfterBackgoundToAverage - TocAfterShift));
    
    %GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory = 'C:\MasterUTSLDirectory\CortexUTSL004\Wafer005\SectionOverviewsAlignedWithTemplateDirectory';
    OverviewImageAlignedFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.tif',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
    OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,Label);
    
     
    imwrite(uint8(OverviewImage_rotated_shifted),OverviewImageAlignedFileNameStr,'tif');
    AP(i).AlignmentParameters.r_offset = r_offset;
    AP(i).AlignmentParameters.c_offset = c_offset;
    AP(i).AlignmentParameters.AngleOffsetInDegrees = AngleOffsetInDegrees;
    AlignmentParameters = AP(i).AlignmentParameters;
    save(OverviewAlignedDataFileNameStr, 'AlignmentParameters');
    
    TocAfterImwriteProcessing = toc(StartTimeOfThisSection);
    disp(sprintf('   Time to write new image file for this section %0.5g seconds', TocAfterImwriteProcessing - TocAfterBackgoundToAverage));
    
%     ColorCombinedImage(:,:,1) = OverviewImage_rotated_shifted;
%     ColorCombinedImage(:,:,2) = CenteredTemplateImage;
%     ColorCombinedImage(:,:,3) = 0*ColorCombinedImage(:,:,1);
%     figure(555);
%     imshow(ColorCombinedImage);
    
    TocAfterAllProcessing = toc(StartTimeOfThisSection);
    disp(sprintf('   Time for full processing of this section %0.5g seconds', TocAfterAllProcessing));
    
    
    SecondsToAlignedPreviousSection = TocAfterAllProcessing;
end

close(showFrame)
% 
% if ishandle(GuiGlobalsStruct.h_waitbar)
%      delete(GuiGlobalsStruct.h_waitbar);
% end


