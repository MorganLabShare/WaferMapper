

MontageStackDir = 'Z:\Hayworth\MasterUTSLDir\Cortex\w007\MontageStack_08';

for SecNum=24:44
    MontageDir = sprintf('%s\\w007_Sec%d_Montage',MontageStackDir, SecNum);
    disp(sprintf(' Loading Dir: %s',MontageDir));
    [ArrayOfTileInfos] = UtilityScript_ReadInfoForAllTilesInMontageDir(MontageDir);
    
    for i = 1:length(ArrayOfTileInfos)
        Info = ArrayOfTileInfos(i).Info;
        disp(sprintf('   Info.ScanRotation = %0.5g', Info.ScanRotation));
    end
end