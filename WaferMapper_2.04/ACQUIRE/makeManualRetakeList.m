%% Make manual retake list

%%Enter list
manualRetakeList = ...
[196:197];
%manualRetakeList = sort(manualRetakeList,'ascend')
TPN = GetMyDir;


save([TPN 'manualRetakeList.mat'],'manualRetakeList');