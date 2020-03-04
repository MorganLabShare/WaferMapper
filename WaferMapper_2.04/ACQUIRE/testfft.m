Image = imread('Z:\Hayworth\MasterUTSLDirectory\WormUTSL_02\w01\FullWaferTileImages\FullMapImage.tif','tif');
Image_fft = fft2(Image);

[MaxR, MaxC] = size(Image_fft);
CenterR = 1; %MaxR/2;
CenterC = 1; %MaxC/2;
Image_fft_CenterRemoved = Image_fft;
for RIndex = 1:MaxR
    for CIndex = 1:MaxC
        DistToCenter = sqrt( (RIndex - CenterR)^2 + (CIndex - CenterC)^2);
        if DistToCenter <= 2
            Image_fft_CenterRemoved(RIndex, CIndex) = 0;
        end
    end
end
        
Image_fft_Inverted = uint8(ifft2(Image_fft_CenterRemoved));

figure(345);
subplot(1,3,1);
imshow(Image);
subplot(1,3,2);
imshow(Image_fft_CenterRemoved);


subplot(1,3,3);
imshow(Image_fft_Inverted);
