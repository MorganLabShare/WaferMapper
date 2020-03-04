
Image_BSE_3x = imread('C:\PresentationsFolder\LabPresentation_11_1_2011\ExampleIBSCImages\temp\LowResAligned_x3LargerROI_w008_Section_80.tif', 'tif');
Image_BSE = imread('C:\PresentationsFolder\LabPresentation_11_1_2011\ExampleIBSCImages\temp\LowResAligned_w008_Section_80.tif', 'tif');
Image_InLensSE = imread('C:\PresentationsFolder\LabPresentation_11_1_2011\ExampleIBSCImages\temp\TempImage_80_3mmWD_InLens_1.7kV.tif', 'tif');




H_gaussian = fspecial('gaussian',[5 5],2);%fspecial('gaussian',[9 9],5); %fspecial('gaussian',[5 5],1.5);
Image_BSE_3x = imfilter(Image_BSE_3x,H_gaussian);
Image_BSE = imfilter(Image_BSE,H_gaussian);
Image_InLensSE = imfilter(Image_InLensSE,H_gaussian);

figure(1);
subplot(1,3,1);
imshow(Image_BSE_3x,[0,255]);
title('Image\_BSE\_3x');
subplot(1,3,2);
imshow(Image_BSE,[0,255]);
title('Image\_BSE');
subplot(1,3,3);
imshow(Image_InLensSE,[0,255]);
title('Image\_InLensSE');






%START: JOSH'S FILTER
[Image_BSE_3x_MexHatFiltered] = mexHatVessle(Image_BSE_3x);
Image_BSE_3x_MexHatFiltered = 255*(Image_BSE_3x_MexHatFiltered/max(max(Image_BSE_3x_MexHatFiltered)));

[Image_BSE_MexHatFiltered] = mexHatVessle(Image_BSE);
Image_BSE_MexHatFiltered = 255*(Image_BSE_MexHatFiltered/max(max(Image_BSE_MexHatFiltered)));

[Image_InLensSE_MexHatFiltered] = mexHatVessle(Image_InLensSE);
Image_InLensSE_MexHatFiltered = 255*(Image_InLensSE_MexHatFiltered/max(max(Image_InLensSE_MexHatFiltered)));

figure(2);
subplot(1,3,1);
imshow(Image_BSE_3x_MexHatFiltered,[0,255]);
title('Image\_BSE\_3x\_MexHatFiltered');
subplot(1,3,2);
imshow(Image_BSE_MexHatFiltered,[0,255]);
title('Image\_BSE\_MexHatFiltered');
subplot(1,3,3);
imshow(Image_InLensSE_MexHatFiltered,[0,255]);
title('Image\_InLensSE\_MexHatFiltered');


