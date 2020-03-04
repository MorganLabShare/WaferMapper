%% get directory
TPN = GetMyDir;
resizeDir = [TPN 'resize\'];
if ~exist(resizeDir,'dir')
    mkdir(resizeDir);
end

%% get tifs
dTPN = dir(TPN); dTPN = dTPN(3:end);
tifNam = {}; %list of all tif names
for i = 1:length(dTPN)
   nam = dTPN(i).name;
   if strcmp(nam(end-3:end),'.tif')
      tifNam{length(tifNam)+1} = nam; 
   end
end

%% Read info
for i = 1: length(tifNam)
    nfo =  imfinfo([TPN tifNam{i}]);
    Width(i) = nfo.Width;
    Height(i) = nfo.Height;
end

W = round(min(mean(Width)*1.3,max(Width)));
H = round(min(mean(Height)*1.3,max(Height)));


%% Resize images
resizeI = zeros(H,W,'uint8');
for i = 1:length(tifNam)
    resizeI = resizeI * 0;
    I = imread([TPN tifNam{i}]);
    getW = min(W,size(I,2));
    getH = min(H,size(I,1));
    resizeI(1:getH,1:getW) = I(1:getH,1:getW);
    imwrite(resizeI,[resizeDir tifNam{i}]);
    
end


%


