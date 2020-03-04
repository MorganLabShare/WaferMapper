clear all
SPN = 'G:\joshm\MasterRaw\2013zf\2017+12+14_waf44\'
stackName = [SPN(1:end-1) '_singleStack_center2\'];
if ~exist(stackName,'dir'),mkdir(stackName);end

dSPN = dir(SPN);

c = 0;
clear sec fold
for i = 1:length(dSPN)
    nam = dSPN(i).name;
    s = regexp(nam,'_Sec');
    m = regexp(nam,'_Mon');
   if ~isempty(s) & ~isempty(m)
        c = c+1;
       sec(c) = str2num(nam(s(1)+4:m(1)-1));
       fold{c} = nam;
       
   end
end

c = 0;
for i = 1:length(fold)
    dMon = dir([SPN fold{i} '\*.tif']);
    for m = 1:length(dMon);
        nam = dMon(m).name;
        t =  regexp(nam,'Tile_r2-c1');
        if ~isempty(t)
            c = c+ 1;
            imnam{c} = nam;
            imfold{c} = fold{i};
        end
    
    end
end


info = imfinfo([SPN imfold{1} '\' imnam{1}]);
xs = info.Width; ys = info.Height;
cutSize = 512;
centX = round(xs/2-cutSize/2);
centY = round(ys/2-cutSize/2);

for i = 1:length(imnam)
    oldName = [SPN imfold{i} '\' imnam{i}];
    newName = [stackName imnam{i}];
    I = imread(oldName,'pixelregion',{[centY+1, centY + cutSize],[1,xs]});
    Ic = I(:,centX+1:centX+cutSize);
    imwrite(Ic,newName);
    %copyfile(oldName,newName)
    
end


