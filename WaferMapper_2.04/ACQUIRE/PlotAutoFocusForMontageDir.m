%function PlotAutoFocusForMontageDir()
clear all;
close all;
MontageDir = uigetdir('.','Pick the montage directory');
if MontageDir == 0
    return;
end


% load('InfoForGridAutoFocus_FirstTest.mat');
% InfoForGridAutoFocus_FirstTest = InfoForGridAutoFocus;

% load('InfoForGridAutoFocus_SecondTest.mat');
% InfoForGridAutoFocus_SecondTest = InfoForGridAutoFocus;
InfoForGridAutoFocus_FileNameStr = sprintf('%s\\InfoForGridAutoFocus.mat',MontageDir);
load(InfoForGridAutoFocus_FileNameStr);


X = InfoForGridAutoFocus.WD_PointsForPlaneFit_StageX;
Y = InfoForGridAutoFocus.WD_PointsForPlaneFit_StageY;
Z = InfoForGridAutoFocus.WD_PointsForPlaneFit_WD;

MedianValueGridAF_WD = median(Z);

ModelStr = 'poly11'; %'poly11'
%generate plane fit object
ReturnedPlaneFitObject = fit( [X, Y], ...
    Z, ModelStr); %'lowess'

%Calculate residuals
for i = 1:length(X)
    Z_residual(i) = ReturnedPlaneFitObject(X(i), Y(i)) - Z(i);
end

%Throw out any outliers
StdOfResiduals = std(Z_residual);
n = 1;
for i = 1:length(X)
    if abs(Z_residual(i)) < 2*StdOfResiduals;
        %non-outliers are plotted in blue
        ColorForPlot(i,1) = 0;
        ColorForPlot(i,2) = 0;
        ColorForPlot(i,3) = 1;
        X_AfterOutliersRemoved(n,1) = X(i);
        Y_AfterOutliersRemoved(n,1) = Y(i);
        Z_AfterOutliersRemoved(n,1) = Z(i);
        n = n + 1;
    else
        %outliers are plotted in red
        ColorForPlot(i,1) = 1;
        ColorForPlot(i,2) = 0;
        ColorForPlot(i,3) = 0;
    end
end

%regenerate plane fit object after outliers removed
ReturnedPlaneFitObject = fit( [X_AfterOutliersRemoved, Y_AfterOutliersRemoved], ...
    Z_AfterOutliersRemoved, ModelStr); %'lowess'



% X_First = InfoForGridAutoFocus_FirstTest.WD_StageX_array*1000
% Y_First = InfoForGridAutoFocus_FirstTest.WD_StageY_array*1000
% Z_First = InfoForGridAutoFocus_FirstTest.WD_array*1000

% X_Second = InfoForGridAutoFocus_SecondTest.WD_StageX_array*1000
% Y_Second = InfoForGridAutoFocus_SecondTest.WD_StageY_array*1000
% Z_Second = InfoForGridAutoFocus_SecondTest.WD_array*1000

figure(9876);
S = 0*X + 15; %size of dots
scatter3(X,Y,(Z-MedianValueGridAF_WD)*1000000,S,ColorForPlot);
hold on;



%Load mat files for 
n = 1;
%dir('Z:\ForJosh\AW01_Sec65_Montage\*.mat')
DirAndWildCardStr = sprintf('%s\\*.mat',MontageDir);
ListOfMatFiles = dir(DirAndWildCardStr);
for i = 1:length(ListOfMatFiles)
    FileName = ListOfMatFiles(i).name;
    if length(FileName) >= 5
        if strcmp('Tile_',FileName(1:5))
            disp(sprintf('Loading file: %s',FileName));
            FileNameAndPath = sprintf('%s\\%s', MontageDir, FileName);
            load(FileNameAndPath);
            
            %Tile_r1-c6_AW01_sec65
            TempArray = strfind(FileName,'_');
            SubStr = FileName(TempArray(1)+2:end);
            TempArray2 = strfind(SubStr,'-');
            RowStr = SubStr(1:TempArray2(1)-1);
            TempArray3 = strfind(SubStr,'_');
            ColStr = SubStr(TempArray2(1)+2:TempArray3(1)-1);
            
     
            R_FromTiles(n,1) = str2num(RowStr);
            C_FromTiles(n,1) = str2num(ColStr);
            
            
            
            X_FromTiles(n,1) = Info.StageX_Meters;
            Y_FromTiles(n,1) = Info.StageY_Meters;
            Z_FromTiles(n,1) = Info.WorkingDistance;
            
            Z_DistTileFocusFromFitPlane(n,1) = ReturnedPlaneFitObject(Info.StageX_Meters,Info.StageY_Meters) - Info.WorkingDistance;
            
            n = n+1;
        end
    end
end

scatter3(X_FromTiles,Y_FromTiles,(Z_FromTiles-MedianValueGridAF_WD)*1000000,'k');
OriginalAxis = axis;
NewAxis = OriginalAxis;
NewAxis(5) = MedianValueGridAF_WD - 5;
NewAxis(6) = MedianValueGridAF_WD + 5;
axis(NewAxis);

%plot plane fit
MinX = min(X_FromTiles);
MaxX = max(X_FromTiles);
MinY = min(Y_FromTiles);
MaxY = max(Y_FromTiles);
% LINSPACE(X1, X2, N) generates N points between X1 and X2.
%     For N < 2, LINSPACE returns X2.
XRangeArray = linspace(MinX, MaxX, 10);
YRangeArray = linspace(MinY, MaxY, 10);

for XIndex = 1:length(XRangeArray)
    for YIndex = 1:length(YRangeArray)
        x = XRangeArray(XIndex);
        y = YRangeArray(YIndex);
        z = ReturnedPlaneFitObject(x,y);
        X_ForMeshGrid(XIndex, YIndex) = x;
        Y_ForMeshGrid(XIndex, YIndex) = y;
        Z_ForMeshGrid(XIndex, YIndex) = z;
    end
end

mesh(X_ForMeshGrid, Y_ForMeshGrid, (Z_ForMeshGrid-MedianValueGridAF_WD)*1000000);

%figure(200);
%scatter3(X_FromTiles,Y_FromTiles,Z_DistTileFocusFromFitPlane);

[SortedAbsOffsetsFromPlaneFit IndicesOfSort] = sort(abs(Z_DistTileFocusFromFitPlane),'descend');

for i = 1:length(IndicesOfSort)
    n = IndicesOfSort(i);
    AbsOffset = Z_DistTileFocusFromFitPlane(n);
    RowNum = R_FromTiles(n);
    ColNum = C_FromTiles(n);
    MyStr = sprintf('AbsOffset = %d microns, R=%d, C=%d',AbsOffset*1000000,RowNum,ColNum);
    disp(MyStr);
end

% disp('Top five max tile offsets from fit plane in microns:');
% SortedAbsOffsetsFromPlaneFit*1000000

xlabel('Stage Pos (meters)');
ylabel('Stage Pos (meters)');
zlabel('WD from plane points median (microns)');
title(MontageDir);
