function [StageTransform, FudgeScaleUsed] = CalculateOffsetOfAllFiducials(FiducialsDirectory, ReimageFiducialsDirectory, IsCalculateFudgeScale, FudgeScaleToUseOtherwise)
global GuiGlobalsStruct;



FiducialNum = 1;
while true
    FiducialNumStr = sprintf('%d',(100 + FiducialNum));
    OriginalImageFileNameStr = sprintf('%s\\Fiducial_%s.tif',FiducialsDirectory,FiducialNumStr(2:3));
    OriginalDataFileNameStr = sprintf('%s\\Fiducial_%s.mat',FiducialsDirectory,FiducialNumStr(2:3));
    ReimagedFiducialFileNameStr = sprintf('%s\\Fiducial_%s.tif',ReimageFiducialsDirectory,FiducialNumStr(2:3));
    ReimagedDataFileNameStr = sprintf('%s\\Fiducial_%s.mat',ReimageFiducialsDirectory,FiducialNumStr(2:3)); %note: this may have diferent coordinates due to transformation

    if exist(ReimagedFiducialFileNameStr, 'file')
        
        disp(sprintf('Loading image file: %s',OriginalImageFileNameStr));
        OriginalImage = imread(OriginalImageFileNameStr,'tif');
        disp(sprintf('Loading image file: %s',ReimagedFiducialFileNameStr));
        ReImagedImage = imread(ReimagedFiducialFileNameStr,'tif');
        
        %load info for the original fiducial
        disp(sprintf('Loading %s', OriginalDataFileNameStr));
        load(OriginalDataFileNameStr,'Info');
        
        FOV_microns = Info.ReadFOV_microns; %KH replaced with ReadFOV_microns on 6-15-2011
        ImageWidthInPixels = Info.ImageWidthInPixels;
        ImageHeightInPixels = Info.ImageHeightInPixels;
        Original_StageX_Meters = Info.StageX_Meters;
        Original_StageY_Meters = Info.StageY_Meters;
        OriginalImageMag = Info.Mag;
        
        %load info for the reimaged fiducial
        disp(sprintf('Loading %s', ReimagedDataFileNameStr));
        load(ReimagedDataFileNameStr,'Info');
        Reimaged_StageX_Meters = Info.StageX_Meters;
        Reimaged_StageY_Meters = Info.StageY_Meters;
        ReImagedImageMag = Info.Mag;
        
        %KH Here is a quick correction for mag difference between the two
        %imaging sessions
        %KH removed 10_17_2011 %[OriginalImage, ReImagedImage] = EqualizeMags(OriginalImage, OriginalImageMag, ReImagedImage, ReImagedImageMag);
        
        
        
        pixelsize_Meters = (FOV_microns/ImageWidthInPixels)/1000000;
        
        DSFactor = 4; %KH Note this used to be '2' but I changed it to make it run faster   %2;
        OriginalImageDS = imresize(OriginalImage,1/DSFactor,'bilinear'); %Must down sample by 8x to prevent out of memory error on fibics computer
        ReImagedImageDS = imresize(ReImagedImage,1/DSFactor,'bilinear');
        
        

        
        %START: Code to do different scales
        if IsCalculateFudgeScale
            
            if FiducialNum == 1  %Only run through different scales on first fiducial
                [BestScaleFactorFromFirstFiducial] = DetermineBestScaleBetweenImages(OriginalImageDS,  ReImagedImageDS);
                
%                 h_figMsgBox = msgbox(sprintf('Scale_Best = %0.5g, Continuing in 5 seconds...', BestScaleFactorFromFirstFiducial));
%                 beep;pause(.1);beep;pause(.1);beep;
%                 pause(5);
%                 if ishandle(h_figMsgBox)
%                     close(h_figMsgBox);
%                 end
                
                %Save this found scale factor for later displaying
                ScaleFactorDataFileNameStr = sprintf('%s\\ComputedScaleFactor.mat',ReimageFiducialsDirectory);
                save(ScaleFactorDataFileNameStr, 'BestScaleFactorFromFirstFiducial');
                
            end
            
        else
            BestScaleFactorFromFirstFiducial = FudgeScaleToUseOtherwise;
        end
        
        
        OriginalImageDS_DummyMag = 1;
        ReImagedImageDS_DummyMag = BestScaleFactorFromFirstFiducial;
        
        [OriginalImageDS_scaled, ReImagedImageDS_scaled] = EqualizeMags(OriginalImageDS, OriginalImageDS_DummyMag, ReImagedImageDS, ReImagedImageDS_DummyMag);
        
        %function [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] = ...
         %       CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImage, NewImage, CenterAngle, AngleIncrement, NumMultiResSteps)
         CenterAngle = 0;
         AngleIncrement = 1;
         NumMultiResSteps = 1;
         
         % add band pass joshm
         OriginalImageDS_scaled = mexHatFiducial(OriginalImageDS_scaled);
         ReImagedImageDS_scaled = mexHatFiducial(ReImagedImageDS_scaled);

        [XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees, FigureOfMerit] =...
            CalcPixelOffsetAndAngleBetweenTwoImagesMultiScale(OriginalImageDS_scaled, ReImagedImageDS_scaled, CenterAngle, AngleIncrement, NumMultiResSteps);
        
   

        PlotRedGreenOverlapOfTwoImages(OriginalImageDS_scaled, ReImagedImageDS_scaled, XOffsetOfNewInPixels, YOffsetOfNewInPixels, AngleOffsetOfNewInDegrees);
        %uiwait(msgbox('Program debugging pause. Press OK to continue.'));
        
   
        XOffset_Meters = XOffsetOfNewInPixels*DSFactor*pixelsize_Meters;
        YOffset_Meters = YOffsetOfNewInPixels*DSFactor*pixelsize_Meters;
        
        %Save these here for analysis outside of function
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).XOffset_Meters = XOffset_Meters;
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).YOffset_Meters = YOffset_Meters;
        
        MyStr = sprintf('FIDUCIAL# %d\n  XOffset_Meters = %d\n  YOffset_Meters = %d\n  AngleOffsetOfNewInDegrees = %d',...
            FiducialNum, XOffset_Meters, YOffset_Meters,  AngleOffsetOfNewInDegrees);
        disp(MyStr);
        
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).Original_StageX_Meters = Original_StageX_Meters;
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).Original_StageY_Meters = Original_StageY_Meters;
        
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).ReImaged_StageX_Meters = Reimaged_StageX_Meters - XOffset_Meters;
        GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).ReImaged_StageY_Meters = Reimaged_StageY_Meters - YOffset_Meters;
        
        
    else
        break;
    end
    
    FiducialNum = FiducialNum + 1;
end

INPUT_POINTS_Meters = [];
BASE_POINTS_Meters = [];
for FiducialNum = 1:length(GuiGlobalsStruct.FiducialAlignmentArray)
    %     TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,TRANSFORMTYPE) returns a TFORM
    %     structure containing a spatial transformation. INPUT_POINTS is an M-by-2
    %     double matrix containing the X and Y coordinates of control points in
    %     the image you want to transform. BASE_POINTS is an M-by-2 double matrix
    %     containing the X and Y coordinates of control points in the base
    %     image.
    
    %Since we want a transform that will take original wafer coordinates
    %(from mapping sessions) and transform them to the current session the
    %INPUT_POINTS should come from the original wafer fiducial points
    INPUT_POINTS_Meters(FiducialNum,1) = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).Original_StageX_Meters;
    INPUT_POINTS_Meters(FiducialNum,2) = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).Original_StageY_Meters;
    
    BASE_POINTS_Meters(FiducialNum,1) = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).ReImaged_StageX_Meters;
    BASE_POINTS_Meters(FiducialNum,2) = GuiGlobalsStruct.FiducialAlignmentArray(FiducialNum).ReImaged_StageY_Meters;

end

%StageTransform is returned from function
StageTransform = cp2tform(INPUT_POINTS_Meters,BASE_POINTS_Meters,'nonreflective similarity');
disp('Computed stage transformation:');
StageTransform.tdata.T

FudgeScaleUsed = BestScaleFactorFromFirstFiducial;