function [Image1_scaled, Image2_scaled] = EqualizeMags_ForUseWith3xLargerFOV(Image1_x3LargerROI, Image2, ScalingFactorForImage2RelativeToImage1)

sc = 1/ScalingFactorForImage2RelativeToImage1;
I = Image1_x3LargerROI;
[ys1 xs1] = size(I);
I = imresize(I,sc);
[ys2 xs2] = size(I);

dify = ys2 - ys1;
difx = xs2 - xs1;
if dify>0;
    I2 = I(round(dify/2)+1:round(dify/2)+ys1, round(difx/2)+1:round(difx/2)+xs1);
elseif dify<0
    aby = abs(dify);
    abx = abs(difx);
    I2 = zeros(ys1,xs1,class(I))+median(I(:));
    I2(round(aby/2)+1:round(aby/2)+ys2, round(abx/2)+1:round(abx/2)+xs2) = I;
end

Image1_scaled = I2;
Image2_scaled = Image2;

%{ 
Old version
if ScalingFactorForImage2RelativeToImage1 > 1
    MyBool = true;
else
    MyBool = false;
end

if MyBool  %scale up Image2
    ScalingFactor = ScalingFactorForImage2RelativeToImage1;
    ImageToScale = Image2;
else %scale up Image1_x3LargerROI
    ScalingFactor = 1/ScalingFactorForImage2RelativeToImage1; %1/(((ScalingFactorForImage2RelativeToImage1-1)/3)+1);
    ImageToScale = Image1_x3LargerROI;
end

%ScalingFactor

[h, w] = size(ImageToScale);
ScaledImage = imresize(ImageToScale, ScalingFactor, 'bilinear');

%This image now has too many pixels, it must be cropped to original size
[h2, w2] = size(ScaledImage);
r_start = floor((h2-h)/2)+1;
c_start = floor((w2-w)/2)+1;
ScaledImage_cropped = ScaledImage(r_start:(r_start+h-1), c_start:(c_start+w-1));

if MyBool
    Image1_scaled = Image1_x3LargerROI;
    Image2_scaled = ScaledImage_cropped;
else
    Image1_scaled = ScaledImage_cropped;
    Image2_scaled = Image2;
end

end
%}

