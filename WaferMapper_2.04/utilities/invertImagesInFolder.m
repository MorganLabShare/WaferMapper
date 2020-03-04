TPN = GetMyDir;

dTPN = dir(TPN); dTPN = dTPN(3:end);

for i = 1:length(dTPN)
    
    nam = dTPN(i).name;
    if length(nam)>4
        if strcmp(nam(end-3:end), '.tif')
            disp(sprintf('Inverting %s, file %d of %d',nam,i,length(dTPN)))
            I = imread([TPN nam]);
            I = 255 - I;
            imwrite(I,[TPN nam],'Compression','none');
        end %if tif
    end %if long enough name
end %run all files
