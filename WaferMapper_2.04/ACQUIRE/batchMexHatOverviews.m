
TPN = GetMyDir;
dTPN = dir(TPN); dTPN= dTPN(3:end);
secDir = 'SectionOverviewsDirectory';
colormap gray(256)

for i = 1:length(dTPN)
    nam = dTPN.name
    if isdir([TPN nam])
        targetSecs = [TPN nam '\' secDir];
        %copyfile(targetSecs,[targetSecs 'Raw'])
        mkdir([targetSecs 'Filtered']);
        allSec = dir(targetSecs); allSec = allSec(3:end);
        for s = 1:length(allSec)
            nams = allSec(s).name;
            if length(nams)>4
                if strcmp(nams(end-3:end),'.tif')
                   imageName = [targetSecs '\' nams]
                   filteredName = [targetSecs 'Filtered\' nams];
                    I = imread(imageName);
                    If = mexHatSection(I);
                    If = If*(256/max(If(:)));
                    If = 256-If;
                    image(If),pause(.01)
                    imwrite(uint8(If),filteredName,'Compression','none')
                end
            end
        end
    end
end
    
    