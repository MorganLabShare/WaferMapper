% function[allTiles] = selectTiles(NumRowTiles,NumColTiles)


NumRowTiles = 3;
NumColTiles = 3;

selFig = figure;

field = zeros(NumRowTiles,NumColTiles)+50;
field(1:2:end) = 150;
fieldGrey = uint8(cat(3,field,field,field));
image(fieldGrey)

[y x] = find(field);
solidTiles = [y x];

useTiles = y * 0 + 1;
allTiles = solidTiles(useTiles,:);


