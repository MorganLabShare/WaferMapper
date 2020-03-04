function[TPN] = GetMyDir()



%% Get Folder 

if ~exist('.\temp'), mkdir('.\temp'),end

if exist('.\temp\Last.mat')
     load(['.\temp\Last.mat'])
     if exist(Last)
        TPN=uigetdir(Last)
     else
         TPN=uigetdir
     end
else
    TPN=uigetdir
end

TPN= [TPN '\'];

Last=TPN;
if Last>0
save('.\temp\Last.mat','Last')
end
