function[Imf] = mexHatVessle(I,s1,s2);

%% process I
if ~exist('s1','var')
    s1 = 5;
    s2 = 6;
    
end
if ~exist('s2','var')
    s2 = s1+1;
end

kSize = [s2 * 4 s2 * 4];

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
% plot(kern(round(kRad(1)),:))

%% Convolve

Itemp = fastCon(I,kern);
Itemp = Itemp-min(Itemp(:));
pixClip = min(kSize,round(size(I,1)/3));
Imf  = Itemp * 0;
Imf(pixClip +1:end-pixClip,pixClip +1:end-pixClip)=Itemp(pixClip +1:end-pixClip,pixClip +1:end-pixClip);
Imf(Imf<0)=0;
Imf = Imf*256/max(Imf(:));
