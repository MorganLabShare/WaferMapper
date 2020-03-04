function[tile maxId] = checkFileQual(checkFile)

if ~exist('checkFile','var');
    checkFile = FileNameStr;
end
maxId = 0;
%{
Manual check
[TFN TPN] = GetMyFile
checkFile = [TPN TFN]
%}


%% wait for image to be readable
IsReadOK = false;
tic
while ~IsReadOK
    IsReadOK = true;
    try
        testPix = imread(checkFile, 'PixelRegion', {[1 1], [1 1]});
    catch MyException
        IsReadOK = false;
        pause(.1);
    end
end
'qual check for data time'
toc
%%
dsamp = 200; %number of kernal samples in each dimension 
sigThresh = .01; %Only look at darkest sigthresh of image
top = .5; % select top X of sample based on contrast differences

yshift = [ 0 0 0 1 1 1 2 2 2]; %shifts for extracting 3X3 samples
xshift = [ 0 1 2 0 1 2 0 1 2];

%1 %2 %3
%4 %5 %6
%7 %8 %9

sur  = {[2 4 6 ], [1 2 3], [4 8 6] [4 5 6],[1 5 7], [1 4 7], [2 6 8], [ 2 5 8]};
cent = {[1 5 3 ], [4 5 6], [7 5 9] [7 8 9],[2 4 8], [2 5 8], [3 5 9], [3 6 9]};

colormap gray(256)

info = imfinfo(checkFile);
xs = info.Width;
ys = info.Height;

dsampy = fix((ys-5)/dsamp); %down sample image reading
dsampx = fix((xs-5)/dsamp);

Id = zeros(dsamp,dsamp,length(yshift));

%grab samples
tic
for i = 1:length(yshift)
    Is = double(imread(checkFile,'PixelRegion',{[ 4+yshift(i) dsampy ys],[4 + xshift(i) dsampx xs]}));
    %Is = I([1 + yshift(i) : 3 :ys],[1 + xshift(i) :3:xs]);
    Is = Is(1:dsamp,1:dsamp);
    Id(:,:,i) = 255-Is;
end
'qual get data time'
toc

%I = double(imread(checkFile));

%maxId = max(Id,[],3);
maxId = mean(Id,3);
devI = std(Id,1,3);

%% check bottom
%botCheck = maxId(end-3:end,:,:);
lastValues = 255-Id(end,:,:);
if sum(lastValues(:)) == 0
    acquisitionFail = 1 %no data in bottom row, assume acquisition fail
else
    acquisitionFail = 0;
end


colormap gray(256)
%% Find signal
Sats = (Id==255) | (Id <= 1);
percentSat = sum(Sats(:))/length(Sats(:))*100;
sumSats = sum(Sats,3);
useVals = devI(sumSats<1);
if (length(useVals)>5) & ~acquisitionFail
    sortMean = sort(useVals,'ascend');
    threshVal = sortMean(end  - (fix(length(sortMean)*sigThresh)));
    useSig = find((devI>=threshVal) & (sumSats==0));
    showUsed = 255 - (maxId);
    showUsed(useSig) = 1000;
    %image(showUsed)
    %pause(1)
    
    %%     Find contrasts
    useDifs = cell(1,length(cent));
    for f = 1: length(cent)
        dif = mean(Id(:,:,cent{f}),3)-mean(Id(:,:,sur{f}),3);
        %dif = abs(dif);
        difs(:,:,f) = dif;
        useDifs{f} = dif(useSig);
    end
    sampSize = length(useSig);
    
    %% group difs
    groups = {[1 3],[2 4],[5 7],[6 8]}; %% group horizontals and verticals
    topCon = zeros(1,length(groups));
    for f = 1:length(groups)
        vals = abs([useDifs{[groups{f}]}]);
        sortVals = sort(vals(:),'ascend');
        thresh = sortVals(end+1 - (round(length(sortVals)*top)));
        topCon(f) = mean(vals(vals>=thresh));
    end
    
   %% group difs  mean then max then max
    groups = {[1 3],[2 4],[5 7],[6 8]}; %% group horizontals and verticals
    meanVals = zeros(sampSize,length(groups));
    for f = 1:length(groups)
        vals = ([useDifs{[groups{f}]}]);
        meanVals(:,f) = abs(mean(vals,2));
    end
  
        maxVals(:,1) = max([meanVals(:,1) meanVals(:,3)],[],2);
        
        topMax = zeros(1,2);
      for f = 1:2
        maxVals = max([meanVals(:,f) meanVals(:,f+2)],[],2);  
        sortVals = sort(maxVals,'ascend');
        thresh = sortVals(end+1 - (round(length(sortVals)*top)));
        topMax(f) = mean(maxVals(maxVals>=thresh));
      end
    
    %% global contrast
    glob = mean(Id,3);
    % gY = abs(glob(2:end,:)-glob(1:end-1,:)) ;
    % gX = abs(glob(:,2:end)-glob(:,1:end-1)) ;
    % spacer = zeros(size(glob,1),1);
    % gAll = cat(3,[spacer' ; gY], [gY*-1 ;spacer'],[spacer gX], [gX*-1  spacer]);
    % maxG = max(gAll,[],3);
    
    globVals = sort(glob(:),'ascend');
    backGround = median(globVals(1:dsamp));
    topGlobM = mean(glob(useSig));
    range = topGlobM-backGround;
    
    %% calculate quality
    
    vertQual = (topCon(2)/topCon(1)-1) * 100;
    horzQual = (topCon(4)/topCon(3)-1) * 100;
    %quality = min(vertQual,horzQual);%/range*100;
    quality = (topMax(2)/topMax(1) - 1) * 100;
    
    %% Record data
    tile.quality = quality
    tile.range = range;
    tile.horzQual = horzQual;
    tile.vertQual = vertQual;
    tile.topCon = topCon;
    tile.stdHigh = mean(devI(useSig))/range;
    tile.std = std(Id(:));
else
    tile.quality = -100;
    tile.range = 0;
    tile.horzQual = 0;
    tile.vertQual = 0;
    tile.topCon = 0;
    tile.stdHigh = 0;
    tile.std = 0;
end

tile.percentSaturation = percentSat;




