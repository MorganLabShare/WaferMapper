
SPN = 'G:\joshm\MasterRaw\2013zf\2017+12+14_waf44\';
TPN = 'G:\joshm\MasterRaw\2013zf\2017+12+14_waf44_cutCenter\';

dSPN = dir([SPN 'w*'])

isFold = [dSPN.isdir];

folds = {dSPN(isFold).name};

aDir = '\SectionOverviewsAlignedWithTemplateDirectory\';
c = 0;
clear wafID secID
for i = 1:length(folds)
    
    fol= folds{i};
    nums = [];
    for f = 1:length(fol)
       num = str2num(fol(f)) ;
       if ~isempty(num)
           nums = [nums fol(f)];
       end
    end
    waf = str2num(nums);
    
    alignDir = [SPN folds{i} aDir];
    if exist(alignDir)
       
        dSPN = dir([alignDir '*.tif']);
        tifs = {dSPN.name};
        for t = 1:length(tifs)
           nam = tifs{t};
            dot = regexp(nam,'.tif');
            und = regexp(nam,'_');
            sec = str2num(nam(und(end)+1:dot(1)-1));
            
            if sec
                c = c+1;
                wafID(c) = waf;
                secID(c) = sec;
                
                sourceName{c} = [alignDir nam];
                
                
            end
            
        end
        
    end
    
end



idx = wafID*1000 + secID;

[x a] = sort(idx,'ascend');



sourceName2 = sourceName(a);
wafID2 = wafID(a);
secID2 = secID(a);
if ~exist(TPN,'dir'),mkdir(TPN),end
useWaf = find((wafID2>45) & (wafID2<51));
for i = 1:length(useWaf)
    plane = useWaf(i);
    newName = sprintf('id%06.0f_w%04.0f_s%04.0f.tif',plane,wafID2(plane),secID2(plane));
    
    Iraw = imread(sourceName2{plane});
    I = Iraw(2000:3000,1500:2500);
    imwrite(I,[TPN newName]);

end



