function[] =  UpdateTextOnStageStitched(NumRowTiles, NumColTiles, StitchFigNum, StageStitched_TextStringsArray)

         figure(StitchFigNum);

title(StageStitched_TextStringsArray(1, 1).title);
for tR = 1:NumRowTiles
    for tC = 1:NumColTiles
        textX = StageStitched_TextStringsArray(tR, tC).textX;
        textY = StageStitched_TextStringsArray(tR, tC).textY;
        MyText = StageStitched_TextStringsArray(tR, tC).Text;
        %TEXT(X,Y,'string')
        h = text(textX, textY, MyText);
        set(h,'Color', StageStitched_TextStringsArray(tR, tC).Color);
        set(h,'FontSize', 18);
    end
end

end