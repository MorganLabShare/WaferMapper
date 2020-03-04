function[tileList] = nearestSpiral(tileList,t,listStageX_Meters,listStageY_Meters,lastFocusPoint)

%%Get distance to other tiles

%{
% simulation data
listStageX_Meters = repmat((1:4)',4,1)
listStageY_Meters = [];
for i = 1:4 
    listStageY_Meters = cat(1,listStageY_Meters,ones(4,1)*i)
end
lastFocusPoint = [2.5 2.5];
tileList = 1:16;
t = 0;
showTiles = zeros(4,4);
%}
%% 
for n = t:length(tileList)-1
    dist2foc = sqrt((listStageX_Meters(tileList) - lastFocusPoint(1)).^2 + (listStageY_Meters(tileList)-lastFocusPoint(2)).^2);
    if n < 1 %if no tile has been taken yet
        dist2last = dist2foc * 0;
    else
        dist2last = sqrt((listStageX_Meters(tileList) - listStageX_Meters(tileList(n))).^2 ...
            + (listStageY_Meters(tileList)-listStageY_Meters(tileList(n))).^2);
    end %if no tile has been taken yet
    totalDist = dist2last *1.4 + dist2foc;
    remainingDists = totalDist(n+1:end);
    remainingTiles = tileList(n+1:end);
    nextTile = remainingTiles(find(remainingDists == min(remainingDists),1));
    tileList(tileList==nextTile) = tileList(n+1);
    tileList(n+1) = nextTile;
end


%{

showTiles(tileList) = 1:16

%}