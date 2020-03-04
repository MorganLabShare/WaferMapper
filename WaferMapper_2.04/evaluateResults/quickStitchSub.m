function[stitchedCol, stitchStats] = quickStitchSub(TPN);

if ~exist('TPN','var')
    TPN = GetMyDir
end
%['stitching ' TPN]
dTPN = dir(TPN); dTPN = dTPN(3:end);
nanometerSamp = 50;
overlapFactor = 2; % 1 = only look at overlap region to correlate, 2 = look at a region twice as wide as overlap
displayOn = 0;

if displayOn
    colormap gray(256)
end

%% Get tile names
tifNams = {};
for i = 1:length(dTPN)
    nam = dTPN(i).name;
    
    if strcmp(nam(1:5),'Tile_')
        unds = regexp(nam,'_');
        dash = regexp(nam,'-');
        r = str2num(nam(unds(1)+2:dash(1)-1));
        c = str2num(nam(dash(1)+2:unds(2)-1));
        if length(unds)==3;
            if strcmp(nam(end-3:end),'.tif')
                
                tifNams{r,c} = nam;
                
            elseif strcmp(nam(end-3:end),'.mat')
                if ~exist('matNams','var')
                    firstMat = nam;
                end
                matNams{r,c} = nam;
                
            end %if tif or mat
        end %if correct number of underscores
    end % if Tile
end %find Tiles

%% Check validity
if isempty(tifNams)
    valid = 0;
elseif exist([TPN tifNams{1,1}],'file') & exist('firstMat','var')
    valid = 1;
else
    valid = 0;
end


if valid
    %% Get tile info
    load([TPN firstMat])
    overlap = Info.MontageTarget.PercentTileOverlap;
    Width = Info.ImageWidthInPixels;
    Height = Info.ImageHeightInPixels;
    nmPerPix = Info.FOV_microns/Width*1000;
    increment = round(nanometerSamp/nmPerPix);
    getDown = {[1 increment Height] [1 increment Width]};
    numRow = Info.MontageTarget.NumberOfTileRows;
    numCol = Info.MontageTarget.NumberOfTileCols;
   if (size(tifNams,1)*size(tifNams,2))~=(numRow*numCol) %if all tiles present
    valid = 0;
end 
    
    
end


valid
if valid
    %% Grab all tiles
    clear tiles
    %tiles = zeros(H,W,numRow,numCol,'uint8');
    %filtered = zeros(H,W,numRow,numCol);
    for r = 1:size(tifNams,1)
        for c = 1:size(tifNams,2)
            if ~isempty(tifNams{r,c})
                I = imread([TPN tifNams{r,c}],'PixelRegion',getDown);
                filtI = mexHatTile(256-I,1,2);
                [H W ] = size(I);
                %image(I),pause(.01)
                tiles(:,:,r,c) = I;
                filtered(:,:,r,c) = filtI;
            end
        end
        ['Read row ' num2str(r)]
    end
    
    
    %% Align
    
    grabOverlap = round(H * overlap/100);
    subOverlap = round(H * overlap/100);
    
    getBottom = {[H-round(grabOverlap*2/2)+1 : H] [1 : W]};
    getTop = {[1 : round(grabOverlap * 2/2)] [1 : W]};
    getRight = {[1:H] [ W-grabOverlap+1:W]};
    getLeft = {[1:H] [1:grabOverlap]};
    
    %getRight = {[1 : H] [W-round(grabOverlap*2/2) : W]};
    %getLeft = {[1 : H] [1 : round(grabOverlap*2/2)]};
    
    subBottom = {[H-round(subOverlap/2) : H] [subOverlap : W-subOverlap]};
    subTop = {[1 : round(subOverlap/2)] [subOverlap : W-subOverlap]};
    subRight = {[subOverlap : H-subOverlap] [W-round(subOverlap/2) : W]};
    subLeft = {[subOverlap : H-subOverlap] [1 : round(subOverlap/2)]};
    
    
    numSub = round(W/grabOverlap);
    
    for s = 1:numSub
        sub{s} = round([(s-1)*W/numSub+1:(s*W/numSub)]);
    end
    
    clear upCor leftCor stackC
    for r = 1:size(tifNams,1);
        for c = 1:size(tifNams,2);
            
            %%Check right
            if c<size(tifNams,2)
                A = filtered(getRight{1},getRight{2},r,c)';
                B = filtered(getLeft{1},getLeft{2},r,c+1)';
                for s = 1:numSub
                    subA = A(:,sub{s});
                    subB = B(:,sub{s});

                    minVar =  min(var(subA(:)),var(subB(:)));
                    if minVar
                        C = normXcorr2(subB,subA);  %where does B fit into A
                        
                        if displayOn
                            'check right'
                            subplot(1,3,1)
                            image(subA'+100)
                            subplot(1,3,2)
                            image(subB'+100)
                            subplot(1,3,3)
                            image(C'/max(C(:))*256),pause(.01)
                            %image(C' *300)
                            pause(.01)
                        end
                        var(subB(:));
                        stackC(:,:,s) = C.^2 * minVar^2;
                        subC(s) = max(C(:));
                        %[matchY matchX] = find(C == max(C(:)),1);
                        %subMatchY(s) = size(subB,1)-matchY;
                        %subMatchX(s) = size(subB,2)-matchX;
                    else %no variance
                        %subMatchY(s) = 0;
                        %subMatchX(s) = 0;
                        subC(s) = 0;
                    end
                end
                if exist('stackC')
                meanC = mean(stackC,3);
                %image(meanC'*256/max(meanC(:))),pause
                [matchY matchX] = find(meanC == max(meanC(:)),1);
                leftCor(r,c+1,1:2) = [size(subB,2) - matchX  size(subB,1) - matchY ];
                %leftCor(r,c+1,1:2) = [median(subMatchY) median(subMatchX)];
                   else
                  leftCor(r,c+1,1:2) = [0 0];
                end
                
                leftFit(r,c+1) = mean(subC);
                pause(.1)
            end
            
            
            
            %%Check bottom
            if r < size(tifNams,1)
                %'check bottom'
                A = filtered(getBottom{1},getBottom{2},r,c);
                B = filtered(getTop{1},getTop{2},r+1,c);
                
                for s = 1:numSub
                    subA = A(:,sub{s});
                    subB = B(:,sub{s});
                    minVar = min(var(subA(:)),var(subB(:)));
                    
                    if minVar
                        C = normXcorr2(subB,subA);  %where does B fit into A
                        if displayOn
                            'check bottom'
                            subplot(1,3,1)
                            image(subA'+100)
                            subplot(1,3,2)
                            image(subB'+100)
                            subplot(1,3,3)
                            image(C'/max(C(:))*256),pause(.01)
                            pause(.01)
                        end
                        
                        
                        stackC(:,:,s) = C.^2* minVar^2;
                        subC(s) = max(C(:));
                        %[matchY matchX] = find(C == max(C(:)),1);
                        %subMatchY(s) = size(subB,1)-matchY;
                        %subMatchX(s) = size(subB,2)-matchX;
                    else %no variance
                        %subMatchY(s) = 0;
                        %subMatchX(s) = 0;
                        subC(s) = 0;
                    end
                end
                if exist('stackC')
                meanC = mean(stackC,3);
                %image(meanC'*256/max(meanC(:))),pause
                [matchY matchX] = find(meanC == max(meanC(:)),1);
                
                upCor(r+1,c,1:2) = [ size(subB,1) - matchY size(subB,2) - matchX];
                else
                  upCor(r+1,c,1:2) = [0 0];
                end
                
                
                %upCor(r+1,c,1:2) = [median(subMatchY) median(subMatchX)];
                upFit(r+1,c) = mean(subC);
                
            end
        end %run coloumns
        ['Aligned row ' num2str(r)]
    end %run rows
    
    
    %%propogate offsets
    
    %% Resolve offsets topleft to botom right
    trackY = zeros(numRow,numCol);
    trackX = zeros(numRow,numCol);
    for r = 1:size(tifNams,1)
        for c = 1:size(tifNams,2);
            topShiftY = 0;
            topShiftX = 0;
            leftShiftY = 0;
            leftShiftX = 0;
            if r>1
                topShiftY= trackY(r-1,c);
                topShiftX = trackX(r-1,c);
            end
            if c>1
                leftShiftY = trackY(r,c-1);
                leftShiftX = trackX(r,c-1);
            end
            
            
            offX = [leftCor(r,c,2)  + leftShiftX  upCor(r,c,2) + topShiftX];
            offY = [leftCor(r,c,1) + leftShiftY   upCor(r,c,1) + topShiftY];
            
            if upFit(r,c)>=leftFit(r,c)
                shiftX = offX(2);%find(abs(offX)==min(abs(offX)),1));
                shiftY = offY(2);%find(abs(offY)==min(abs(offY)),1));
            else
                shiftX = offX(1);
                shiftY = offY(1);
            end
            trackY(r,c) = shiftY;
            trackX(r,c) = shiftX;
        end
    end
    
    %%Create matrix
    subplot(1,1,1)
    globalY = max(trackY(1,:))+1;
    globalX = max(trackX(:,1))+1;
    realWidth = round((W- (W * overlap/100)));
    maxX = fix((W-grabOverlap) * numCol - min(trackX(:,end))+globalX+grabOverlap)+1;
    maxY = fix((H-grabOverlap) * numRow - min(trackY(end,:))+globalY+grabOverlap)+1;
    stitched = zeros(maxY, maxX,1);
    stitchedCol = zeros(maxY,maxX,3,'uint8');
    filled = zeros(maxY, maxX);
    
    % trackY = trackY * 0;
    % trackX = trackX * 0;
    for r = 1:size(tifNams,1)
        for c = 1:size(tifNams,2)
            chan = mod((r+c),2)+1;
            startX = (c-1) * realWidth  - trackX(r,c) +globalX;
            startY = (r-1) * realWidth - trackY(r,c) +globalY;
            stitched(startY:startY+H-1,startX:startX+W-1) ...
                = stitched(startY:startY+H-1,startX:startX+W-1)+ double(tiles(:,:,r,c));
            stitchedCol(startY:startY+H-1,startX:startX+W-1,chan) ...
                = stitchedCol(startY:startY+H-1,startX:startX+W-1,chan)+ uint8(double(tiles(:,:,r,c)));
            filled(startY:startY+H-1,startX:startX+W-1) =filled(startY:startY+H-1,startX:startX+W-1)+1;
            starts(r,c,:) = [startY startX];
        end
    end
    stitchedBW = uint8(256-stitched);
    image(stitchedCol),pause(.01)
    
    
    %% Analyze overlap
    totalPix = W* W * numRow * numCol;
    predictedOverlapPix = ((numRow-1) *numCol)+((numCol-1) * numRow) * (overlap/100 * W)*W;
    actualOverlapPix = sum(filled(:)>1);
    
    targetWidth = W * numCol - (numCol-1)*overlap/100*W;
    targetHeight = H * numRow - (numRow-1)*overlap/100*H;
    targetPix = targetWidth*targetHeight;
    
    
    %%Find inner edge box
    innerTop = max(starts(1,:,1));
    innerBot = min(starts(end,:,1))+W-1;
    innerLeft = max(starts(:,1,2));
    innerRight = min(starts(:,end,2))+W-1;
    innerArea = (innerBot-innerTop)*(innerRight-innerLeft);
    
    %%Find outer edge box
    outerTop = min(starts(1,:,1));
    outerBot = max(starts(end,:,1))+ W-1;
    outerLeft = min(starts(:,1,2)) ;
    outerRight = max(starts(:,end,2)) +W-1;
    outerArea = (outerBot-outerTop)*(outerRight-outerLeft);
    
    outerGap = (outerArea-innerArea)/targetPix * 100;
    
    percentInner = innerArea/targetPix * 100;
    
    %%Inner filled
    innerFilled = filled(innerTop:innerBot,innerLeft:innerRight);
    %image(innerFilled * 100)
    
    innerGap = (sum(innerFilled(:)==0)/innerArea)*100;
    
    
    
    if innerGap ==0;
        tileRating = percentInner;
    else
        tileRating = -1 * innerGap;
    end
    
    
    stitchStats.percentInner = percentInner;
    stitchStats.innerGap = innerGap;
    stitchStats.meanXerror = sum(sum(abs([leftCor(:,:,2) upCor(:,:,2)])))/(numRow*numCol*2-1)*nanometerSamp/1000;
    stitchStats.meanYerror = sum(sum(abs([leftCor(:,:,1) upCor(:,:,1)])))/(numRow*numCol*2-1)*nanometerSamp/1000;
    stitchStats.maxerror = max(abs([leftCor(:) ; upCor(:)]))*nanometerSamp/1000;
    
    stitchStats
    
    %{
%% Other analysis

%%find minBox
vertEdges=abs((filled(2:end,:)>0)-(filled(1:end-1,:)>0));
countVert = sum(vertEdges,1);
horzEdges = abs((filled(:,2:end)>0)-(filled(:,1:end)>0));
countHorz = sum(horizEdges,2);
plot(countVert)

image(filled * 100)

fStats = regionprops(filled,'Area','BoundingBox','FilledArea','FilledImage','Image','ConvexArea')

gaps = fStats.FilledArea - fStats.Area;

    %}
    
    
    
else
    stitchStats = struct;
    stitchedBW = 0;
    stitchedCol = 0;
end






