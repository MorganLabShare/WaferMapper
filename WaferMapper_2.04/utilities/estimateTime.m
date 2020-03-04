
fov = 3000; % um
dwell = 2; %us
res = 1; % um
us2min = 1/1000000/60;
imSize = fov/res;

minutes = imSize^2 * dwell * us2min;
