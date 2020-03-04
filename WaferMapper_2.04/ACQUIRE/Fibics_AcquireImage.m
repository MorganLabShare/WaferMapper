function Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
    FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr, IsReturnImmediatly)
%function Fibics_AcquireImage(MyCZEMAPIClass, ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
%    FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
%
%   Function calls Fibics to acquire the image and automatically creats a
%   *.mat file saving all acquition info as well. This file is gaurenteed
%   not to return until file is finished writing to disk
global GuiGlobalsStruct; %Note: I should make this a parameter but I am having problems with Matlab passing this
MyCZEMAPIClass = GuiGlobalsStruct.MyCZEMAPIClass;


%Set FOV or Mag
MyCZEMAPIClass.Fibics_WriteFOV(FOV_microns); %Always set the FOV even if you are overriding with mag (might be used in some way inside Fibics)
pause(0.1); %1

if IsMagOverride
    MyCZEMAPIClass.Set_PassedTypeSingle('AP_MAG',MagForOverride);
end
pause(.1); %1


%Data file will have same name as image but have .mat extension
DataFileNameStr = sprintf('%s.mat',FileNameStr(1:end-4));

%KH: This Fibics_AcquireImage function is often used in the larger code
%with a check after it to wait if the file has already been written. This
%will give a race condition if there is already a file with the same name.
%Therefore this code checks to see if the file name already exists and
%renames it (and its .mat file) with a unique date-stamped postfix to eliminate this race
%condition datestr(now,30) = 20111027T224057

[ExtractedPathStr,ExtractedFileName,ExtractedExt] = fileparts(FileNameStr);
UID_DateStr = datestr(now,30);
ImageFileRenameCommandForDos = sprintf('rename %s %s_%s.tif',  FileNameStr, ExtractedFileName, UID_DateStr);
DataFileRenameCommandForDos = sprintf('rename %s %s_%s.mat',  DataFileNameStr, ExtractedFileName, UID_DateStr);
%DataFileRenameCommandForDos = sprintf('rename %s %s_%s%s',  DataFileNameStr, DataFileNameStr(1:end-4), UID_DateStr, DataFileNameStr(end-3:end))


if exist(FileNameStr, 'file')
    disp('Executing dos command:');
    disp(sprintf('   %s', ImageFileRenameCommandForDos));
    for dp = 1:20
        dossPass = 1;
        try  dos(ImageFileRenameCommandForDos);
        catch err
            dossPass = 0;
            disp(sprintf('Failed to rename %s',ImageFileRenameCommandForDos))
            pause(5)
        end
        if dossPass, break,end
    end
end

if exist(DataFileNameStr, 'file')
    disp('Executing dos command:');
    disp(sprintf('   %s', DataFileRenameCommandForDos));
    for dp = 1:20
        dossPass = 1;
        try   dos(DataFileRenameCommandForDos);
        catch err
            dossPass = 0;
            disp(sprintf('Failed to rename %s',DataFileRenameCommandForDos))
            pause(5);
        end
        if dossPass ,break,end
    end
end

%Acquire image
tic
MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
    DwellTimeInMicroseconds,FileNameStr);

IsSkipWaitStuff = false;
if exist('IsReturnImmediatly', 'var')
    if IsReturnImmediatly == true
        IsSkipWaitStuff = true;
    end
end
 
if ~IsSkipWaitStuff
    'Waiting for image to finish'
    while(MyCZEMAPIClass.Fibics_IsBusy)
        pause(.2); %1
    end
    
    
    %Try to read this image downsampled. Continue trying until it works meaning
    %that Fibics is done writing file
    IfCheckFileIsWritten = true;
    if IfCheckFileIsWritten
        
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                MyDownSampledImage = imread(FileNameStr, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
            catch MyException
                IsReadOK = false;
                pause(0.5);
            end
        end
        
        %Perform auto retake if needed
        if IsDoAutoRetakeIfNeeded
            AvgOfBottom10PercentOfImage = mean(mean(MyDownSampledImage(floor(end*0.9):end,:)));
            if (AvgOfBottom10PercentOfImage < 5) || (AvgOfBottom10PercentOfImage > 250) %reacquire image
                disp(sprintf('POSSIBLE FIBICS IMAGING FAULT, Reacquiring %s.',FileNameStr));
                BadFileName = sprintf('%s_BadImage.tif',FileNameStr(1:(end-4)));
                %MOVEFILE(SOURCE,DESTINATION,MODE)
                for moveTry = 1:100;
                    goodMove = 1;
                    try movefile(FileNameStr,BadFileName);
                    catch err
                        dips(sprintf('Failed to move %s.',FileNameStr))
                        goodMove = 0;
                        pause(5)
                    end
                    if goodMove,break,end %move on if finished
                end
                
                if goodMove
                    pause(.2);
                    MyCZEMAPIClass.Fibics_AcquireImage(ImageWidthInPixels,ImageHeightInPixels,...
                        DwellTimeInMicroseconds,FileNameStr);
                    while(MyCZEMAPIClass.Fibics_IsBusy)
                        pause(1);
                    end
                    pause(1);
                    IsReadOK = false;
                    while ~IsReadOK
                        IsReadOK = true;
                        try
                            MyDownSampledImage = imread(FileNameStr, 'PixelRegion', {[1 16 ImageWidthInPixels], [1 16 ImageWidthInPixels]});
                        catch MyException
                            IsReadOK = false;
                            pause(0.5);
                        end
                    end
                end %end if goodMove
            end
        end
        
    end
    
end

%Save all info to a file with same name but .mat extension
%Save info
Info.WaferName = WaferNameStr;
Info.Label = LabelStr;

Info.FOV_microns = FOV_microns; %This is the requested FOV
Info.ReadFOV_microns = MyCZEMAPIClass.Fibics_ReadFOV(); %KH inserted to record actual FOV Fibics got to
Info.IsMagOverride = IsMagOverride;
Info.Mag = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_MAG');

Info.ImageWidthInPixels = ImageWidthInPixels;
Info.ImageHeightInPixels = ImageHeightInPixels;
Info.DwellTimeInMicroseconds = DwellTimeInMicroseconds;

Info.StageX_Meters = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_X');
Info.StageY_Meters = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Y');
Info.stage_z = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_Z');
Info.stage_t = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_T');
Info.stage_r = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_R');
Info.stage_m = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STAGE_AT_M');

Info.ScanRotation = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_SCANROTATION');

Info.WorkingDistance = MyCZEMAPIClass.Get_ReturnTypeSingle('AP_WD');

%save stig, contrast, and brightness values (since Fibics uses these from
%the xml file)
Info.Brightness = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_BRIGHTNESS');
Info.Contrast = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_CONTRAST');
Info.StigX = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_X');
Info.StigY = GuiGlobalsStruct.MyCZEMAPIClass.Get_ReturnTypeSingle('AP_STIG_Y');



if isfield(GuiGlobalsStruct, 'MontageTarget')
   Info.MontageTarget = GuiGlobalsStruct.MontageTarget; %save coordinates in section frame
end


safeSave(DataFileNameStr,'Info');
 

end




