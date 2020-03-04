function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = CalcPixelOffsetAndAngleBetweenTwoImages_UsingOriginal(OriginalImage, NewImage, AnglesInDegreesToTryArray)

[HeightNew, WidthNew] = size(NewImage);
[HeightOriginal, WidthOriginal] = size(OriginalImage);

%NewImage = uint8(HighPassFilterImage(NewImage, 1));
%OriginalImage = uint8(HighPassFilterImage(OriginalImage, 1));



% I2 = IMCROP(I,RECT)
%        X2 = IMCROP(X,MAP,RECT)
%  
%     RECT is a 4-element vector with the form [XMIN YMIN WIDTH HEIGHT


IsPlotResults = false;
IsPlotFinal = true;

    ColorCombinedImage = zeros(HeightOriginal*3,WidthOriginal * 3,3,'uint8');

if IsPlotResults | IsPlotFinal
    h_fig = figure(888);
    %preallocate ColorCombinedImage array to be size of SubImageForAreaToMatch but colored
end

MaxSoFar = -1000000000;
for i = 1:length(AnglesInDegreesToTryArray)

    OriginalImage_rotated = imrotate(OriginalImage,AnglesInDegreesToTryArray(i),'crop');

    if IsPlotResults
        
        %First display the SubImageForTemplate in red centered on the SubImageForAreaToMatch in green
        ColorCombinedImage(HeightOriginal+1:HeightOriginal+HeightNew, WidthOriginal+1:WidthOriginal+WidthNew,1) = NewImage; %red (centered template)
        ColorCombinedImage(HeightOriginal+1:HeightOriginal*2,WidthOriginal+1:WidthOriginal*2,2) = OriginalImage_rotated; %green
        ColorCombinedImage(HeightOriginal+1:HeightOriginal*2,WidthOriginal+1:WidthOriginal*2,3) = OriginalImage_rotated; %green
        
        figure(h_fig);
        subplot(1,3,1);
        imshow(ColorCombinedImage);
        pause(.01)
    end
    
    %Compute correlation between images (includes a lot of regions that are not valid)
    if sum(abs((NewImage(:)-mean(NewImage(:)))))
            C = normxcorr2(NewImage, OriginalImage_rotated);

        
    else %make dummy C
            C = zeros(size(NewImage)*2);
            C(round(size(C,1)/2),round(size(C,2)/2)) = 1000;
    end
    
    %Extract only the region of C that used entire template for corr
    [Width_C, dummy] = size(C);
    

    if IsPlotResults
        figure(h_fig);
        subplot(1,3,2);
        imagesc(C);
    end
    
    %Pick out the row col of the peak
    [max_C, imax] = max(C(:));
    [rpeak, cpeak] = ind2sub(size(C),imax(1));
    r_offset = rpeak - HeightNew;
    c_offset = cpeak - WidthNew;
    
    if IsPlotResults
        %Display the corrected postion of the template
        ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
        ColorCombinedImage(HeightOriginal+1+r_offset:HeightOriginal+r_offset + HeightNew,...
            WidthOriginal+1+c_offset:WidthOriginal+c_offset+WidthNew,1) = NewImage;
        
        figure(h_fig);
        subplot(1,3,3);
        imshow(ColorCombinedImage);
    end
    
    %image((C_ValidRegion>(max_C_ValidRegion*.5))*1000),pause(.1)
    
    
    
    if max_C > MaxSoFar
        MaxSoFar = max_C;
        r_offset_final = r_offset;
        c_offset_final = c_offset;
        i_final = i;
        %bestCorrImage = C_ValidRegion;
    end
    
end



if IsPlotFinal
%     h_fig = figure(999);
%     %display final best result
    clf;
    
    OriginalImage_rotated = imrotate(OriginalImage,AnglesInDegreesToTryArray(i_final),'crop');
    
    ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
      ColorCombinedImage(HeightOriginal+1+r_offset_final:HeightOriginal+r_offset_final + HeightNew,...
            WidthOriginal+1+c_offset_final:WidthOriginal+c_offset_final+WidthNew,1) = NewImage;
     ColorCombinedImage(HeightOriginal+1:HeightOriginal*2,WidthOriginal+1:WidthOriginal*2,2) = OriginalImage_rotated; %green
        ColorCombinedImage(HeightOriginal+1:HeightOriginal*2,WidthOriginal+1:WidthOriginal*2,3) = OriginalImage_rotated; %green
        
    figure(h_fig);
    imshow(ColorCombinedImage);
    pause(3);
    
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



