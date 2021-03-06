function[Imf] = mexHatTarget(I);
% %%
% medI = median(I(:));
% meanI = mean(I(:));
% threshI = I < (medI);
% tic
% se = strel('disk',5);
% mf1 = imopen(threshI,se);
% se = strel('disk',10);
% mf2 = imclose(mf1,se);
% toc
 %image(uint8(cat(3,threshI,mf1,mf2)*1000))

%% process I
kSize = [256 256];
s1 =2;
s2 = 10;

kRad = (kSize + 1)/2;
kern = zeros(kSize);

[y x z] = ind2sub(kSize,find(kern==0));
dists = sqrt(((y-kRad(1))).^2 + ((x - kRad(2))).^2);

cKern = 1 * exp(-.5 * (dists/s1).^2);
cKern = cKern/sum(cKern(:));
sKern = 1 * exp(-.5 * (dists/s2).^2);
sKern = sKern/sum(sKern(:));
kern(:) = cKern - sKern;

% subplot(2,1,1)
%plot(kern(round(kRad(1)),:))

%%Convolve

Itemp = fastCon(I,kern);
pixClip = 10;
Imf  = Itemp * 0;
Imf(pixClip +1:end-pixClip,pixClip +1:end-pixClip)=Itemp(pixClip +1:end-pixClip,pixClip +1:end-pixClip);
%Imf(Imf<0)=0;

Imf = Imf*(256/max(Imf(:)));
%Imf = 256-Imf;


trimEdge = max(s1,s2)*2;
Imf(1:trimEdge,:) = 0;
Imf(end-trimEdge+1:end,:) = 0;
Imf(:,1:trimEdge) = 0;
Imf(:,end-trimEdge+1:end) = 0;
%image(Imf+100)


