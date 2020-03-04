SPN = GetMyDir;
TPN = GetMyDir;

dSPN = dir(SPN);dSPN = dSPN(3:end);

for i = 1:length(dSPN)
   nam = dSPN(i).name
   if strcmp(nam(1:4),'Tile') & strcmp(nam(end-3:end),'.tif')
       newName = [ nam];
       I = imread([SPN nam]);
       smallI = imresize(I,0.1,'bicubic');
       smallI = 256-smallI;
       imwrite(smallI,[TPN newName],'Compression','none')
   end
    
end