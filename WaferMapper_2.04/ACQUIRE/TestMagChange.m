

Image1 = imread('Z:\Hayworth\MasterUTSLDirectory\WormEmbryoUTSL\w10\LowResFiducialsDirectory\Fiducial_01.tif', 'tif');
load Z:\Hayworth\MasterUTSLDirectory\WormEmbryoUTSL\w10\LowResFiducialsDirectory\Fiducial_01.mat;
MagOfImage1 = Info.Mag;
Image2 = imread('Z:\Hayworth\MasterUTSLDirectory\WormEmbryoUTSL\w10\ReimageLowResFiducialsDirectory\Fiducial_01.tif', 'tif');
load Z:\Hayworth\MasterUTSLDirectory\WormEmbryoUTSL\w10\ReimageLowResFiducialsDirectory\Fiducial_01.mat;
MagOfImage2 = Info.Mag;

[Image1_scaled, Image2_scaled] = EqualizeMags(Image1, MagOfImage1, Image2, MagOfImage2);

figure(333);
subplot(1,2,1);
imshow(Image1_scaled);
subplot(1,2,2);
imshow(Image2_scaled);


% ScalingFactor = 1.3;
% MyImage_color = imread('MagTestImage.tif','tif');
% MyImage = MyImage_color(:,:,1);
% [h, w] = size(MyImage)
% 
% MyImage2 = imresize(MyImage, ScalingFactor, 'bilinear');
% [h2, w2] = size(MyImage2)
% 
% r_start = round((h2-h)/2);
% c_start = round((w2-w)/2);
% MyImage2_cropped = [];
% MyImage2_cropped = MyImage2(r_start:(r_start+h), c_start:(c_start+w)); 
% 
% figure(333);
% subplot(1,3,1);
% imshow(MyImage);
% subplot(1,3,2);
% imshow(MyImage2);
% subplot(1,3,3);
% imshow(MyImage2_cropped);