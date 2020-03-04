

%SPN = 'G:\joshm\MasterUTSL\130201zf142\w43\HighResFiducialsDirectory\'
SPN = GetMyDir;

iDir = dir([SPN '*.tif']);
iNames = {iDir.name}

for i = 1:length(iNames)
   
    I = imread([SPN iNames{i}]);
    I = 255-I;
    imwrite(I,[SPN iNames{i}])
end