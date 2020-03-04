function Fibics_AcquireImage_WithAutoRetakes(ImageWidthInPixels,ImageHeightInPixels,DwellTimeInMicroseconds,FileNameStr)
%This function is a wrapper around the standard Fibics Call
% and checks if the bottom of the image is predomantly black or white.
%It does only one retake since there may indeed be times when the image
%should be black on the bottom.
global GuiGlobalsStruct;

GuiGlobalsStruct.MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
    DwellTimeInMicroseconds,FileNameStr);
while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
    pause(1);
end

IsReadOK = false;
while ~IsReadOK
    IsReadOK = true;
    try
        MyDownSampledImage = imread(FileNameStr, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
    catch MyException
        IsReadOK = false;
        %disp(sprintf('   imread exception: %s',MyException.identifier));
        pause(.1);
    end
end
    
AvgOfBottom10PercentOfImage = mean(mean(MyDownSampledImage(floor(end*0.9):end,:)));
if (AvgOfBottom10PercentOfImage < 5) || (AvgOfBottom10PercentOfImage > 250) %reacquire image
    disp(sprintf('POSSIBLE FIBICS IMAGING FAULT, Reacquiring %s.',FileNameStr));
    BadFileName = sprintf('%s_BadImage.tif',FileNameStr(1:(end-4)));
    %MOVEFILE(SOURCE,DESTINATION,MODE)
    movefile(FileNameStr,BadFileName);
    pause(.2);
    GuiGlobalsStruct.MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
        DwellTimeInMicroseconds,FileNameStr);
    while(GuiGlobalsStruct.MyCZEMAPIClass.Fibics_IsBusy)
        pause(1);
    end
    pause(1);
end



end

