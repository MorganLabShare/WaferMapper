clear all
logFile = 'C:\Users\joshm\GoogleDriveJMDataWatcher\Google Drive\logBooks\LogBook_w049.mat'
load(logFile);


qual = logBook.sheets.quality.data

tiles = qual(:,1)
quals = qual(:,3)

for i = 1:length(tiles)
   nam = tiles{i};
   quality = quals{i};  
   rS = regexp(nam,'_r');
   cS = regexp(nam,'-c');
   wS = regexp(nam,'_w');
   sS = regexp(nam,'_sec');
   tS = regexp(nam,'.tif');
   r = str2num(nam(rS+2:cS-1));
   c = str2num(nam(cS+2:wS-1)) ;
   s = str2num(nam(sS+4:tS-1));
   
   mapQual(r,c,s) = quality;
   
end

%% Normalize
for i = 1: size(mapQual,3)
    secQual = mapQual(:,:,i);
    medQuals(i) = median(secQual(:));
   medQual(:,:,i) = secQual/median(secQual(:));
    
end

%%
sortRC = [1 0 0 1 ;0 2 2 0 ; 0 2 2 0; 1 0 0 1];
corners = [];
middle = [];
for r = 1:size(mapQual,1)
    for c = 1:size(mapQual,2)
        rcqual = squeeze(medQual(r,c,:));
        rcqual = rcqual(rcqual>0);
       meanQual(r,c) =  mean(rcqual);
       if sortRC(r,c) == 1
           corners = cat(1,corners,rcqual);
       elseif sortRC(r,c) == 2
           middle = cat(1,middle,rcqual);
           
       end
           
       
    end
end
%%
histWindow = [-1:.1:1]
cornerHist = hist(corners,histWindow);
middleHist = hist(middle,histWindow);
bar(histWindow,[cornerHist; middleHist]')

