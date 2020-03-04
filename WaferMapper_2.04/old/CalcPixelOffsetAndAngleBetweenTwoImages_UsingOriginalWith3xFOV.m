function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginalWith3xFOV(OriginalImage_x3LargerROI, NewImage, AnglesInDegreesToTryArray)

[HeightImage, WidthImage] = size(NewImage);
[Height_x3LargerROI_Image, Width_x3LargerROI_Image] = size(OriginalImage_x3LargerROI);

%NewImage = uint8(HighPassFilterImage(NewImage, 1));
%OriginalImage_x3LargerROI = uint8(HighPassFilterImage(OriginalImage_x3LargerROI, 1));







% I2 = IMCROP(I,RECT)
%        X2 = IMCROP(X,MAP,RECT)
%  
%     RECT is a 4-element vector with the form [XMIN YMIN WIDTH HEIGHT


if (Height_x3LargerROI_Image ~= 3*HeightImage) || (Width_x3LargerROI_Image ~= 3*WidthImage) || (HeightImage ~= WidthImage)
   disp('Images must be the same size and be square. Quiting...');
   lsdjfdsjf
end


IsPlotResults = true; %true



if IsPlotResults
    h_fig = figure(888);
    
    %preallocate ColorCombinedImage array to be size of SubImageForAreaToMatch but colored
    ColorCombinedImage(:,:,1) = 0*OriginalImage_x3LargerROI;
    ColorCombinedImage(:,:,2) = 0*OriginalImage_x3LargerROI;
    ColorCombinedImage(:,:,3) = 0*OriginalImage_x3LargerROI;
end

MaxSoFar = -1000000000;
for i = 1:length(AnglesInDegreesToTryArray)

    OriginalImage_x3LargerROI_rotated = imrotate(OriginalImage_x3LargerROI,AnglesInDegreesToTryArray(i),'crop');

    if IsPlotResults
        
        %First display the SubImageForTemplate in red centered on the SubImageForAreaToMatch in green
        ColorCombinedImage(HeightImage+1:(end-HeightImage), WidthImage+1:(end-WidthImage),1) = NewImage; %red (centered template)
        ColorCombinedImage(:,:,2) = OriginalImage_x3LargerROI_rotated; %green
        ColorCombinedImage(:,:,3) = 0*OriginalImage_x3LargerROI_rotated; %blue
        
        figure(h_fig);
        subplot(1,3,1);
        imshow(ColorCombinedImage);
    end
    
    %Compute correlation between images (includes a lot of regions that are not valid)
    if (sum(NewImage(:)-mean(NewImage(:))))
            C = normxcorr2(NewImage, OriginalImage_x3LargerROI_rotated);

        
    else %make dummy C
            C = zeros(size(NewImage)*2);
            C(round(size(C,1)/2),round(size(C,2)/2)) = 1000;
    end
    
    %Extract only the region of C that used entire template for corr
    [Width_C, dummy] = size(C);
    
    C_ValidRegion = C(WidthImage+1:Width_C-(WidthImage-1), WidthImage+1:Width_C-(WidthImage-1));


    if IsPlotResults
        figure(h_fig);
        subplot(1,3,2);
        imagesc(C_ValidRegion);
    end
    
    %Pick out the row col of the peak
    [max_C_ValidRegion, imax] = max(C_ValidRegion(:))
    [rpeak, cpeak] = ind2sub(size(C_ValidRegion),imax(1));
    [WidthValidRegion, dummy] = size(C_ValidRegion);
    r_offset = rpeak - WidthValidRegion/2;
    c_offset = cpeak - WidthValidRegion/2;
    
    if IsPlotResults
        %Display the corrected postion of the template
        ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
        ColorCombinedImage(HeightImage+1+r_offset:(end-HeightImage)+r_offset,...
            WidthImage+1+c_offset:(end-WidthImage)+c_offset,1) = NewImage;
        
        figure(h_fig);
        subplot(1,3,3);
        imshow(ColorCombinedImage);
    end
    
    %image((C_ValidRegion>(max_C_ValidRegion*.5))*1000),pause(.1)
    
    
    
    if max_C_ValidRegion > MaxSoFar
        MaxSoFar = max_C_ValidRegion;
        r_offset_final = r_offset;
        c_offset_final = c_offset;
        i_final = i;
        %bestCorrImage = C_ValidRegion;
    end
    
end



if IsPlotResults
%     h_fig = figure(999);
%     %display final best result
    clf;
    
    OriginalImage_x3LargerROI_rotated = imrotate(OriginalImage_x3LargerROI,AnglesInDegreesToTryArray(i_final),'crop');
    
    ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
    ColorCombinedImage(HeightImage+1+r_offset_final:(end-HeightImage)+r_offset_final,...
            WidthImage+1+c_offset_final:(end-WidthImage)+c_offset_final,1) = NewImage;
    

    ColorCombinedImage(:,:,2) = OriginalImage_x3LargerROI_rotated; %green
    ColorCombinedImage(:,:,3) = 0*OriginalImage_x3LargerROI_rotated; %blue
    
    figure(h_fig);
    imshow(ColorCombinedImage);
    pause(1);
end


YOffsetOfNewInPixels = r_offset_final; %Note: Here is where the reversed Y-Axis sign change is fixed
XOffsetOfNewInPixels = -c_offset_final;
AngleOffsetOfNewInDegrees = AnglesInDegreesToTryArray(i_final);





FigureOfMerit = MaxSoFar;

if exist('h_fig','var')
    if ishandle(h_fig)
        close(h_fig);
    end
end

end



