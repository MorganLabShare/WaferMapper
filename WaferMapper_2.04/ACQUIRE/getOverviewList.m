function[imageList] = getOverviewList(SPN)

if ~exist(SPN)
    SPN = 'L:\joshm\LGNs1\UTSL_lgns1\'
end

dSPN = dir(SPN)
wafDir = {}
for i = 1:length(dSPN)
    
    nam = dSPN(i).name
    if nam(1) == 'w'
        wafDir{length(wafDir)+1} = nam;
    end
end


%%
foundOV = 0;
imageList = {};
for i = 1:length(wafDir)
    disp(sprintf('reading %d of %d',i,length(wafDir)));
   checkDir = [SPN wafDir{i} '\SectionOverviewsDirectory\'];
   dCheck = dir(checkDir);
   for o = 1:length(dCheck)
       nam = dCheck(o).name;
       if sum(regexp(nam,'SectionOverview_')) & sum(regexp(nam,'.tif'));
           if ~sum(regexp(nam,'BadImage'))
       foundOV = foundOV+1;
       rawList{foundOV} = [checkDir nam];
       wafID(foundOV) = i;
       
       und = regexp(nam,'_');
       dot = regexp(nam,'.tif');
       
       secID(foundOV) = str2num(nam(und(1)+1:dot(1)-1));
           end
       end 
   end
end

%% Sort
sortID = wafID * 10000 + secID
[sortedID idx] = sort(sortID);
imageList = rawList(idx)';


