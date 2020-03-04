%%Flip contrast in directory
TPN = GetMyDir

dTPN = dir(TPN);

for i = 1:length(dTPN)
    nam = dTPN(i).name;
    if length(nam)>4
        if strcmp(nam(end-3:end),'.tif')
            I = imread([TPN nam]);
            I = 255-I;
            imwrite(I,[TPN nam],'Compression','none')
        end
    end
end
