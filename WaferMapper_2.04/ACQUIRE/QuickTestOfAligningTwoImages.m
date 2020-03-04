%QuickTestOfAligningTwoImages

clear all
close all

OriginalImage_Filtered = imread('Fiducial_01_ORIGINAL.tif');
%CurrentImage_Filtered = imread('LowResAligned_w008_Section_1.tif');
%CurrentImage_Filtered = imread('Image_365x_365y_1scale_0angle.tif');
%CurrentImage_Filtered = imread('Image_385x_345y_1scale_0angle.tif');
%CurrentImage_Filtered = imread('Image_365x_365y_1scale_2angle.tif');
CurrentImage_Filtered = imread('Fiducial_01_RETAKE.tif');



figure(987);
subplot(1,2,1);
imshow(OriginalImage_Filtered,[0,255]);
title('OriginalImage_Filtered');

subplot(1,2,2);
imshow(CurrentImage_Filtered,[0,255]);
title('CurrentImage_Filtered');




%ScalesToTryArray = linspace(0.95, 1.05,  11);
ScalesToTryArray = linspace(0.95, 1.05,  3);




FigureOfMerit_BestSoFar = -100000000;
for i = 1:length(ScalesToTryArray)
    [OriginalImage_Filtered_Scaled, CurrentImage_Filtered_Scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_Filtered, CurrentImage_Filtered, ScalesToTryArray(i));

    %AnglesInDegreesToTryArray = [-2, -1,0, 1, 2];
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
        CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage_Filtered_Scaled, CurrentImage_Filtered_Scaled); %, AnglesInDegreesToTryArray);
    
    if FigureOfMerit > FigureOfMerit_BestSoFar
        FigureOfMerit_BestSoFar = FigureOfMerit;
        XOffsetOfNewInPixels_Best = XOffsetOfNewInPixels;
        YOffsetOfNewInPixels_Best = YOffsetOfNewInPixels;
        Scale_Best = ScalesToTryArray(i); 
        AngleOffsetOfNewInDegrees_Best = AngleOffsetOfNewInDegrees;
        
        OriginalImage_Filtered_Scaled_BestScaleSoFar = OriginalImage_Filtered_Scaled;
        CurrentImage_Filtered_Scaled_BestScaleSoFar = CurrentImage_Filtered_Scaled;
    end
end

%disp('Final best values');
XOffsetOfNewInPixels = XOffsetOfNewInPixels_Best
YOffsetOfNewInPixels = YOffsetOfNewInPixels_Best
AngleOffsetOfNewInDegrees = AngleOffsetOfNewInDegrees_Best
Scale_Best



PlotRedGreenOverlapOfTwoImages(OriginalImage_Filtered_Scaled_BestScaleSoFar, CurrentImage_Filtered_Scaled_BestScaleSoFar, XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees)
