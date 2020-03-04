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


%% Target Dir 
TPN = wif.dir; TPN = [TPN(1:end-1) 'Shaped\'];
TPNsav = [TPN 'WD+stig\'];
if ~exist(TPNsav),mkdir(TPNsav);end

%% stitch downSampled
colormap gray(256)
isize = 200;
subReg = [round(xs/2 - isize/2) round(xs/2 - isize/2) + isize-1];


for s = 1 : length(wif.sec) % run sections
    sprintf('reading tile %d of %d',s,length(wif.sec))
    
    [tree, rootname, dom]=xml_read(wif.sec(s).xml);
    for t = 1:length(tree.Tiles.Tile)
        tile = tree.Tiles.Tile(t);
        rc = tile.ATTRIBUTE;
        wd(rc.row,rc.col) = tile.WD * 1000;
        stigX(rc.row,rc.col) = tile.StigX ;
        stigY(rc.row,rc.col) = tile.StigY ;
        
    end
    
    stigX = stigX * 50 + 128;
    stigY = stigY * 50 + 128;
    wd = (wd - median(wd(:))) * 5000 + 128;
    mos = uint8(cat(3,wd,stigX, stigY));
    
    mosB = imresize(mos,100,'nearest');
    image(mosB),pause(.01)
    
    
%     %[tree, rootname, dom]=xml_read(wif.sec(s).xml);
%     mos = zeros(mosDim*isize,'uint8');
%     for t = 1:length(wif.sec(s).tile)
% 
%         ystart = (rc(t,1)-1)*isize+1;
%         xstart = (rc(t,2)-1)*isize+1;
%         I = imread(wif.sec(s).tile{t},'PixelRegion',{subReg,subReg});
%         mos(ystart:ystart+size(I,1)-1,xstart:xstart+size(I,2)-1) = 255-I;
%         %image(mos),pause(.1)
%     end
%     image(mos),pause(1)
     imwrite(mosB,[TPNsav wif.secNam{s} '.tif'],'Compression','none')
end










