function [] = PlotRedGreenOverlapOfTwoImages_x3FOV(OriginalImage_x3LargerROI, CurrentImage, XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees)

r_offset_final = YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
c_offset_final = -XOffsetOfNewInPixels;

[HeightImage, WidthImage] = size(CurrentImage);
%[Height_x3LargerROI_Image, Width_x3LargerROI_Image] = size(OriginalImage_x3LargerROI);

%preallocate ColorCombinedImage array to be size of SubImageForAreaToMatch but colored
ColorCombinedImage(:,:,1) = 0*OriginalImage_x3LargerROI;
ColorCombinedImage(:,:,2) = 0*OriginalImage_x3LargerROI;
ColorCombinedImage(:,:,3) = 0*OriginalImage_x3LargerROI;

OriginalImage_x3LargerROI_rotated = imrotate(OriginalImage_x3LargerROI,AngleOffsetOfNewInDegrees,'crop');

ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
ColorCombinedImage(HeightImage+1+r_offset_final:(end-HeightImage)+r_offset_final,...
    WidthImage+1+c_offset_final:(end-WidthImage)+c_offset_final,1) = CurrentImage;


ColorCombinedImage(:,:,2) = OriginalImage_x3LargerROI_rotated; %green
ColorCombinedImage(:,:,3) = 0*OriginalImage_x3LargerROI_rotated; %blue

figure(1287);
imshow(ColorCombinedImage);

TitleStr = sprintf('(x,y) Offset = (%d, %d) pixels, Angle Offset = %d degrees',XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees);
title(TitleStr);
pause(1);