function UtilityScript_PlotOffsetsOfAlignedTargetList()

load Z:\Hayworth\MasterUTSLDir\Cerebellum_JM_YR1C_ForPosTest_UTSL\AlignedTargetListsDirectory\TargetPoint01\AlignedTargetList.mat;



for SectionNum = 1:length(AlignedTargetList.WaferArray(1).SectionArray)
    XOffset_microns_Array(SectionNum) = AlignedTargetList.MicronsPerPixel * AlignedTargetList.WaferArray(1).SectionArray(SectionNum).XOffsetOfNewInPixels;
    YOffset_microns_Array(SectionNum) = AlignedTargetList.MicronsPerPixel * AlignedTargetList.WaferArray(1).SectionArray(SectionNum).YOffsetOfNewInPixels;
end

SecNumArray = 1:length(XOffset_microns_Array);

figure(1);
subplot(2,1,1);
plot(SecNumArray, XOffset_microns_Array);
title('X\_Offset\_Array');
ylabel('(microns)');
subplot(2,1,2);
plot(SecNumArray, YOffset_microns_Array);
title('Y\_Offset\_Array');
ylabel('(microns)');
xlabel('Section Number');

figure(2);
%SCATTER(X,Y,S,C)
scatter(XOffset_microns_Array, YOffset_microns_Array);
axis equal;
title('Position offsets');
xlabel('(microns)');
ylabel('(microns)');


%Compute Statistics
MeanX = mean(XOffset_microns_Array);
StdX = std(XOffset_microns_Array);
RangeX = max(XOffset_microns_Array) - min(XOffset_microns_Array);
MeanY = mean(YOffset_microns_Array);
StdY = std(YOffset_microns_Array);
RangeY = max(YOffset_microns_Array) - min(YOffset_microns_Array);

disp(sprintf('X: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanX, StdX, RangeX));
disp(sprintf('Y: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanY, StdY, RangeY));