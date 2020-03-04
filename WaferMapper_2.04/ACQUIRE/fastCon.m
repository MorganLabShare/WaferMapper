function[I] = fastCon(I,K);

% get size
[iys ixs izs] = size(I);
[kys kxs kzs] = size(K);

% pad with zeros
K(kys + iys , ixs + kxs, izs + kzs) = 0;
I(kys + iys, ixs + kxs, izs + kzs) = 0;

% convolve by fft
cI = ifftn(fftn(I).*fftn(K));

% recover non zeros
I = cI(round(kys/2):round(kys/2)+iys - 1,...
    round(kxs/2):round(kxs/2)+ixs - 1,...
    round(kzs/2):round(kzs/2)+izs - 1);
I = real(I);


