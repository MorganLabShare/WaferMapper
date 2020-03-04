function [] = PlotRedGreenOverlapOfTwoImages(OriginalImage, CurrentImage, XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees)

r_offset_final = YOffsetOfNewInPixels; %Note: Here is where the reversed Y-Axis sign change is fixed
c_offset_final = -XOffsetOfNewInPixels;




[HeightImage, WidthImage] = size(OriginalImage);
[HeightImageNew, WidthImageNew] = size(CurrentImage);
if (HeightImageNew ~= HeightImage) || (WidthImageNew ~= WidthImage) || (HeightImage ~= WidthImage)
   disp('Images must be the same size and be square. Quiting...');
   lsdjfdsjf
end


%First make an image with a width 3x the original and fill in with
%background average (this is to allow a good convolution). Note: should make
%sure that the background of a good fiducial is always uniform anyway
OriginalImage_3xSizeWithFilledInBackground = uint8(zeros(3*HeightImage,3*WidthImage));
avg1 = mean(OriginalImage(1,1:end));
avg2 = mean(OriginalImage(end,1:end));
avg3 = mean(OriginalImage(1:end,1));
avg4 = mean(OriginalImage(1:end,end));
AvgOrigBackground = mean([avg1 avg2 avg3 avg4]);
OriginalImage_3xSizeWithFilledInBackground(:,:) =  AvgOrigBackground;
OriginalImage_3xSizeWithFilledInBackground(HeightImage+1:(end-HeightImage), WidthImage+1:(end-WidthImage)) =...
    OriginalImage;


%preallocate ColorCombinedImage array to be size of SubImageForAreaToMatch but colored
ColorCombinedImage(:,:,1) = 0*OriginalImage_3xSizeWithFilledInBackground;
ColorCombinedImage(:,:,2) = 0*OriginalImage_3xSizeWithFilledInBackground;
ColorCombinedImage(:,:,3) = 0*OriginalImage_3xSizeWithFilledInBackground;

OriginalImage_3xSizeWithFilledInBackground_rotated = imrotate(OriginalImage_3xSizeWithFilledInBackground,AngleOffsetOfNewInDegrees,'crop');

ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
ColorCombinedImage(HeightImage+1+r_offset_final:(end-HeightImage)+r_offset_final,...
    WidthImage+1+c_offset_final:(end-WidthImage)+c_offset_final,1) = CurrentImage;


ColorCombinedImage(:,:,2) = OriginalImage_3xSizeWithFilledInBackground_rotated; %green
ColorCombinedImage(:,:,3) = 0*OriginalImage_3xSizeWithFilledInBackground_rotated; %blue

figure(1287);
imshow(ColorCombinedImage);

TitleStr = sprintf('(x,y) Offset = (%d, %d) pixels, Angle Offset = %d degrees',XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees);
title(TitleStr);
pause(1);