function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = ...
    CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage, NewImage, CenterAngle, AngleIncrement, NumMultiResSteps)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%[XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees] = DetermineAlignmentUsingSIFT(OriginalImage, NewImage);

%fill in default parameters if not supplied by calling function
if nargin < 5
    CenterAngle = 0; %always start at 0 deg
    AngleIncrement = 8;%4; %degrees    Start angles are [-4 0 +4]
    NumMultiResSteps = 4;   %Example [-4 0 +4] -> [-2 0 +2] -> [-3 -2 -1] -> [-2.5 -2 -1.5] -> found angle = -1.5deg
end


[HeightImage, WidthImage] = size(OriginalImage);
[HeightImageNew, WidthImageNew] = size(NewImage);
if (HeightImageNew ~= HeightImage) || (WidthImageNew ~= WidthImage) || (HeightImage ~= WidthImage)
   disp('Images must be the same size and be square. Quiting...');
end

ScaleFactor = 1/(2^(NumMultiResSteps-1)); %(1/8), (1/4), (1/2), (1)



angles{1} = [-170:5:180];
angles{2} = [-4:1:4];
angles{3} = [-.8:.2:.8];
angles{4} = [-.1:.05:.1];
NumMultiResSteps = length(angles);

for MultiResStepIndex = 1:NumMultiResSteps
    %B = IMRESIZE(A, [NUMROWS NUMCOLS])
    
    ScaleFactor = 1/(2^(NumMultiResSteps-MultiResStepIndex)); 
    %AnglesInDegreesToTryArray = [CenterAngle-2*AngleIncrement, CenterAngle-AngleIncrement,  CenterAngle,   CenterAngle+AngleIncrement ,   CenterAngle+2*AngleIncrement];
    
    AnglesInDegreesToTryArray = angles{MultiResStepIndex} + CenterAngle;
    
    OriginalImageDownsampled =...
        imresize(OriginalImage,[HeightImage*ScaleFactor, WidthImage*ScaleFactor],'bilinear');
    NewImageDownsampled =...
        imresize(NewImage,[HeightImage*ScaleFactor, WidthImage*ScaleFactor],'bilinear');

    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
        CalcPixelOffsetAndAngleBetweenTwoImages(OriginalImageDownsampled, NewImageDownsampled, AnglesInDegreesToTryArray); %NOTE: just take FIgureOfMerit of last
    
    %Prepare for next cycle centered on the found angle
    ScaleFactor = 2*ScaleFactor;
    AngleIncrement = AngleIncrement/2;
    CenterAngle = AngleOffsetOfNewInDegrees;
end



%Note: Returns [XOffsetOfNewInPixels, YOffsetOfNewInPixels,
%AngleOffsetOfNewInDegrees] from last iteration of above loop


end

