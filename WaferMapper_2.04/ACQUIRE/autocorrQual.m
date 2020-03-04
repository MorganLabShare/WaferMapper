function[acQual] = autocorrQual(Isource)

%% check image quality using autocorrelation method

global GuiGlobalsStruct;


%% read image if string
if ischar(Isource)
    I = imread(ischar);  
else
    I = Isource;
end
I =  double(I);

acQual.var = var(I(:));


% make masks
alpha = 6;
beta = 0.5;
gamma = 3;
sigma = 0.5;
epsilon = 9;

acorrSize = 64;
for i = 1: acorrSize
    x = i - acorrSize/2;
    
    for j = 1: acorrSize
        y = j - acorrSize/2;
        r = sqrt(x^2+y^2);
        if r == 0;
            r = 1;
        end
        sinT = x/r;
        cosT = y/r;
        exp_astig = exp(-r^2/alpha) - exp(-r^2/beta);
        
        self.fi_mask(i,j) = exp(-r^2/gamma) - exp(-r^2/sigma);
        self.fo_mask(i,j) = exp(-r^2/epsilon) - exp(-r^2/gamma);
        self.apx_mask(i,j) = sinT^2 * exp_astig;
        self.amx_mask(i,j) = cosT^2 * exp_astig;
        self.apy_mask(i,j) = 0.5 * (sinT + cosT)^2 * exp_astig;
        self.amy_mask(i,j) = 0.5 * (sinT -cosT)^2 * exp_astig;
           
    end
end



%%

meanI = mean(I(:));
I = I - meanI;
norm = sum(I(:).^2);

autocorr = conv2(I,fliplr(flipud(I)))/norm;
[height width] = size(autocorr);
autocorr = autocorr(floor(height/2)-32 : floor(height/2)+31,...
    floor(width/2)-32:floor(width/2)+31);

fi = multiplySelf(autocorr, self.fi_mask);
fo = multiplySelf(autocorr, self.fo_mask);
apx = multiplySelf(autocorr, self.apx_mask);
amx = multiplySelf(autocorr, self.amx_mask);
apy = multiplySelf(autocorr, self.apy_mask);
amy = multiplySelf(autocorr, self.amy_mask);

%check if tile key is in estimate?????

%% Calculate single-image estimators

acQual.foc_est = (fi-fo)/(fi+fo);
acQual.astgx_est =(apx - amx) / (apx + amx);
acQual.astgy_est =  (apy - amy) / (apy + amy);

% 
% foc_est = [foc_est (fi-fo)/(fi+fo)];
% astgx_est = [astgx_est (apx - amx) / (apx + amx)];
% astgy_est = [astgy_est (apy - amy) / (apy + amy)];
% 



function res = multiplySelf(autocorr, mask);
    numerator_sum = sum(sum(autocorr.*mask));
    norm = sum(mask(:));
    res = numerator_sum/norm;
    





















