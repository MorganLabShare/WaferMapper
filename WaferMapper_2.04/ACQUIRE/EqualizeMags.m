function [Image1_scaled, Image2_scaled] = EqualizeMags(Image1, MagOfImage1, Image2, MagOfImage2)

if MagOfImage2 < MagOfImage1  %scale up Image2
    ScalingFactor = MagOfImage1/MagOfImage2;
    ImageToScale = Image2;
else
    ScalingFactor = MagOfImage2/MagOfImage1;
    ImageToScale = Image1;
end

[h, w] = size(ImageToScale);
ScaledImage = imresize(ImageToScale, ScalingFactor, 'bilinear');

%This image now has too many pixels, it must be cropped to original size
[h2, w2] = size(ScaledImage);
r_start = floor((h2-h)/2)+1;
c_start = floor((w2-w)/2)+1;
ScaledImage_cropped = ScaledImage(r_start:(r_start+h-1), c_start:(c_start+w-1));

if MagOfImage2 < MagOfImage1
    Image1_scaled = Image1;
    Image2_scaled = ScaledImage_cropped;
else
    Image1_scaled = ScaledImage_cropped;
    Image2_scaled = Image2;
end

end

