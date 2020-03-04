function DrawBox(CenterX, CenterY, Width, Height, ColorArray)
    LeftX =  CenterX - floor(Width/2);
    RightX = LeftX + Width;
    TopY = CenterY - floor(Height/2);
    BottomY = TopY + Height;
    
    h1 = line([LeftX LeftX],[TopY BottomY]); %left line
    h2 = line([RightX RightX],[TopY BottomY]); %right line
    h3 = line([LeftX RightX],[TopY TopY]); %top line
    h4 = line([LeftX RightX],[BottomY BottomY]); %bottom line
    set(h1, 'Color', ColorArray);
    set(h2, 'Color', ColorArray);
    set(h3, 'Color', ColorArray);
    set(h4, 'Color', ColorArray);
end
