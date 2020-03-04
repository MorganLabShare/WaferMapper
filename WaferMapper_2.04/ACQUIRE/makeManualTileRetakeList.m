%% Make manual retake list

%%Enter list
sections = ...
    [10,13,44,48,76,80,89,117,123,127,128,130,148,152,157,158,159,162,182,...
    183,185,190,202,206,218,226,231,245,282];

% tiles{53} = [4 4];
% tiles{9} = [1 4];
% 
% 
% tiles{max(sections)+1} = [];

manualRetakeList.sections = sections;
% manualRetakeList.tiles = tiles;

TPN = GetMyDir;


save([TPN 'manualRetakeList.mat'],'manualRetakeList');