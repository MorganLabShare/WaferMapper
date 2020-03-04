function[Imf] = mexHatTile(I,s1,s2);

%% process I

if ~exist('s1','var')
s1 = 1;
end
if ~exist('s2','var')
s2 = 10;
end
kSize = max(s1,s2)*3;
kSize = [kSize kSize];


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

%% Convolve
pixClip = max(s1,s2)*100;
Ibuf = zeros(size(I)+pixClip*2)+mean(I(:));
Ibuf(pixClip+1:pixClip+size(I,1),pixClip+1:pixClip+size(I,2))=I;
Itemp = conv2(Ibuf,kern,'same');
Imf=Itemp(pixClip +1:end-pixClip,pixClip +1:end-pixClip);


