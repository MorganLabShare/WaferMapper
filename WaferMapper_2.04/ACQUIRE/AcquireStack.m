%AcquireStack

if ~exist(GuiGlobalsStruct.TempImagesDirectory,'dir')
    [success,message,messageid] = mkdir(GuiGlobalsStruct.TempImagesDirectory);
end

for i = 1:length(GuiGlobalsStruct.CoarseSectionList)

    LabelStr = GuiGlobalsStruct.CoarseSectionList(i).Label;
    ImageFileNameStr = sprintf('%s\\StackImage_%s.tif', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    DataFileNameStr = sprintf('%s\\StackImage_%s.mat', GuiGlobalsStruct.TempImagesDirectory, LabelStr);
    
    
    
    
    
    
    %do not overwrite, this allows for easy retakes
    if exist(ImageFileNameStr,'file')
        disp(sprintf('Skipping. Image file already exists: %s',ImageFileNameStr));
    else
        disp(sprintf('Acquiring image file: %s',ImageFileNameStr));
        
        %The UpdateSectionOverviewDisplay(handles) function uses the
        %SectionLabel_EditBox to determine which section to update. This
        %function sets the parameters that are needed by
        %GoToMontageTargetPointRotationAndFOV
        set(handles.SectionLabel_EditBox,'String',LabelStr);
        UpdateSectionOverviewDisplay(handles);
        
        GoToMontageTargetPointRotationAndFOV;
        
        
        IsDoAutoFocus =true;
        if IsDoAutoFocus
            PerformAutoFocusStigFocus;%PerformAutoFocus; %
        end
        pause(2);
        
        MyStr = sprintf('Acquiring %s, Please wait...',ImageFileNameStr);
        h_msgbox = msgbox(MyStr,'modal');
        
        StartTimeOfImageAcquire = tic;
        
        %Acquire image
        %Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, FileNameStr,...
        %     FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr)
        IsDoAutoRetakeIfNeeded = true;
        IsMagOverride = false;
        MagForOverride = -1;
        WaferNameStr = '';
        ImageWidthInPixels = 16384;%10000;%16384;%8192;
        ImageHeightInPixels = 16384;%10000;%16384;%8192;
        DwellTimeInMicroseconds = 1;
        Fibics_AcquireImage(ImageWidthInPixels, ImageHeightInPixels, DwellTimeInMicroseconds, ImageFileNameStr,...
            FOV_microns, IsDoAutoRetakeIfNeeded, IsMagOverride, MagForOverride,  WaferNameStr, LabelStr);
        
        disp(sprintf('Image Acquire Duration = %0.7g seconds',toc(StartTimeOfImageAcquire)));
        
        IsReadOK = false;
        while ~IsReadOK
            IsReadOK = true;
            try
                %don't read entire file, will cause memory error
                MyImage = imread(ImageFileNameStr, 'tif','PixelRegion',{[1 floor(ImageHeightInPixels/16)], [1 floor(ImageWidthInPixels/16)]});
            catch MyException
                IsReadOK = false;
                pause(.1);
            end
        end
    end
    
end