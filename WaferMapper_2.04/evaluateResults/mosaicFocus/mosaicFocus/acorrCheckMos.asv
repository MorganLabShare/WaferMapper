%% Turn mosaics from waffer into viewable (centers and downsample) mosaics

%% Get Waffer folder information
wif = GetMyWafer;
%% View stitched

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
dsamp = 10;
subReg = [round(xs/2 - isize/2) round(xs/2 - isize/2) + isize-1];
shiftA = 20;

for s = 4%1 : length(wif.sec) % run sections
    sprintf('reading tile %d of %d',s,length(wif.sec))

    %[tree, rootname, dom]=xml_read(wif.sec(s).xml);
    rc = wif.sec(s).rc;
    mosDim = max(rc,[],1);
    mos = zeros(mosDim*isize,'uint8');
    for t = 1:length(wif.sec(s).tile)

        ystart = (rc(t,1)-1)*isize+1;
        xstart = (rc(t,2)-1)*isize+1;
        I = imread(wif.sec(s).tile{t});
        subplot(2,2,1)
        image(I*1.5)
        subplot(2,2,2)
        image(I(1000:1500,1000:1500)*1.5),pause(.01)
        Id = I(1:end-shiftA,:)*0;
        for s = 1:shiftA
           Id(:,:,s) = I(1:end-shiftA,:)-I(1+s:end-shiftA+s,:); 
        end
        
        
        I1 = double(imread(wif.sec(s).tile{t},'PixelRegion',{[ 1 dsamp ys],[1 dsamp xs]}));
        Id = zeros(size(I1,1),size(I1,2),dsamp-2);
        for i = 1 :dsamp-2
            Is = double(imread(wif.sec(s).tile{t},'PixelRegion',{[ 1+i dsamp ys],[1 dsamp xs]}));
            
            Id(:,:,i) = abs(Is-I1);
            %image(Is(:,:,i)),pause
        end
        
            for d = 1:size(Id,3)
                vals = Id(:,:,d);
                medDif(d) = median(vals(:));
            end
        
        subplot(2,1,2)
        plot(medDif)
        ylim([0 20]),pause
        %[mfIs, listYX] =funSubFFT(I);


        %mos(ystart:ystart+size(I,1)-1,xstart:xstart+size(I,2)-1) = 255-I;
        %image(mos),pause(.1)
    end
    %image(mos),pause(1)
    % imwrite(mosB,[TPNsav wif.secNam{s} '.tif'],'Compression','none')
end










