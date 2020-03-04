function [] = UtilityScript_AlalizeGridAutoFocusStatsAcrossMultipleSections()

MontageStackDir = uigetdir('W:\Hayworth\','Pick the montage stack directory');
if MontageStackDir == 0
    return;
end

%Y:\Hayworth\MontageStack_JM_YR1C_w008_11_9_2011\w008_Sec1_Montage

DirAndWildCardStr = sprintf('%s\\*_Montage',MontageStackDir);
ListOfMontageDirectories = dir(DirAndWildCardStr)


OrderedArrayOfMontageDirectoryNames = [];
for i = 1:length(ListOfMontageDirectories)
    TempArray = strfind(ListOfMontageDirectories(i).name,'_');
    SectionNumStr = ListOfMontageDirectories(i).name(TempArray(end-1)+4:TempArray(end)-1);
    SectionNum = str2num(SectionNumStr);
    
    OrderedCellArrayOfMontageDirectoryNames{SectionNum} = ListOfMontageDirectories(i).name;
    
end




MovieFrameNum = 0;
for SectionNum = 1:length(OrderedCellArrayOfMontageDirectoryNames)
    MontageDirName = OrderedCellArrayOfMontageDirectoryNames{SectionNum};
    
    if ~isempty(MontageDirName)
        MovieFrameNum = MovieFrameNum + 1;
        MontageDir = sprintf('%s\\%s', MontageStackDir, MontageDirName);
        disp(sprintf('Analizing: %s',  MontageDir));
        
        [InfoForGridAutoFocus, ImageOfFigure] = UtilityScript_PlotAutoFocusForMontageDir(MontageDir); %KH added 11-14-2011
        
        if ~isempty(ImageOfFigure)
            
            M(MovieFrameNum) = im2frame(ImageOfFigure);
            
            
            
            %load InfoForGridAutoFocus.mat file for this section
            InfoForGridAutoFocus_FileNameStr = sprintf('%s\\InfoForGridAutoFocus.mat',MontageDir);
            load(InfoForGridAutoFocus_FileNameStr);
            
            %Fit the plane for this section
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
            
            for i = 1:length(Z)
                z_OfAFPointFromPlaneFit = ReturnedPlaneFitObject(X(i),Y(i));
                
                DistFromPlaneFit_Microns = (Z(i)-z_OfAFPointFromPlaneFit)*1000000;
                
                if abs(DistFromPlaneFit_Microns) > 0.5
                    FID_OUTPUT = 2; %standard error red output text
                else
                    FID_OUTPUT = 1; %standard black output text
                end
                
                
                fprintf(FID_OUTPUT,'   AF point#%d, Distance from plane fit %0.3g (microns)\n', i, DistFromPlaneFit_Microns);
            end
            
        else
            MovieFrameNum = MovieFrameNum - 1; %skip this movie frame
        end
        
    
        
    end
    
    
end

%[FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE)
[MovieFileName, MoviePathName, MovieFilterIdex] = uiputfile('*.avi', 'Save AVI movie file as...');
MovieFileNameFullPath = sprintf('%s%s',MoviePathName, MovieFileName)
movie2avi(M,MovieFileNameFullPath, 'COMPRESSION', 'None');

