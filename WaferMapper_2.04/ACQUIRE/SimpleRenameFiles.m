
ImagesDirectory = 'C:\Users\Hayworth\ImagesFromUTSL008_4_11_2011\Wafer006';

n=1;
for SectionIndex = 1:94
    ImageFileNameStr = ...
        sprintf('%s\\HighResImage_%d.tif', ImagesDirectory, SectionIndex);
    
    
    
    NumStr = num2str(10000 + n);
    NewImageFileNameStr =...
        sprintf('%s\\Image_%s.tif', ImagesDirectory, NumStr(2:5));
    disp(NewImageFileNameStr);
    %[SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE)
    movefile(ImageFileNameStr,NewImageFileNameStr);
    n=n+1;
end

ImagesDirectory = 'C:\Users\Hayworth\ImagesFromUTSL008_4_11_2011\Wafer007';
for SectionIndex = 1:92
    ImageFileNameStr = ...
        sprintf('%s\\HighResImage_%d.tif', ImagesDirectory, SectionIndex);
    
    NumStr = num2str(10000 + n);
    NewImageFileNameStr =...
        sprintf('%s\\Image_%s.tif', ImagesDirectory, NumStr(2:5));
    disp(NewImageFileNameStr);
    %[SUCCESS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE)
    movefile(ImageFileNameStr,NewImageFileNameStr);
    n=n+1;
end


