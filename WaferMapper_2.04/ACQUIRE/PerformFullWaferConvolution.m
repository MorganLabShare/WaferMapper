%Perform Convolution
global GuiGlobalsStruct;


[HeightSubWindowForAreaToMatch, WidthSubWindowForAreaToMatch] = size(GuiGlobalsStruct.SubImageForAreaToMatch);
[HeightSubWindowForTemplate, WidthSubWindowForTemplate] = size(GuiGlobalsStruct.SubImageForTemplate);

%AnglesToTryArray = linspace(-6,6,7); %original
%AnglesToTryArray = linspace(-14,14,15);
AnglesToTryArray = linspace(GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMinAngle,...
    GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryMaxAngle,...
    GuiGlobalsStruct.WaferParameters.AutoMapAnglesToTryNumberOfAngles);

%Fill in black regions created due to rotating with the average value of the
%periphery of the image
[MaxR, MaxC] = size(GuiGlobalsStruct.SubImageForTemplate);
AverageOfPeriphery = mean( GuiGlobalsStruct.SubImageForTemplate(1:MaxR,1) );

%This is the main array that will be used to find sections (max of all
%convolutions at different angles)
GuiGlobalsStruct.C_ValidRegion_ArrayOfMax = [];

h_fig_ForIntermediateResults = figure();

for i = 1:length(AnglesToTryArray)

    %SubImageForAreaToMatch_rotated = imrotate(SubImageForAreaToMatch,AnglesToTryArray(i),'crop');
    SubImageForTemplate_rotated = imrotate(GuiGlobalsStruct.SubImageForTemplate,AnglesToTryArray(i),'crop');
    
    %Fill in black regions created due to rotating with the average value of the
    %periphery of the image
    for r = 1:MaxR
        for c = 1:MaxC
            if SubImageForTemplate_rotated(r,c) == 0
                SubImageForTemplate_rotated(r,c) = AverageOfPeriphery;
            end
        end
    end

    figure(h_fig_ForIntermediateResults);
    subplot(1,2,1);
    imshow(SubImageForTemplate_rotated);
    pause(.01)
    

    %Compute correlation between images (includes a lot of regions that are not valid)
    C = normxcorr2(SubImageForTemplate_rotated, GuiGlobalsStruct.SubImageForAreaToMatch);



    %Extract only the region of C that used entire template for corr
    [Height_C, Width_C] = size(C);
    %C_ValidRegion = C(HeightSubWindowForTemplate:Height_C-HeightSubWindowForTemplate, WidthSubWindowForTemplate:Width_C-WidthSubWindowForTemplate);
    
    C_ValidRegion = C(round(HeightSubWindowForTemplate/2):Height_C-round(HeightSubWindowForTemplate/2), round(WidthSubWindowForTemplate/2):Width_C-round(WidthSubWindowForTemplate/2));
    
  
    if isempty(GuiGlobalsStruct.C_ValidRegion_ArrayOfMax)
        GuiGlobalsStruct.C_ValidRegion_ArrayOfMax = C_ValidRegion;
    else
        GuiGlobalsStruct.C_ValidRegion_ArrayOfMax = max(GuiGlobalsStruct.C_ValidRegion_ArrayOfMax, C_ValidRegion);
    end
    
    I = GuiGlobalsStruct.C_ValidRegion_ArrayOfMax;
    
    I = I -min(I(:));
    I = I / max(I(:));
    GuiGlobalsStruct.C_ValidRegion_ArrayOfMax = I;
   figure(h_fig_ForIntermediateResults);
   subplot(1,2,2);
    imagesc(C_ValidRegion);
     
end
pause(.1)
if ishandle(h_fig_ForIntermediateResults)
    close(h_fig_ForIntermediateResults);
end
