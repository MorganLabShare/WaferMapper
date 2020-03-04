function UtilityScript_AnalizeImageJAlignedStackOffsets()

uiwait(msgbox('Note: This assumes filename formats like ''RigidAligned0001.tif'''));
pause(1);
%[FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE)
[ExampleFileName, PathName, FilterIndex] = uigetfile('*.tif', 'Select directory containing images:')
% FileName = RigidAligned0001.tif
% PathName = Z:\Hayworth\PostionTestStuff\Stack_OriginalSessionNoRelaod_BasedOnIBSC\RigidAligned\

SaveFileName = sprintf('%sCalculatedPixelOffsets.mat',PathName);
IsSkipImageProcessing = false;
if exist(SaveFileName, 'file')
    YesNoAnswerToUseExistingFile = questdlg('Use existing CalculatedPixelOffsets.mat file?', ...
                         'Question', ...
                         'Yes', 'No', 'Yes');
    if strcmp(YesNoAnswerToUseExistingFile, 'Yes')
        IsSkipImageProcessing = true;
    end
end


if ~IsSkipImageProcessing
    FileNameBeforeNumber = ExampleFileName(1:end-8)
    
    SectionNum = 1;
    while true
        TempNum = 10000 + SectionNum;
        TempNumStr = num2str(TempNum);
        FileName = sprintf('%s%s%s.tif',PathName, FileNameBeforeNumber, TempNumStr(2:end));
        if ~exist(FileName)
            break;
        end
        
        disp(sprintf('Processing file: %s', FileName));
        
        MyImage = imread(FileName, 'tif');
        
        
        %%% Determine the black background offsets around all sides %%%
        VerticalVector = MyImage(1:end, floor(end/2));
        NumZeroPixelsOnTop = 0;
        for i=1:length(VerticalVector)
            if VerticalVector(i) ~= 0
                break;
            end
            NumZeroPixelsOnTop = 1 + NumZeroPixelsOnTop;
        end
        NumZeroPixelsOnBottom = 0;
        for i=length(VerticalVector):-1:1
            if VerticalVector(i) ~= 0
                break;
            end
            NumZeroPixelsOnBottom = 1 + NumZeroPixelsOnBottom;
        end
        
        HorizontalVector = MyImage(floor(end/2), 1:end);
        NumZeroPixelsOnLeft = 0;
        for i=1:length(HorizontalVector)
            if HorizontalVector(i) ~= 0
                break;
            end
            NumZeroPixelsOnLeft = 1 + NumZeroPixelsOnLeft;
        end
        NumZeroPixelsOnRight = 0;
        for i=length(HorizontalVector):-1:1
            if HorizontalVector(i) ~= 0
                break;
            end
            NumZeroPixelsOnRight = 1 + NumZeroPixelsOnRight;
        end
        
        
        %%% Determine x,y offset (in pixels) for image %%%
        if NumZeroPixelsOnTop > NumZeroPixelsOnBottom
            Y_Offset = -NumZeroPixelsOnTop;
        else
            Y_Offset = NumZeroPixelsOnBottom;
        end
        
        if NumZeroPixelsOnLeft > NumZeroPixelsOnRight
            X_Offset = NumZeroPixelsOnLeft;
        else
            X_Offset = -NumZeroPixelsOnRight;
        end
        
        X_Offset_Array(SectionNum) = X_Offset;
        Y_Offset_Array(SectionNum) = Y_Offset;
        
        
        SectionNum = SectionNum  + 1;
    end
    
    disp(sprintf('Saving file: %s', SaveFileName));
    save(SaveFileName,'X_Offset_Array', 'Y_Offset_Array');
end

load(SaveFileName,'X_Offset_Array', 'Y_Offset_Array');

%ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER) 
MicronsPerPixelConversionFactorStr = inputdlg('Enter microns/pixel conversion factor to use:', 'um/pix', 1, {'0.02'});
MicronsPerPixelConversionFactor = str2double(MicronsPerPixelConversionFactorStr);

SecNumArray = 1:length(X_Offset_Array);

figure(1);
subplot(2,1,1);
plot(SecNumArray, MicronsPerPixelConversionFactor*X_Offset_Array, '-o');
title('X\_Offset\_Array');
ylabel('(microns)');
subplot(2,1,2);
plot(SecNumArray, MicronsPerPixelConversionFactor*Y_Offset_Array, '-o');
title('Y\_Offset\_Array');
ylabel('(microns)');
xlabel('Section Number');

figure(2);
%SCATTER(X,Y,S,C)
scatter(MicronsPerPixelConversionFactor*X_Offset_Array, MicronsPerPixelConversionFactor*Y_Offset_Array);
axis equal;
title('Position offsets');
xlabel('(microns)');
ylabel('(microns)');


%Compute Statistics
MeanX = mean(MicronsPerPixelConversionFactor*X_Offset_Array);
StdX = std(MicronsPerPixelConversionFactor*X_Offset_Array);
RangeX = max(MicronsPerPixelConversionFactor*X_Offset_Array) - min(MicronsPerPixelConversionFactor*X_Offset_Array);
MeanY = mean(MicronsPerPixelConversionFactor*Y_Offset_Array);
StdY = std(MicronsPerPixelConversionFactor*Y_Offset_Array);
RangeY = max(MicronsPerPixelConversionFactor*Y_Offset_Array) - min(MicronsPerPixelConversionFactor*Y_Offset_Array);

disp(sprintf('X: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanX, StdX, RangeX));
disp(sprintf('Y: mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanY, StdY, RangeY));

X_Offset_Array_LinearTrendRemoved = detrend(X_Offset_Array);
Y_Offset_Array_LinearTrendRemoved = detrend(Y_Offset_Array);

figure(3);
subplot(2,1,1);
plot(SecNumArray, MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved, '-o');
title('X\_Offset\_Array (Linear Trend Removed)');
ylabel('(microns)');
subplot(2,1,2);
plot(SecNumArray, MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved, '-o');
title('Y\_Offset\_Array (Linear Trend Removed)');
ylabel('(microns)');
xlabel('Section Number');

figure(4);
%SCATTER(X,Y,S,C)
scatter(MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved, MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved);
axis equal;
title('Position offsets  (Linear Trend Removed)');
xlabel('(microns)');
ylabel('(microns)');

%Compute Statistics
MeanX_LTR = mean(MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved);
StdX_LTR = std(MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved);
RangeX_LTR = max(MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved) - min(MicronsPerPixelConversionFactor*X_Offset_Array_LinearTrendRemoved);
MeanY_LTR = mean(MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved);
StdY_LTR = std(MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved);
RangeY_LTR = max(MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved) - min(MicronsPerPixelConversionFactor*Y_Offset_Array_LinearTrendRemoved);

disp(sprintf('X (linear trend removed): mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanX_LTR, StdX_LTR, RangeX_LTR));
disp(sprintf('Y (linear trend removed): mean=%0.5gum, stdev=%0.5gum, range=%0.5gum',MeanY_LTR, StdY_LTR, RangeY_LTR));
