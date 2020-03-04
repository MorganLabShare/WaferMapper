function [ OutputImage ] = HighPassFilterImage( InputImage,  FilterMaskRadius)
%FilterMaskRadius = 1;

%Highpass filter
Temp_Image = fftshift(fft2(InputImage));
[EndIndex,dummy] = size(Temp_Image);
CenterIndex = ((EndIndex-1)/2)+1;


for i = 1:EndIndex
    for j = 1:EndIndex
        if( sqrt((i-CenterIndex)^2 + (j-CenterIndex)^2) <= FilterMaskRadius)
            Temp_Image(i,j) = 0;
        end
    end
end

%Temp_Image( (CenterIndex-1):(CenterIndex+1) ,(CenterIndex-1):(CenterIndex+1) ) = 0;

OutputImage = abs(ifft2(Temp_Image));

IsDisplay = true;
if IsDisplay
    figure;
    subplot(1,3,1);
    imshow(InputImage,[0 255]);
    title('InputImage');
    
    subplot(1,3,2);
    imagesc(abs(Temp_Image));
    colorbar;
    title('Masked FFT2');
    
    subplot(1,3,3);
    imshow(OutputImage,[0 255]);
    title('OutputImage');
end

