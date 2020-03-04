function[groupTiles focusPoints] = Focus_4square(listStageX_Meters,listStageY_Meters,allTiles,listTakeImage)%(RowDistanceBetweenTileCentersInMicrons, ColDistanceBetweenTileCentersInMicrons, SaveDir)
%This function uses the current scan rotation to determine how to move the
%stage from the current stage position. It assumes that the calling
%function has properly setup the scan rotation.
global GuiGlobalsStruct;


shortTiles = fix((allTiles+1)/2);
groupNum = sub2ind([max(shortTiles(:,1)) max(shortTiles(:,2))], shortTiles(:,1), shortTiles(:,2));

for i = 1:max(groupNum)
    groupInd = find((groupNum == i) & listTakeImage');
    groupTiles{i} = groupInd;
    focusX(i) = mean(listStageX_Meters(groupInd));
    focusY(i) = mean(listStageY_Meters(groupInd));
end

focusPoints = [focusX' focusY'];




