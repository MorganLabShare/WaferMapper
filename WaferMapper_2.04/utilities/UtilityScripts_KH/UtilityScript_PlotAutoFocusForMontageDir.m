function [InfoForGridAutoFocus, ImageOfFigure] = UtilityScript_PlotAutoFocusForMontageDir(MontageDirInput)

ImageOfFigure = [];

if nargin < 1
    IsCalledAsSubFunction = false;
else
    IsCalledAsSubFunction = true;
end

if ~IsCalledAsSubFunction
    MontageDir = uigetdir('W:\Hayworth\stack_w009\','Pick the montage directory');
    if MontageDir == 0
        return;
    end
else
    MontageDir = MontageDirInput; 
end


InfoForGridAutoFocus_FileNameStr = sprintf('%s\\InfoForGridAutoFocus.mat',MontageDir);
load(InfoForGridAutoFocus_FileNameStr);

[MaxR, MaxC] = size(InfoForGridAutoFocus.WD_array);
for r = 1:MaxR
    for c = 1:MaxC
        if ~IsCalledAsSubFunction
            disp(sprintf('FocusPoint#(%d,%d), WD = %0.5g (microns)', r, c, 1000000*InfoForGridAutoFocus.WD_array(r,c)));
        end
    end
end

X = InfoForGridAutoFocus.WD_PointsForPlaneFit_StageX;
Y = InfoForGridAutoFocus.WD_PointsForPlaneFit_StageY;
Z = InfoForGridAutoFocus.WD_PointsForPlaneFit_WD;
MedianValueGridAF_X = median(X);
MedianValueGridAF_Y = median(Y);
MedianValueGridAF_WD = median(Z);

if length(X) >= 3
    ReturnedPlaneFitObject = fit( [X, Y], ...
        Z, 'poly11'); %'lowess'
    IsReturnedPlaneFit = true;
else
    IsReturnedPlaneFit = false;
end



h_3DFigure = figure; %(9876);
S = 15; %size of dots
scatter3((X-MedianValueGridAF_X)*1000000,(Y-MedianValueGridAF_Y)*1000000,(Z-MedianValueGridAF_WD)*1000000,S);
hold on;



%Load mat files for 
R_FromTiles = [];
C_FromTiles = [];
X_FromTiles = [];
Y_FromTiles = [];
Z_FromTiles = [];
Z_DistTileFocusFromFitPlane = [];
n = 1;
DirAndWildCardStr = sprintf('%s\\*.mat',MontageDir);
ListOfMatFiles = dir(DirAndWildCardStr);
for i = 1:length(ListOfMatFiles)
    FileName = ListOfMatFiles(i).name;
    if length(FileName) >= 5
        if strcmp('Tile_',FileName(1:5))
            if ~IsCalledAsSubFunction
                disp(sprintf('Loading file: %s',FileName));
            end
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

if isempty(X_FromTiles)
   close(h_3DFigure);
   return; 
end

figure(h_3DFigure);
scatter3((X_FromTiles-MedianValueGridAF_X)*1000000,(Y_FromTiles-MedianValueGridAF_Y)*1000000,(Z_FromTiles-MedianValueGridAF_WD)*1000000,'k');
OriginalAxis = axis;
NewAxis = OriginalAxis;
NewAxis(5) = MedianValueGridAF_WD - 5;  %make plot range +/-5 microns
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

MinZ = min(Z_FromTiles);
MaxZ = max(Z_FromTiles);


figure(h_3DFigure);
mesh((X_ForMeshGrid-MedianValueGridAF_X)*1000000, (Y_ForMeshGrid-MedianValueGridAF_Y)*1000000, (Z_ForMeshGrid-MedianValueGridAF_WD)*1000000);
xlabel('Stage Pos (microns)');
ylabel('Stage Pos (microns)');
zlabel('WD from plane points median (microns)');

ArrayOfSlashIndices = findstr(MontageDir, '\');
JustNameOfMontageDir = MontageDir(ArrayOfSlashIndices(end):end);
TitleStr = sprintf('%s  deltaWD = %0.5g (microns)', JustNameOfMontageDir, 1000000*(MaxZ - MinZ));
title(TitleStr, 'interpreter', 'none');


%determine how far off each of the autofocus points was from the fit plane
if ~IsCalledAsSubFunction
    disp('PRINT OUT OF RESULTS:');
    for i = 1:length(Z)
        z_OfAFPointFromPlaneFit = ReturnedPlaneFitObject(X(i),Y(i));
        disp(sprintf('   AF point#%d, Distance from plane fit %0.3g (microns)', i, (Z(i)-z_OfAFPointFromPlaneFit)*1000000));
    end
end


if IsCalledAsSubFunction
    ImageOfFigure = frame2im(getframe(h_3DFigure));
    close(h_3DFigure);
else
    ImageOfFigure = [];
end
