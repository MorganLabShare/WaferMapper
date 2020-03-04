%% Turn mosaics from waffer into viewable (centers and downsample) mosaics
clear all 
%% Get Waffer folder information
wif = GetMyWafer;
%% View stitched

%logF = dlmread(wif.log{end})
%% Parse XML
[tree, rootname, dom]=xml_read(wif.xml{end});
overlap = tree.MosaicSetup.TileOverlapXum;
xs = tree.MosaicSetup.TileWidth;
ys = tree.MosaicSetup.TileHeight;
res = tree.MosaicSetup.PixelSize;
pixelOverlap = fix(overlap / res * 1000);
minXfield = tree.MosaicSetup.Width;
minYfield = tree.MosaicSetup.Height;

%% Target Dir
TPN = wif.dir; TPN = [TPN(1:end-1) 'Shaped\'];
TPNsav = [TPN 'quality\'];
if ~exist(TPNsav),mkdir(TPNsav);end

%% test Focus
colormap gray(256)
dsampy = 100;
dsampx = 100;
sampA = 3;

for s = 1 : length(wif.sec) % run sections
    sprintf('reading  section %d of %d',s,length(wif.sec))

    %[tree, rootname, dom]=xml_read(wif.sec(s).xml);
    rc = wif.sec(s).rc;
    mosDim = max(rc,[],1);
    mos = zeros(mosDim(1),mosDim(2),3);
    for t = 1:length(wif.sec(s).tile)
        %Ir = imread(wif.sec(s).tile{t},'PixelRegion',{[1000 1500],[1000 1500]});
        %FM = fmeasure(Ir,'SFRQ',[])
        subplot(2,1,1)
        %image(Ir),pause(.01)
        I1 = double(imread(wif.sec(s).tile{t},'PixelRegion',{[ 1 dsampy ys],[1 dsampx xs]}));
        I1 = I1(1:end-1,:);
        Id = zeros(size(I1,1),size(I1,2),sampA);
        
        for i = 1 :sampA
            Is = double(imread(wif.sec(s).tile{t},'PixelRegion',{[ 1+i dsampy ys],[1 dsampx xs]}));
            Is = Is(1:size(I1,1),1:size(I1,2));
            Id(:,:,i) = abs(Is-I1);
        end
        Ic(:,:) = abs(Is-circshift(I1,[5 0]));
        difC = mean(Ic(:));
        
        clear medDif
        for d = 1:size(Id,3)
            vals = Id(:,:,d);
            medDif(d) = mean(vals(:));
        end

        subplot(2,1,2)
        plot(medDif)
        con = difC-medDif(1);
        scaledDif = (medDif-medDif(1))/con*100;
       
        dmap = scaledDif(2:end)-scaledDif(1:end-1);
        ylim([medDif(1) difC]),pause(.01)
        
        mos(rc(t,1),rc(t,2),:) = [dmap(1) dmap(2) con];
        mosC = uint8(mos * 10);
    end
    mosA(:,:,:,s) = mos;
    image(mosC),pause(1)
    imwrite(mosC,[TPNsav wif.secNam{s} '.tif'],'Compression','none')
end
safesave([TPNsav 'qual.mat'],'mosA')










