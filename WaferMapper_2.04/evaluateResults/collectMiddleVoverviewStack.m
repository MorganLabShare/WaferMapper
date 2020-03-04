
SPN = 'G:\UTSL\130201zf142_UTSL\MasterUTSL\130201zf142\';
TPN = 'G:\UTSL\Data\AlignOview\';

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
useWaf = (wafID2>32) & (wafID2<46);
for i = 1:length(useWaf)
    plane = useWaf(i);
    newName = sprintf('id%06.0f_w%04.0f_s%04.0f.tif',plane,wafID2(plane),secID2(plane));
    
    I = imread(sourceName2{plane});
    imwrite(I,[TPN newName]);

end







