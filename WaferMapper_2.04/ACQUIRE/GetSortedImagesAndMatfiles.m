function [Files,MatFiles,labels]=GetSortedImagesAndMatfiles(directory)

filestruct = dir([directory '\*.tif']);
labels=zeros(1,length(filestruct));
Files=cell(1,length(filestruct));
MatFiles=cell(1,length(filestruct));
for i = 1:length(filestruct)
            %Extract Label
            Files{i}=[directory filesep filestruct(i).name];
            Label = filestruct(i).name(length('SectionOverview_')+1:end-4);
            MatFiles{i}=[directory filesep filestruct(i).name(1:end-3) 'mat'];
            labels(i) = str2num(Label);
end
[labels,indices]=sort(labels);
Files=Files(indices);
MatFiles=MatFiles(indices);