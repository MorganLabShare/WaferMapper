function[] = testSafeSave()
TPN = GetMyDir

%%
tk = 'this is a success';



safeSave([TPN 'testMy.mat'],'tk',tk)
clear tk
load([TPN 'testMy.mat'])

tk