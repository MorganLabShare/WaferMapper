function [ FinalBestScale ] = DetermineBestScaleBetweenImages(OriginalImage,  ReImagedImage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

LargeScale = 1.07;
SmallScale = 0.93;

%function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = ...
         %       CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage, NewImage, CenterAngle, AngleIncrement, NumMultiResSteps)
         CenterAngle = 0;
         AngleIncrement = 1;
         NumMultiResSteps = 1;


OriginalImage_DummyMag = 1;
%Compute figure of merit for these two
ReImagedImage_DummyMag = LargeScale;
[OriginalImage_scaled, ReImagedImage_scaled] = EqualizeMags(OriginalImage, OriginalImage_DummyMag, ReImagedImage, ReImagedImage_DummyMag);
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_LargeScale] =...
    CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage_scaled, ReImagedImage_scaled, CenterAngle, AngleIncrement, NumMultiResSteps);

ReImagedImage_DummyMag = SmallScale;
[OriginalImage_scaled, ReImagedImage_scaled] = EqualizeMags(OriginalImage, OriginalImage_DummyMag, ReImagedImage, ReImagedImage_DummyMag);
[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_SmallScale] =...
    CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage_scaled, ReImagedImage_scaled, CenterAngle, AngleIncrement, NumMultiResSteps);

%Binary search
for i = 1:5
    %Computer for middle
    MiddleScale = (LargeScale+SmallScale)/2;
    
    
    ReImagedImage_DummyMag = MiddleScale;
    [OriginalImage_scaled, ReImagedImage_scaled] = EqualizeMags(OriginalImage, OriginalImage_DummyMag, ReImagedImage, ReImagedImage_DummyMag);
    


    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit_MiddleScale] =...
        CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage_scaled, ReImagedImage_scaled, CenterAngle, AngleIncrement, NumMultiResSteps);
    
    
    
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
      
