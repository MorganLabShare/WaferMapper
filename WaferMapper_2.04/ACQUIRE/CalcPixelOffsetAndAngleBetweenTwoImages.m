function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = CalcPixelOffsetAndAngleBetweenTwoImages(OriginalImage, NewImage, AnglesInDegreesToTryArray)


%AnglesInDegreesToTryArray = linspace(-6,6,5); %-7 to 7 degrees in 1 degree
%increments

[HeightImage, WidthImage] = size(OriginalImage);
[HeightImageNew, WidthImageNew] = size(NewImage);
if (HeightImageNew ~= HeightImage) || (WidthImageNew ~= WidthImage) || (HeightImage ~= WidthImage)
   disp('Images must be the same size and be square. Quiting...');
   lsdjfdsjf
end


%First make an image with a width 3x the original and fill in with
%background average (this is to allow a good convolution). Note: should make
%sure that the background of a good fiducial is always uniform anyway
OriginalImage_3xSizeWithFilledInBackground = uint8(zeros(3*HeightImage,3*WidthImage));
% avg1 = mean(OriginalImage(1,1:end));
% avg2 = mean(OriginalImage(end,1:end));
% avg3 = mean(OriginalImage(1:end,1));
% avg4 = mean(OriginalImage(1:end,end));
% AvgOrigBackground = mean([avg1 avg2 avg3 avg4]);
AvgOrigBackground = median(OriginalImage(:));
OriginalImage_3xSizeWithFilledInBackground(:,:) =  AvgOrigBackground;
OriginalImage_3xSizeWithFilledInBackground(HeightImage+1:(end-HeightImage), WidthImage+1:(end-WidthImage)) =...
    OriginalImage;





[WidthOriginalImage_3xSize, dummy] = size(OriginalImage_3xSizeWithFilledInBackground);
[WidthNewImage, dummy] = size(NewImage);


IsPlotResults = false; %true

if IsPlotResults
    h_fig = figure(888);
    
    %preallocate ColorCombinedImage array to be size of SubImageForAreaToMatch but colored
    ColorCombinedImage(:,:,1) = 0*OriginalImage_3xSizeWithFilledInBackground;
    ColorCombinedImage(:,:,2) = 0*OriginalImage_3xSizeWithFilledInBackground;
    ColorCombinedImage(:,:,3) = 0*OriginalImage_3xSizeWithFilledInBackground;
end

MaxSoFar = -1000000000;
for i = 1:length(AnglesInDegreesToTryArray)

    OriginalImage_3xSizeWithFilledInBackground_rotated = imrotate(OriginalImage_3xSizeWithFilledInBackground,AnglesInDegreesToTryArray(i),'crop');

%     if IsPlotResults
%         
%         %First display the SubImageForTemplate in red centered on the SubImageForAreaToMatch in green
%         ColorCombinedImage(HeightImage+1:(end-HeightImage), WidthImage+1:(end-WidthImage),1) = NewImage; %red (centered template)
%         ColorCombinedImage(:,:,2) = OriginalImage_3xSizeWithFilledInBackground_rotated; %green
%         ColorCombinedImage(:,:,3) = 0*OriginalImage_3xSizeWithFilledInBackground_rotated; %blue
%         
%         figure(h_fig);
%         subplot(1,3,1);
%         imshow(ColorCombinedImage);
%     end
    
    %Note normxcorr2 will crash if fed a template (NewImage) with all same
    %values. Check for this condition and substitute a random noise image
    %in its place
    if min(min(NewImage)) == max(max(NewImage))
        disp('***** BLANK IMAGE FOUND. *****');
        [MR, MC] = size(NewImage);
        NoiseAddedToNewImage = uint8(10+10*rand(MR, MC));
        C = normxcorr2(NoiseAddedToNewImage, OriginalImage_3xSizeWithFilledInBackground_rotated);
        %C = corrcoef(NoiseAddedToNewImage, OriginalImage_3xSizeWithFilledInBackground_rotated);
        %C = NoiseAddedToNewImage.* OriginalImage_3xSizeWithFilledInBackground_rotated;
    else
        %Compute correlation between images (includes a lot of regions that are not valid)
        C = normxcorr2(NewImage, OriginalImage_3xSizeWithFilledInBackground_rotated);
        %C = corrcoef(NewImage, OriginalImage_3xSizeWithFilledInBackground_rotated);
        %C = NewImage.* OriginalImage_3xSizeWithFilledInBackground_rotated;
    end

    %Extract only the region of C that used entire template for corr
    [Width_C, dummy] = size(C);
    C_ValidRegion = C(WidthNewImage+1:Width_C-(WidthNewImage-1), WidthNewImage+1:Width_C-(WidthNewImage-1));

    %NOTE KH INSERTED 2-21-2011
    IsRestrictToCenter = true;
    if IsRestrictToCenter
        %Restrict to center:
        C_ValidRegion(1:floor(end/3), :) = 0;
        C_ValidRegion(2*floor(end/3):end, :) = 0;
        C_ValidRegion(:, 1:floor(end/3)) = 0;
        C_ValidRegion(:, 2*floor(end/3):end) = 0;
    end
    
%     if IsPlotResults
%         figure(h_fig);
%         subplot(1,3,2);
%         imagesc(C_ValidRegion);
%     end
    
    %Pick out the row col of the peak
    [max_C_ValidRegion, imax] = max(C_ValidRegion(:));
    [rpeak, cpeak] = ind2sub(size(C_ValidRegion),imax(1));
    [WidthValidRegion, dummy] = size(C_ValidRegion);
    r_offset = rpeak - WidthValidRegion/2;
    c_offset = cpeak - WidthValidRegion/2;
    
%     if IsPlotResults
%         %Display the corrected postion of the template
%         ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
%         ColorCombinedImage(HeightImage+1+r_offset:(end-HeightImage)+r_offset,...
%             WidthImage+1+c_offset:(end-WidthImage)+c_offset,1) = NewImage;
%         
%         figure(h_fig);
%         subplot(1,3,3);
%         imshow(ColorCombinedImage);
%     end
    
    if max_C_ValidRegion > MaxSoFar
        MaxSoFars(i) = max_C_ValidRegion;
        r_offset_finals(i) = r_offset;
        c_offset_finals(i) = c_offset;
        %i_final = i;
    end
    
end

MaxSoFar = max(MaxSoFars);
i_final = find(MaxSoFars == MaxSoFar,1);
r_offset_final =  r_offset_finals(i_final);
c_offset_final =  c_offset_finals(i_final);




% if IsPlotResults
%     %display final best result
%     clf;
%     
%     OriginalImage_3xSizeWithFilledInBackground_rotated = imrotate(OriginalImage_3xSizeWithFilledInBackground,AnglesInDegreesToTryArray(i_final),'crop');
%     
%     ColorCombinedImage(:,:,1) = 0*ColorCombinedImage(:,:,1); %clear red channel
%     ColorCombinedImage(HeightImage+1+r_offset_final:(end-HeightImage)+r_offset_final,...
%             WidthImage+1+c_offset_final:(end-WidthImage)+c_offset_final,1) = NewImage;
%     
% 
%     ColorCombinedImage(:,:,2) = OriginalImage_3xSizeWithFilledInBackground_rotated; %green
%     ColorCombinedImage(:,:,3) = 0*OriginalImage_3xSizeWithFilledInBackground_rotated; %blue
%     
%     figure(h_fig);
%     imshow(ColorCombinedImage, 'InitialMagnification', 'fit');
%     pause(.1);
% end


YOffsetOfNewInPixels = r_offset_final; %Note: Here is where the reversed Y-Axis sign change is fixed
XOffsetOfNewInPixels = -c_offset_final;
AngleOffsetOfNewInDegrees = AnglesInDegreesToTryArray(i_final);



if IsPlotResults
    if ishandle(h_fig)
        close(h_fig);
    end
end

FigureOfMerit = MaxSoFar;

end



