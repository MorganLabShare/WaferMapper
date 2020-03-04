%% test focus measure
wif = GetMyWafer;

%%
load([wif.dir 'good.mat'])
load([wif.dir 'rate.mat'])
load([wif.dir(1:end-1) 'shaped\quality\qual.mat'])
good
secNum = 3;
I = imread([wif.dir(1:end-1) 'shaped\quality\' wif.secNam{secNum} '.tif']);
rc = wif.sec(secNum).rc;
inds = sub2ind(max(rc,[],1),rc(:,1),rc(:,2));

qual = mosA(:,:,:,secNum);


%%
cols = ['r' 'g' 'b'];

    
foc1 = qual(:,:,1);
foc1 = foc1(inds); foc1 = foc1(:);
foc2 = qual(:,:,2);
foc2 = foc2(inds); foc2 = foc2(:);
con = qual(:,:,3);
con = con(inds); con = con(:);
focS = sqrt(foc1.*foc2);

for i = 1:2
 use = find(good == i);
    scatter(focS(use),con(use),cols(i))
hold on
end
hold off

scatter(rate +rand(1,length(good))/2,(con.*foc1.*foc2).^(1/3))
scatter(rate,con  + foc1 + foc2)
scatter(rate,(con.*foc1.*foc2).^(1))
