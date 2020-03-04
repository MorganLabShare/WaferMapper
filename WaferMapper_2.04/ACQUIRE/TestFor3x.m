%Test of CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV()

LabelStr = '6';
WaferName = 'w007';
TempImageFileNameStr = sprintf('%s\\TempImage_%s.tif', '.', LabelStr); %TempImage_6.tif
CurrentImage = imread(TempImageFileNameStr, 'tif');
IsNeedToInvert = true;
if IsNeedToInvert
    CurrentImage = 255-CurrentImage;
end


ImageFile_x3LargerROI_NameStr = sprintf('%s\\LowResAligned_x3LargerROI_%s_Section_%s.tif',...
    '.' , WaferName,  LabelStr);
OriginalImage_x3LargerROI = imread(ImageFile_x3LargerROI_NameStr, 'tif');


H_gaussian = fspecial('gaussian',[3 3],1); %fspecial('gaussian',[9 9],5); %fspecial('gaussian',[5 5],1.5);
OriginalImage_x3LargerROI_Filtered = imfilter(OriginalImage_x3LargerROI,H_gaussian);
CurrentImage_Filtered = imfilter(CurrentImage,H_gaussian);


%uint8(imadjust(CurrentImage_Filtered,stretchlim(double(CurrentImage_Filtered)),[]));
CurrentImage_Filtered = imadjust(CurrentImage_Filtered);
OriginalImage_x3LargerROI_Filtered = imadjust(OriginalImage_x3LargerROI_Filtered);

figure(100);
subplot(1,2,1);
imshow(CurrentImage_Filtered, [0,255]);
subplot(1,2,2);
imshow(OriginalImage_x3LargerROI_Filtered, [0,255]);



ScalesToTryArray = linspace(0.94, 1.06, 13); %[0.96, 0.97, 0.98, 0.99, 1, 1.01,  1.02, 1.03, 1.04]; %[0.98, 1, 1.01, 1.02, 1.03, 1.04, 1.05];
FigureOfMerit_BestSoFar = -100000000;
FigureOfMerit_Array = [];
for i = 1:length(ScalesToTryArray)
    


    [OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled] = EqualizeMags_ForUseWith3xLargerFOV(OriginalImage_x3LargerROI_Filtered, CurrentImage_Filtered, ScalesToTryArray(i));

    
    %%% END: Correct for different mag %%%%%%%%%%%%%%%%%%%%%%%
    
   
    
    AnglesInDegreesToTryArray = [-2, -1,0, 1, 2];
    [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
        CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI_Filtered_Scaled, CurrentImage_Filtered_Scaled, AnglesInDegreesToTryArray)
    
    FigureOfMerit_Array(i) = FigureOfMerit;
    
    if FigureOfMerit > FigureOfMerit_BestSoFar
        FigureOfMerit_BestSoFar = FigureOfMerit;
        XOffsetOfNewInPixels_Best = XOffsetOfNewInPixels;
        YOffsetOfNewInPixels_Best = YOffsetOfNewInPixels;
        Scale_Best = ScalesToTryArray(i); 
        AngleOffsetOfNewInDegrees_Best = AngleOffsetOfNewInDegrees;
    end
end

disp('Final best values');
XOffsetOfNewInPixels = XOffsetOfNewInPixels_Best
YOffsetOfNewInPixels = YOffsetOfNewInPixels_Best
AngleOffsetOfNewInDegrees = AngleOffsetOfNewInDegrees_Best
Scale_Best


figure(326);
plot(ScalesToTryArray, FigureOfMerit_Array);
title('Figure of merit vs. scale');

% 
% AnglesInDegreesToTryArray = [-2, -1,0, 1, 2];
% [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
%     CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI_Filtered, CurrentImage_Filtered, AnglesInDegreesToTryArray)

