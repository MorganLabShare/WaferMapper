%AlignOverviews

filestruct = dir([GuiGlobalsStruct.SectionOverviewsDirectory '\*.tif']);
labels=zeros(1,length(filestruct));
Files=cell(1,length(filestruct));
MatFiles=cell(1,length(filestruct));

for i = 1:length(filestruct)
            %Extract Label
            Files{i}=[GuiGlobalsStruct.SectionOverviewsDirectory filesep filestruct(i).name];
            Label = filestruct(i).name(length('SectionOverview_')+1:end-4);
            MatFiles{i}=[GuiGlobalsStruct.SectionOverviewsDirectory filesep filestruct(i).name(1:end-3) 'mat'];
            labels(i) = str2num(Label);
end
[labels,indices]=sort(labels);
Files=Files(indices);
MatFiles=MatFiles(indices);

[xpos,ypos,angles,avg_inliers]=GlobalRigidAlignFiles(Files,MatFiles);

for i = 1:length(Files)
      
    %GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory = 'C:\MasterUTSLDirectory\CortexUTSL004\Wafer005\SectionOverviewsAlignedWithTemplateDirectory';
    OverviewImageAlignedFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.tif',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,num2str(labels(i)));
    OverviewAlignedDataFileNameStr = sprintf('%s\\SectionOverviewAligned_%s.mat',GuiGlobalsStruct.SectionOverviewsAlignedWithTemplateDirectory,num2str(labels(i)));
    radangle=angles(i)*pi/180;
    OverviewImage=imread(Files{i});
 
    tform=maketform('affine',[cos(radangle) sin(radangle) 0;-sin(radangle) cos(radangle) 0;xpos(i) ypos(i) 1]); 
    OverviewImage_rotated_shifted=imtransform(OverviewImage,tform,'bicubic','Xdata',[1 size(OverviewImage,2)],'Ydata',[1 size(OverviewImage,1)],'FillValues',128);
    imwrite(OverviewImage_rotated_shifted,OverviewImageAlignedFileNameStr,'tif','Compression','none');
    AlignmentParameters.r_offset = -ypos(i);
    AlignmentParameters.c_offset = xpos(i);
    AlignmentParameters.AngleOffsetInDegrees = -angles(i);
    save(OverviewAlignedDataFileNameStr, 'AlignmentParameters');
    
end


