%Y:\Hayworth\CerebellumStack_7_10_2011\1\Tile_r1-c1_1.tif

%Y:\Hayworth\MontageStack_JM_YR1C_w008\w008_Sec125_Montage\Tile_r2-c3_w008_sec125.tif
for i = 145:166
    FileName = sprintf('Z:\\Hayworth\\MontageStack_JM_YR1C_w008\\w008_Sec%d_Montage\\Tile_r2-c3_w008_sec%d.tif',i,i);
    %exist(FileName,'file')
    MyNumStr = num2str(i+1000);
    
    TargetFileName = sprintf('Z:\\Hayworth\\CenterTile_JM_YR1C_w008\\Tile_r2-c3_w008_sec%s.tif',MyNumStr(2:end));
    
    %CmdStr = sprintf('move %s %s', FileName, TargetFileName);
    CmdStr = sprintf('copy %s %s', FileName, TargetFileName);
    disp(CmdStr);
    dos(CmdStr);
end