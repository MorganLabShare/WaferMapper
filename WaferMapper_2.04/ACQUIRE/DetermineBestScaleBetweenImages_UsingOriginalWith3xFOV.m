function [ FinalBestScale ] = DetermineBestScaleBetweenImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI,  ReImagedImage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

LargeScale = 1.07;
SmallScale = 0.93;


AnglesInDegreesToTryArray = [-2, -1,0, 1, 2];

OriginalImage_x3LargerROI_DummyMag = 1;
%Compute figure of merit for these two
ReImagedImage_DummyMag = LargeScale;
%function [Image1_scaled, Image2_scaled] = EqualizeMags_ForUseWith3xLargerFOV(Image1_x3LargerROI, Image2, ScalingFactorForImage2RelativeToImage1)
[OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI, ReImagedImage, ReImagedImage_DummyMag);
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_LargeScale] =...
    CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal(OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled, AnglesInDegreesToTryArray);

ReImagedImage_DummyMag = SmallScale;
[OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI, ReImagedImage, ReImagedImage_DummyMag);
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_SmallScale] =...
    CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal(OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled, AnglesInDegreesToTryArray);

%Binary search
for i = 1:5
    %Computer for middle
    MiddleScale = (LargeScale+SmallScale)/2;
    
    
    ReImagedImage_DummyMag = MiddleScale;
    [OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI, ReImagedImage, ReImagedImage_DummyMag);
    

    %function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = 
    %  CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI, NewImage, AnglesInDegreesToTryArray)
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_MiddleScale] =...
        CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal(OriginalImage_x3LargerROI_scaled, ReImagedImage_scaled, AnglesInDegreesToTryArray);
    
    
    
    if FigureOfMerit_LargeScale > FigureOfMerit_SmallScale
        SmallScale = MiddleScale;
        FigureOfMerit_SmallScale = FigureOfMerit_MiddleScale;
    else
        LargeScale = MiddleScale;
        FigureOfMerit_LargeScale = FigureOfMerit_MiddleScale;
    end
end

if FigureOfMerit_LargeScale > FigureOfMerit_SmallScale
    FinalBestScale =  LargeScale;
else
    FinalBestScale =  SmallScale;
end
      
