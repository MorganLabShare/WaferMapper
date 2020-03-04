%QuickTestOfAligningTwoImages

clear all
close all

OriginalImage_x3LargerROI_Filtered = imread('LowResAligned_x3LargerROI_w008_Section_1.tif');
%CurrentImage_Filtered = imread('LowResAligned_w008_Section_1.tif');
%CurrentImage_Filtered = imread('Image_365x_365y_1scale_0angle.tif');
%CurrentImage_Filtered = imread('Image_385x_345y_1scale_0angle.tif');
%CurrentImage_Filtered = imread('Image_365x_365y_1scale_2angle.tif');
CurrentImage_Filtered = imread('Image_392x_392y_1.05scale_0angle.tif');




figure(987);
subplot(1,2,1);
imshow(OriginalImage_x3LargerROI_Filtered,[0,255]);
title('OriginalImage_x3LargerROI_Filtered');

subplot(1,2,2);
imshow(CurrentImage_Filtered,[0,255]);
title('CurrentImage_Filtered');




ScalesToTryArray = linspace(0.95, 1.05,  11);
%ScalesToTryArray = linspace(0.95, 1.05,  3);




FigureOfMerit_BestSoFar = -100000000;
for i = 1:length(ScalesToTryArray)
    [OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI_Filtered, CurrentImage_Filtered, ScalesToTryArray(i));

    AnglesInDegreesToTryArray = [-2, -1,0, 1, 2];
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
        CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled, AnglesInDegreesToTryArray);
    
    if FigureOfMerit > FigureOfMerit_BestSoFar
        FigureOfMerit_BestSoFar = FigureOfMerit;
        XOffsetOfNewInPixels_Best = XOffsetOfNewInPixels;
        YOffsetOfNewInPixels_Best = YOffsetOfNewInPixels;
        Scale_Best = ScalesToTryArray(i); 
        AngleOffsetOfNewInDegrees_Best = AngleOffsetOfNewInDegrees;
        
        OriginalImage_x3LargerROI_Filtered_Scaled_BestScaleSoFar = OriginalImage_x3LargerROI_Filtered_Scaled;
        CurrentImage_Filtered_Scaled_BestScaleSoFar = CurrentImage_Filtered_Scaled;
    end
end

%disp('Final best values');
XOffsetOfNewInPixels = XOffsetOfNewInPixels_Best
YOffsetOfNewInPixels = YOffsetOfNewInPixels_Best
AngleOffsetOfNewInDegrees = AngleOffsetOfNewInDegrees_Best
Scale_Best



PlotRedGreenOverlapOfTwoImages_x3FOV(OriginalImage_x3LargerROI_Filtered_Scaled_BestScaleSoFar, CurrentImage_Filtered_Scaled_BestScaleSoFar, XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees)
