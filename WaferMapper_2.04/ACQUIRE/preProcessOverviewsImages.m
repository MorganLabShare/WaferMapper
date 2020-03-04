function[] = preProcessOverviewsImages()

disp('preprocessing overview images for brightness and noise...')
global GuiGlobalsStruct;

secDir = GuiGlobalsStruct.SectionOverviewsDirectory;
backDir = [secDir '_raw'];
if ~exist(backDir,'dir')
    copyfile(secDir,backDir)
end
%movefile(backDir,secDir)4\';

SPN = [backDir '\'];
TPN = [secDir '\'];

if ~exist(TPN,'dir'), mkdir(TPN); end

dSPN = dir([SPN '*.tif']);

nams = {dSPN(:).name};

targBottom = 20;%256 * .025;
targTop = 200;%256 * .975;

%test = [325 788];
parfor i = 1:length(nams)
    nam = nams{i};
    
    if 1%~exist([TPN nam],'file')
        sprintf('running %d of %d',i,length(nams))
        Iraw = imread([SPN nam]);
        I = double(Iraw);
        I = medfilt2(I,[2 2]);
        medI = median(I(:));
        
        vals = sort(I(:),'descend');
        L = length(vals);
        meanTop = mean(vals(1:round(L*.05)));
        meanBottom = mean(vals(round(L*.95):end));
        scaleCon = (targTop-targBottom)/(meanTop-meanBottom);
        I = I * scaleCon;
        I = I - (meanBottom * scaleCon) + targBottom;
        imwrite(uint8(I),[TPN nam]);
    end
end
disp('finished overview preprocessing')








