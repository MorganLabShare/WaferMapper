
ColorCombinedImage = [];

%load SectionOverviewTemplateCroppedFilledPeriphery.tif image, then apply light filtering
FileNameStr = sprintf('%s\\SectionOverviewTemplateCroppedFilledPeriphery.tif',GuiGlobalsStruct.SectionOverviewTemplateDirectory);
SectionOverviewTemplateCroppedFilled = imread(FileNameStr,'tif');
H_gaussian = fspecial('gaussian',[5 5],1.5);
CenteredTemplateImage = imfilter(SectionOverviewTemplateCroppedFilled,H_gaussian);
%downsample
DSFactor = 8;
CenteredTemplateImageDS = imresize(CenteredTemplateImage,1/DSFactor,'bilinear');
%Must down sample by 8x to prevent out of memory error on fibics computer


%determine max label in the SectionOverviewsDirectory
MaxLabelNum = -1;
DirList = dir(GuiGlobalsStruct.SectionOverviewsDirectory);
for i = 1:length(DirList)
    if length(DirList(i).name) > 5
        if strcmp(DirList(i).name(((end-length('.tif'))+1:end)), '.tif')
            %Extract Label
            Label = DirList(i).name(length('SectionOverview_')+1:end-4);
            LableNum = str2num(Label);
            if LableNum > MaxLabelNum
                MaxLabelNum = LableNum;
            end
        end
    end
end

for SectionNum = 1:MaxLabelNum
    Label = num2str(SectionNum);
    OverviewImageFileNameStr = sprintf('%s\\SectionOverview_%s.tif',GuiGlobalsStruct.SectionOverviewsDirectory,Label); 
    
    %load overview image and apply light filtering
    disp(sprintf('Loading image file: %s',OverviewImageFileNameStr));
    OverviewImage = imread(OverviewImageFileNameStr,'tif');
    OverviewImage = imfilter(OverviewImage,H_gaussian);
    
    %downsample
    OverviewImageDS = imresize(OverviewImage,1/DSFactor,'bilinear');
            
    
    ColorCombinedImage(:,:,1) = double(OverviewImageDS)/255;
    ColorCombinedImage(:,:,2) = double(CenteredTemplateImageDS)/255;
    ColorCombinedImage(:,:,3) = 0*ColorCombinedImage(:,:,1);
    figure(555);
    imshow(ColorCombinedImage);
    
    uiwait(msgbox('Go to next?'));
end
            