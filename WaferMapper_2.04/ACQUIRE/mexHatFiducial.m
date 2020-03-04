function[Imf] = mexHatFiducial(I);

%% process I
kSize = [20 20];
s1 =1;
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
kern
% subplot(2,1,1)
% plot(kern(round(kRad(1)),:))

%% Convolve

Itemp = fastCon(I,kern);
pixClip = min(kSize,round(size(I,1)/3));
Imf  = Itemp * 0;
Imf(pixClip +1:end-pixClip,pixClip +1:end-pixClip)=Itemp(pixClip +1:end-pixClip,pixClip +1:end-pixClip);
Imf(Imf<0)=0;
Imf = Imf*256/max(Imf(:));
