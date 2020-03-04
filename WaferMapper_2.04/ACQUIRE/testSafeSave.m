function[] = testSafeSave()
TPN = GetMyDir

%%
tk = 'this is a success';



safeSave([TPN 'testMit.mat'],'tk')
clear tk
load([TPN 'testMit.mat'])

tk